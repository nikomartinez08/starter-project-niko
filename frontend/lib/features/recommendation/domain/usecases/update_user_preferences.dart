import '../../../../core/usecase/usecase.dart';
import '../repository/recommendation_repository.dart';

class UpdatePreferencesParams {
  final bool isLike;
  final String category;
  final List<String> tags;

  UpdatePreferencesParams(this.isLike, this.category, this.tags);
}

class UpdateUserPreferencesUseCase implements UseCase<void, UpdatePreferencesParams> {
  final RecommendationRepository _repository;

  UpdateUserPreferencesUseCase(this._repository);

  @override
  Future<void> call({UpdatePreferencesParams? params}) async {
    if (params == null) return;
    
    if (params.isLike) {
      await _repository.addLike(params.category, params.tags);
    } else {
      await _repository.addDislike(params.category, params.tags);
    }
  }
}
