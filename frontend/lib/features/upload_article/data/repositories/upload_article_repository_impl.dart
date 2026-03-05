import '../../domain/entities/article_input.dart';
import '../../domain/repositories/upload_article_repository.dart';
import '../datasources/remote/upload_article_remote_data_source.dart';

class UploadArticleRepositoryImpl implements UploadArticleRepository {
  final UploadArticleRemoteDataSource _remoteDataSource;

  UploadArticleRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> uploadArticle(ArticleInput article) {
    return _remoteDataSource.uploadArticle(article);
  }
}
