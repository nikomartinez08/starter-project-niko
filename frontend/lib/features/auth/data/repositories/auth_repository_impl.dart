import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/remote/auth_firebase_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;

  AuthRepositoryImpl(this._authRemoteDataSource);

  @override
  Future<UserEntity> signIn(String email, String password) {
    return _authRemoteDataSource.signIn(email, password);
  }

  @override
  Future<UserEntity> signUp(String email, String password, {String? name}) {
    return _authRemoteDataSource.signUp(email, password, name: name);
  }

  @override
  Future<UserEntity> signInWithGoogle() {
    return _authRemoteDataSource.signInWithGoogle();
  }

  @override
  Future<void> signOut() {
    return _authRemoteDataSource.signOut();
  }

  @override
  Future<void> deleteAccount() {
    return _authRemoteDataSource.deleteAccount();
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    return _authRemoteDataSource.getCurrentUser();
  }

  @override
  Stream<UserEntity?> get user {
    return _authRemoteDataSource.user;
  }
}
