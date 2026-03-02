import 'package:floor/floor.dart';
import '../../models/favorite_article_model.dart';

@dao
abstract class FavoriteDao {
  @Query('SELECT * FROM favorite_article ORDER BY id DESC')
  Future<List<FavoriteArticleModel>> getFavorites();

  @Query(
      'SELECT * FROM favorite_article WHERE externalId = :externalId LIMIT 1')
  Future<FavoriteArticleModel?> getFavoriteByExternalId(String externalId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertFavorite(FavoriteArticleModel article);

  @delete
  Future<void> deleteFavorite(FavoriteArticleModel article);

  @Query('DELETE FROM favorite_article WHERE externalId = :externalId')
  Future<void> deleteFavoriteByExternalId(String externalId);
}
