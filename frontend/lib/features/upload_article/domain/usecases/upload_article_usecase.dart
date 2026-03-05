import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import '../entities/article_input.dart';
import '../repositories/upload_article_repository.dart';

class UploadArticleUseCase implements UseCase<void, ArticleInput> {
  final UploadArticleRepository _repository;

  UploadArticleUseCase(this._repository);

  @override
  Future<void> call({ArticleInput? params}) {
    if (params == null) {
      throw ArgumentError("ArticleInput cannot be null");
    }
    return _repository.uploadArticle(params);
  }
}
