import '../../domain/entities/favorite_article.dart';
import '../../domain/repository/favorites_repository.dart';
import '../data_sources/local/favorites_dao.dart';
import '../data_sources/remote/favorites_remote_data_source.dart';
import '../models/favorite_article_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoriteDao _localDataSource;
  final FavoritesRemoteDataSource _remoteDataSource;

  FavoritesRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<List<FavoriteArticleEntity>> getFavorites() async {
    try {
      // Try to fetch from remote first if online/authenticated
      final remoteFavorites = await _remoteDataSource.getFavorites();

      // Sync local with remote
      for (var fav in remoteFavorites) {
        await _localDataSource.insertFavorite(fav);
      }

      return remoteFavorites;
    } catch (e) {
      // If offline or unauthenticated, fallback to local database
      final localFavorites = await _localDataSource.getFavorites();
      return localFavorites;
    }
  }

  @override
  Future<bool> isFavorite(String externalId) async {
    final local = await _localDataSource.getFavoriteByExternalId(externalId);
    return local != null;
  }

  @override
  Future<bool> toggleFavorite(FavoriteArticleEntity article) async {
    final isFav = await isFavorite(article.externalId!);
    final model = FavoriteArticleModel.fromEntity(article);

    if (isFav) {
      // Remove
      await _localDataSource.deleteFavoriteByExternalId(article.externalId!);
      try {
        await _remoteDataSource.removeFavorite(article.externalId!);
      } catch (e) {
        // Ignore remote error if offline, but ideally sync later
      }
      return false; // Result is NOT favorite
    } else {
      // Add
      await _localDataSource.insertFavorite(model);
      try {
        await _remoteDataSource.saveFavorite(model);
      } catch (e) {
        // Ignore remote error if offline
      }
      return true; // Result IS favorite
    }
  }
}
