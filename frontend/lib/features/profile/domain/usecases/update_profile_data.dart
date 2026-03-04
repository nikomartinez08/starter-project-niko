import '../repository/profile_repository.dart';

class UpdateProfileDataUseCase {
  final ProfileRepository _repository;

  UpdateProfileDataUseCase(this._repository);

  Future<void> call({String? name, String? title, String? photoUrl}) {
    return _repository.updateProfile(name: name, title: title, photoUrl: photoUrl);
  }
}
