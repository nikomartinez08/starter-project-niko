import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/user_model.dart';
// import 'auth_firebase_service.dart'; // <-- BORRA ESTA LÍNEA SI EXISTE
import 'auth_remote_data_source.dart';

class AuthSupabaseServiceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AuthSupabaseServiceImpl(this._supabaseClient);

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _supabaseClient.auth.currentUser;
    if (user != null) {
      return UserModel.fromSupabaseUser(user);
    }
    return null;
  }

  @override
  Stream<UserModel?> get user {
    return _supabaseClient.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user == null) {
        return null;
      } else {
        return UserModel.fromSupabaseUser(user);
      }
    });
  }

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      final user = response.user;
      if (user == null) {
        throw Exception('Sign in failed: User is null');
      }
      return UserModel.fromSupabaseUser(user);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  @override
  Future<UserModel> signUp(String email, String password, {String? name}) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );
      
      final user = response.user;
      if (user == null) {
        throw Exception('Sign up failed: User is null');
      }
      return UserModel.fromSupabaseUser(user);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google Sign In canceled');
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw Exception('No Access Token found');
      }
      if (idToken == null) {
        throw Exception('No ID Token found');
      }

      final response = await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      final user = response.user;
      if (user == null) {
        throw Exception('Sign in with Google failed: User is null');
      }
      
      return UserModel.fromSupabaseUser(user);
    } catch (e) {
      throw Exception('Google Sign In error: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
    try {
      await GoogleSignIn().signOut();
    } catch (_) {
      // Ignore if not signed in with Google
    }
  }

  @override
  Future<void> deleteAccount() async {
    // Supabase no permite que un usuario se borre a sí mismo por seguridad (por defecto).
    // Se requiere una Edge Function o llamar a una API administrativa.
    // Por ahora lanzamos excepción o lo dejamos vacío.
    throw UnimplementedError('Delete account requires admin API or Edge Function in Supabase');
  }
}
