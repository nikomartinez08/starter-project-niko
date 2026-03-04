import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
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

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl(this._firebaseAuth, this._googleSignIn);

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return UserModel.fromFirebaseUser(user);
    }
    return null;
  }

  @override
  Stream<UserModel?> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      } else {
        return UserModel.fromFirebaseUser(firebaseUser);
      }
    });
  }

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw Exception('Sign in failed: User is null');
      }
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Sign in failed');
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  @override
  Future<UserModel> signUp(String email, String password, {String? name}) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw Exception('Sign up failed: User is null');
      }
      if (name != null) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload();
        final updatedUser = _firebaseAuth.currentUser;
        return UserModel.fromFirebaseUser(updatedUser!);
      }
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('The email address is already in use by another account.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else if (e.code == 'operation-not-allowed') {
        throw Exception('Email/password accounts are not enabled.');
      } else if (e.code == 'weak-password') {
        throw Exception('The password is too weak.');
      }
      throw Exception(e.message ?? 'Sign up failed');
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Force user to pick account
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Sign in aborted by user');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Firebase requires at least one token: accessToken or idToken
      // Using accessToken for Firebase authentication
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      if (userCredential.user == null) {
        throw Exception('Sign in with Google failed: User is null');
      }
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Sign in with Google failed');
    } on PlatformException catch (e) {
      // common errors: sign_in_canceled, sign_in_failed, network_error
      throw Exception(e.message ?? 'Google sign-in failed');
    } catch (e) {
      throw Exception('Sign in with Google failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      // Ensure we disconnect so the user can choose another account next time
      await _googleSignIn.disconnect(); 
    } catch (_) {
      // Ignore errors if user wasn't signed in with Google
    }
    return _firebaseAuth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        await user.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          throw Exception(
              'The user must re-authenticate before this operation can be executed.');
        }
        throw Exception(e.message ?? 'Delete account failed');
      } catch (e) {
        throw Exception('Delete account failed: $e');
      }
    } else {
      throw Exception('No user signed in');
    }
  }
}
