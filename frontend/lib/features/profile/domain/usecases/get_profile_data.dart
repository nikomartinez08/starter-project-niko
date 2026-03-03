import '../../../../core/usecase/usecase.dart';
import '../entities/profile_entities.dart';
import '../repository/profile_repository.dart';

class GetProfileDataUseCase {
  final ProfileRepository _repository;

  GetProfileDataUseCase(this._repository);

  Stream<UserProfileDataEntity> call() {
    return _repository.getUserProfile();
  }
}
