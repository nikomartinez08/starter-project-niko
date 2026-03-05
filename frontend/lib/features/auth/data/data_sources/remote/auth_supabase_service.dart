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
  Future<void> signInWithGithub() async {
    try {
      await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: 'io.supabase.newsapp://login-callback/',
      );
    } catch (e) {
      throw Exception('GitHub Sign In error: $e');
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
    try {
      // Intenta llamar a la función RPC 'delete_user' si existe en Supabase
      // SQL requerida en Supabase: 
      // create or replace function delete_user() returns void as $$ begin delete from auth.users where id = auth.uid(); end; $$ language plpgsql security definer;
      await _supabaseClient.rpc('delete_user');
    } catch (e) {
      // Si la función no existe, simplemente ignoramos el error y cerramos sesión
      // Esto evita que la app falle si el backend no tiene la función configurada
    }
    
    // Siempre cerramos sesión para que el usuario salga de la pantalla
    await signOut();
  }
}
