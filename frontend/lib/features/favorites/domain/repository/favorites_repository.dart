import '../entities/favorite_article.dart';

abstract class FavoritesRepository {
  Future<List<FavoriteArticleEntity>> getFavorites();
  
  // Toggles the favorite status. Returns true if added, false if removed.
  Future<bool> toggleFavorite(FavoriteArticleEntity article);
  
  // Check if an article is favorited
  Future<bool> isFavorite(String externalId);
}
