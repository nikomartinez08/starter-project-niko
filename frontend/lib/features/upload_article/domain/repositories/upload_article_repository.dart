import '../entities/article_input.dart';

abstract class UploadArticleRepository {
  Future<void> uploadArticle(ArticleInput article);
}
