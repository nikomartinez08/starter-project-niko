import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class SignInWithGithubUseCase implements UseCase<void, void> {
  final AuthRepository _authRepository;

  SignInWithGithubUseCase(this._authRepository);

  @override
  Future<void> call({void params}) {
    return _authRepository.signInWithGithub();
  }
}
