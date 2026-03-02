import '../../../../core/usecase/usecase.dart';
import '../entities/profile_entities.dart';
import '../repository/profile_repository.dart';

class GetProfileDataUseCase implements UseCase<UserProfileDataEntity, void> {
  final ProfileRepository _repository;

  GetProfileDataUseCase(this._repository);

  @override
  Future<UserProfileDataEntity> call({void params}) {
    return _repository.getUserProfile();
  }
}
