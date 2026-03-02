import '../../../../core/usecase/usecase.dart';
import '../entities/favorite_article.dart';
import '../repository/favorites_repository.dart';

class ToggleFavoriteUseCase implements UseCase<bool, FavoriteArticleEntity> {
  final FavoritesRepository _repository;

  ToggleFavoriteUseCase(this._repository);

  @override
  Future<bool> call({FavoriteArticleEntity? params}) {
    if (params == null) throw ArgumentError('FavoriteArticleEntity cannot be null');
    return _repository.toggleFavorite(params);
  }
}

class CheckFavoriteUseCase implements UseCase<bool, String> {
  final FavoritesRepository _repository;

  CheckFavoriteUseCase(this._repository);

  @override
  Future<bool> call({String? params}) {
    if (params == null) throw ArgumentError('ExternalId cannot be null');
    return _repository.isFavorite(params);
  }
}
