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
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  DateTime? _lastFetchTime;
  static const int _pageSize = 20;
  static const int _maxPage = 5; // 5 pages × 20 = 100 articles (NewsAPI free tier max)
  static const Duration _fetchCooldown = Duration(seconds: 30);
  static const Duration _refreshCooldown = Duration(seconds: 60);

  RemoteArticlesBloc(
    this._getArticleUseCase,
    this._getPersonalizedFeedUseCase,
    this._updateUserPreferencesUseCase,
  ) : super(const RemoteArticlesLoading()) {
    on<GetArticles>(onGetArticles);
    on<LoadMoreArticles>(onLoadMoreArticles);
    on<RefreshArticles>(onRefreshArticles);
    on<SwipeArticleEvent>(onSwipeArticle);
    on<FilterArticles>(onFilterArticles);
    on<ResetFilter>(onResetFilter);
  }

  void onGetArticles(
      GetArticles event, Emitter<RemoteArticlesState> emit) async {
    _currentPage = 1;
    _hasMore = true;
    final dataState = await _getArticleUseCase(
      params: GetArticleParams(page: _currentPage, pageSize: _pageSize),
    );
    _lastFetchTime = DateTime.now();

    if (dataState is DataSuccess) {
      _allFetchedArticles = dataState.data ?? [];
      _hasMore = (_allFetchedArticles.length >= _pageSize);
      await _applyCurrentFilterAndEmit(emit);
    }

    if (dataState is DataFailed) {
      emit(RemoteArticlesError(dataState.error!));
    }
  }

  bool _isCooldownActive(Duration cooldown) {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < cooldown;
  }

  Future<void> onLoadMoreArticles(
      LoadMoreArticles event, Emitter<RemoteArticlesState> emit) async {
    if (!_hasMore || _isLoadingMore) return;
    if (_currentPage >= _maxPage) {
      _hasMore = false;
      await _applyCurrentFilterAndEmit(emit);
      return;
    }
    if (_isCooldownActive(_fetchCooldown)) return;
    _isLoadingMore = true;

    emit(RemoteArticlesLoadingMore(
      List.from(_allFetchedArticles),
      hasMore: _hasMore,
    ));

    final nextPage = _currentPage + 1;
    final dataState = await _getArticleUseCase(
      params: GetArticleParams(page: nextPage, pageSize: _pageSize),
    );
    _lastFetchTime = DateTime.now();

    if (dataState is DataSuccess) {
      final newArticles = dataState.data ?? [];
      if (newArticles.isEmpty || newArticles.length < _pageSize) {
        _hasMore = false;
      }
      _currentPage = nextPage;
      _allFetchedArticles.addAll(newArticles);
      await _applyCurrentFilterAndEmit(emit);
    }

    if (dataState is DataFailed) {
      await _applyCurrentFilterAndEmit(emit);
    }

    _isLoadingMore = false;
  }

  Future<void> onRefreshArticles(
      RefreshArticles event, Emitter<RemoteArticlesState> emit) async {
    if (_isCooldownActive(_refreshCooldown)) {
      // Still emit current data so RefreshIndicator completes
      await _applyCurrentFilterAndEmit(emit);
      return;
    }
    _currentPage = 1;
    _hasMore = true;
    final dataState = await _getArticleUseCase(
      params: GetArticleParams(page: _currentPage, pageSize: _pageSize),
    );
    _lastFetchTime = DateTime.now();

    if (dataState is DataSuccess) {
      _allFetchedArticles = dataState.data ?? [];
      _hasMore = (_allFetchedArticles.length >= _pageSize);
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
      emit(RemoteArticlesDone(personalized, hasMore: _hasMore));
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
      emit(RemoteArticlesDone(filtered, hasMore: _hasMore));
    }
  }
}
