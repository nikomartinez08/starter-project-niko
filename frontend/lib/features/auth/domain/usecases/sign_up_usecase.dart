import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase implements UseCase<UserEntity, Map<String, String>> {
  final AuthRepository _authRepository;

  SignUpUseCase(this._authRepository);

  @override
  Future<UserEntity> call({Map<String, String>? params}) {
    return _authRepository.signUp(
      params!['email']!,
      params['password']!,
      name: params['name'],
    );
  }
}
