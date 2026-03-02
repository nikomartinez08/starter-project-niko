import '../../../../core/usecase/usecase.dart';
import '../../../daily_news/domain/entities/article.dart';
import '../repository/recommendation_repository.dart';

class GetPersonalizedFeedUseCase implements UseCase<List<ArticleEntity>, List<ArticleEntity>> {
  final RecommendationRepository _repository;

  GetPersonalizedFeedUseCase(this._repository);

  @override
  Future<List<ArticleEntity>> call({List<ArticleEntity>? params}) {
    if (params == null || params.isEmpty) return Future.value([]);
    return _repository.getPersonalizedFeed(params);
  }
}
