import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_in_with_github_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithGithubUseCase _signInWithGithubUseCase;

  AuthBloc(
    this._signInUseCase,
    this._signUpUseCase,
    this._signOutUseCase,
    this._deleteAccountUseCase,
    this._getCurrentUserUseCase,
    this._signInWithGoogleUseCase,
    this._signInWithGithubUseCase,
  ) : super(AuthLoading()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInEvent>(_onSignIn);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignInWithGithubEvent>(_onSignInWithGithub);
    on<SignUpEvent>(_onSignUp);
    on<SignOutEvent>(_onSignOut);
    on<DeleteAccountEvent>(_onDeleteAccount);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    try {
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _signInUseCase(params: {
        'email': event.email,
        'password': event.password,
      });
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInWithGoogle(SignInWithGoogleEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _signInWithGoogleUseCase();
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInWithGithub(SignInWithGithubEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _signInWithGithubUseCase();
      // OAuth flow opens browser — session will be picked up by onAuthStateChange
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _signUpUseCase(params: {
        'email': event.email,
        'password': event.password,
        if (event.name != null) 'name': event.name!,
      });
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    try {
      await _signOutUseCase();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onDeleteAccount(DeleteAccountEvent event, Emitter<AuthState> emit) async {
    try {
      await _deleteAccountUseCase();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
