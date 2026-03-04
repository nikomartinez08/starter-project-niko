import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

@dao
abstract class ArticleDao {

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertArticle(ArticleModel article);

  @delete
  Future<void> deleteArticle(ArticleModel articleModel);

  @Query('DELETE FROM article WHERE title = :title')
  Future<void> deleteArticleByTitle(String title);

  @Query('SELECT * FROM article')
  Future<List<ArticleModel>> getArticles();
}