import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/remote/auth_remote_data_source.dart';
import '../data_sources/local/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  AuthRepositoryImpl(this._authRemoteDataSource, this._authLocalDataSource);

  @override
  Future<UserEntity> signIn(String email, String password) async {
    final user = await _authRemoteDataSource.signIn(email, password);
    await _authLocalDataSource.saveUser(user);
    return user;
  }

  @override
  Future<UserEntity> signUp(String email, String password, {String? name}) async {
    final user = await _authRemoteDataSource.signUp(email, password, name: name);
    await _authLocalDataSource.saveUser(user);
    return user;
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final user = await _authRemoteDataSource.signInWithGoogle();
    await _authLocalDataSource.saveUser(user);
    return user;
  }

  @override
  Future<void> signInWithGithub() async {
    await _authRemoteDataSource.signInWithGithub();
  }

  @override
  Future<void> signOut() async {
    await _authLocalDataSource.clearUser();
    await _authRemoteDataSource.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    await _authLocalDataSource.clearUser();
    await _authRemoteDataSource.deleteAccount();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    // Try local cache first for instant startup
    final cachedUser = await _authLocalDataSource.getUser();
    if (cachedUser != null) return cachedUser;
    // Fall back to remote
    return _authRemoteDataSource.getCurrentUser();
  }

  @override
  Stream<UserEntity?> get user {
    return _authRemoteDataSource.user;
  }
}
