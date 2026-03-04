import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);

  Future<UserModel> signUp(String email, String password, {String? name});

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<void> deleteAccount();

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> get user;
}