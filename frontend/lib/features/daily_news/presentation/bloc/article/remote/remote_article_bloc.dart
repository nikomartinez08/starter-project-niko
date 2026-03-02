import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import '../../../../domain/entities/article.dart';
import '../../../../../recommendation/domain/usecases/get_personalized_feed.dart';
import '../../../../../recommendation/domain/usecases/update_user_preferences.dart';

class RemoteArticlesBloc
    extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetArticleUseCase _getArticleUseCase;
  final GetPersonalizedFeedUseCase _getPersonalizedFeedUseCase;
  final UpdateUserPreferencesUseCase _updateUserPreferencesUseCase;

  List<ArticleEntity> _allFetchedArticles = [];
  String _currentFilter = 'All';

  RemoteArticlesBloc(
    this._getArticleUseCase,
    this._getPersonalizedFeedUseCase,
    this._updateUserPreferencesUseCase,
  ) : super(const RemoteArticlesLoading()) {
    on<GetArticles>(onGetArticles);
    on<SwipeArticleEvent>(onSwipeArticle);
    on<FilterArticles>(onFilterArticles);
    on<ResetFilter>(onResetFilter);
  }

  void onGetArticles(
      GetArticles event, Emitter<RemoteArticlesState> emit) async {
    final dataState = await _getArticleUseCase();

    if (dataState is DataSuccess) {
      _allFetchedArticles = dataState.data ?? [];
      await _applyCurrentFilterAndEmit(emit);
    }

    if (dataState is DataFailed) {
      emit(RemoteArticlesError(dataState.error!));
    }
  }

  void onSwipeArticle(
      SwipeArticleEvent event, Emitter<RemoteArticlesState> emit) async {
    final title = (event.article.title ?? '').toLowerCase();
    final url = (event.article.url ?? '').toLowerCase();

    String category = 'general';
    if (url.contains('tech') || title.contains('tech')) {
      category = 'technology';
    } else if (url.contains('sport') || title.contains('sport')) {
      category = 'sports';
    } else if (url.contains('politic') || title.contains('politic')) {
      category = 'politics';
    } else if (url.contains('finance') ||
        title.contains('market') ||
        title.contains('economy')) {
      category = 'finance';
    }

    final tags = title.split(' ').where((w) => w.length > 4).toList();

    await _updateUserPreferencesUseCase(
        params: UpdatePreferencesParams(event.isLike, category, tags));

    if (state is RemoteArticlesDone) {
      if (!event.isLike) {
        _allFetchedArticles.removeWhere((a) => a.url == event.article.url);
      }
      await _applyCurrentFilterAndEmit(emit);
    }
  }

  Future<void> onFilterArticles(
      FilterArticles event, Emitter<RemoteArticlesState> emit) async {
    _currentFilter = event.category;
    await _applyCurrentFilterAndEmit(emit);
  }

  Future<void> onResetFilter(
      ResetFilter event, Emitter<RemoteArticlesState> emit) async {
    _currentFilter = 'All';
    await _applyCurrentFilterAndEmit(emit);
  }

  Future<void> _applyCurrentFilterAndEmit(
      Emitter<RemoteArticlesState> emit) async {
    if (_currentFilter == 'All') {
      final personalized =
          await _getPersonalizedFeedUseCase(params: _allFetchedArticles);
      emit(RemoteArticlesDone(personalized));
    } else {
      final filtered = _allFetchedArticles.where((article) {
        final title = (article.title ?? '').toLowerCase();
        final url = (article.url ?? '').toLowerCase();
        String cat = 'general';
        if (url.contains('tech') || title.contains('tech')) {
          cat = 'Technology';
        } else if (url.contains('sport') || title.contains('sport')) {
          cat = 'Sports';
        } else if (url.contains('politic') || title.contains('politic')) {
          cat = 'Politics';
        } else if (url.contains('finance') ||
            title.contains('market') ||
            title.contains('economy')) {
          cat = 'Finance';
        }

        return cat.toLowerCase() == _currentFilter.toLowerCase();
      }).toList();
      emit(RemoteArticlesDone(filtered));
    }
  }
}
