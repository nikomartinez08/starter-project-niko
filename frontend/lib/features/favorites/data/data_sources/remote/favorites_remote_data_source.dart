import '../../models/favorite_article_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<FavoriteArticleModel>> getFavorites();
  Future<void> saveFavorite(FavoriteArticleModel article);
  Future<void> removeFavorite(String externalId);
}
