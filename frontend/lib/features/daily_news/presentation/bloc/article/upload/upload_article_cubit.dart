import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/upload/upload_article_state.dart';

class UploadArticleCubit extends Cubit<UploadArticleState> {
  final CreateArticleUseCase _createArticleUseCase;

  UploadArticleCubit(this._createArticleUseCase) : super(const UploadArticleInitial());

  Future<void> uploadArticle({
    required String title,
    required String content,
    required String urlToImage,
    required String author,
  }) async {
    emit(const UploadArticleLoading());

    try {
      final article = ArticleEntity(
        id: DateTime.now().millisecondsSinceEpoch, // temporary ID
        author: author,
        title: title,
        description: content.length > 50 ? content.substring(0, 50) + "..." : content,
        url: "",
        urlToImage: urlToImage,
        publishedAt: DateTime.now().toIso8601String(),
        content: content,
      );

      await _createArticleUseCase(params: article);
      
      emit(const UploadArticleSuccess());
    } catch (e) {
      emit(UploadArticleError(e.toString()));
    }
  }
}
