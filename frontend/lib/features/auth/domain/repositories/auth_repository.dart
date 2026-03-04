import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signIn(String email, String password);

  Future<UserEntity> signUp(String email, String password, {String? name});

  Future<UserEntity> signInWithGoogle();

  Future<void> signInWithGithub();

  Future<void> signOut();
  
  Future<void> deleteAccount();

  Future<UserEntity?> getCurrentUser();
  
  Stream<UserEntity?> get user;
}
