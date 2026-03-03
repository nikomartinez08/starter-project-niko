import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase implements UseCase<UserEntity, Map<String, String>> {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  @override
  Future<UserEntity> call({Map<String, String>? params}) {
    return _authRepository.signIn(params!['email']!, params['password']!);
  }
}
