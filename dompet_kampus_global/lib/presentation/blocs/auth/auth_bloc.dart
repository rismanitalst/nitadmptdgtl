import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/google_login_usecase.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/error/failures.dart';
import '../../../injection/injection_container.dart' show setApiToken, clearApiToken;

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}
class AuthGoogleLoginRequested extends AuthEvent {}
class AuthLogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}
class AuthUnauthenticated extends AuthState {}
class AuthNeedsVerification extends AuthState {
  final UserEntity user;
  final String token;
  AuthNeedsVerification(this.user, this.token);
  @override
  List<Object?> get props => [user, token];
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase _login;
  final LogoutUsecase _logout;
  final GoogleLoginUsecase _googleLogin;
  final AuthRepository _authRepo;

  AuthBloc({
    required LoginUsecase login,
    required LogoutUsecase logout,
    required GoogleLoginUsecase googleLogin,
    required AuthRepository authRepo,
  })  : _login = login,
        _logout = logout,
        _googleLogin = googleLogin,
        _authRepo = authRepo,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLogin);
    on<AuthGoogleLoginRequested>(_onGoogleLogin);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final token = await _authRepo.getSavedToken();
    if (token == null) {
      emit(AuthUnauthenticated());
      return;
    }
    final user = await _authRepo.getSavedUser();
    if (user == null) {
      emit(AuthUnauthenticated());
      return;
    }
    final verified = await _authRepo.isAuthVerified();
    if (!verified) {
      await _authRepo.logout();
      clearApiToken();
      emit(AuthUnauthenticated());
      return;
    }
    // Set JWT token on API client for outgoing requests
    setApiToken(token);
    emit(AuthAuthenticated(user));
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _login(email: event.email, password: event.password);
      setApiToken(result.token);
      emit(AuthNeedsVerification(result.user, result.token));
    } on AuthFailure catch (e) {
      emit(AuthError(e.message));
    } on ServerFailure catch (e) {
      emit(AuthError(e.message));
    } on NetworkFailure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Terjadi kesalahan. Silakan coba lagi.'));
    }
  }

  Future<void> _onGoogleLogin(AuthGoogleLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _googleLogin();
      setApiToken(result.token);
      emit(AuthNeedsVerification(result.user, result.token));
    } on AuthFailure catch (e) {
      emit(AuthError(e.message));
    } on ServerFailure catch (e) {
      emit(AuthError(e.message));
    } on NetworkFailure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Login Google gagal. Silakan coba lagi.'));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _logout();
    clearApiToken();
    emit(AuthUnauthenticated());
  }
}
