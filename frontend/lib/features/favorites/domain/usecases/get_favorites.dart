import '../../../../core/usecase/usecase.dart';
import '../entities/favorite_article.dart';
import '../repository/favorites_repository.dart';

class GetFavoritesUseCase implements UseCase<List<FavoriteArticleEntity>, void> {
  final FavoritesRepository _repository;

  GetFavoritesUseCase(this._repository);

  @override
  Future<List<FavoriteArticleEntity>> call({void params}) {
    return _repository.getFavorites();
  }
}
