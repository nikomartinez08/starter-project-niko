import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class DeleteAccountUseCase implements UseCase<void, void> {
  final AuthRepository _authRepository;

  DeleteAccountUseCase(this._authRepository);

  @override
  Future<void> call({void params}) {
    return _authRepository.deleteAccount();
  }
}
