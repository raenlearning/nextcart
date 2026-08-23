import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcart/core/service/push_service.dart';
import 'package:nextcart/features/auth/bloc/auth_state.dart';

import '../../../data/repository/auth_repository.dart';

part 'auth_event.dart';

String _friendlyErrorMessage(Object e) {
  final message = e.toString();
  const prefix = 'Exception: ';
  return message.startsWith(prefix) ? message.substring(prefix.length) : message;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final Future<void> Function() _registerToken;
  final Future<void> Function() _deleteToken;

  AuthBloc({
    required this._authRepository,
    Future<void> Function()? registerToken,
    Future<void> Function()? deleteToken,
  })  : _registerToken = registerToken ?? PushService.instance.registerToken,
        _deleteToken = deleteToken ?? PushService.instance.deleteToken,
        super(AuthInitial()) {
    // Handler Register
    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await _authRepository.signUp(
          email: event.email,
          password: event.password,
          fullName: event.fullName,
        );
        if (response.user != null) {
          await _registerToken();
          emit(AuthSuccess(response.user!));
        } else {
          emit(AuthFailure('Gagal membuat akun.'));
        }
      } catch (e) {
        emit(AuthFailure(_friendlyErrorMessage(e)));
      }
    });

    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await _authRepository.signIn(
          email: event.email,
          password: event.password,
        );
        if (response.user != null) {
          await _registerToken();
          emit(AuthSuccess(response.user!));
        } else {
          emit(AuthFailure('User tidak ditemukan.'));
        }
      } catch (e) {
        emit(AuthFailure(_friendlyErrorMessage(e)));
      }
    });

    on<AuthGoogleSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _authRepository.signInWithGoogle();
        await _registerToken();
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailure(_friendlyErrorMessage(e)));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _deleteToken();
        await _authRepository.signOut();
        emit(AuthInitial());
      } catch (e) {
        emit(AuthFailure(_friendlyErrorMessage(e)));
      }
    });

    on<AuthForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.resetPasswordForEmail(event.email);
        emit(AuthForgotPasswordSent());
      } catch (e) {
        emit(AuthFailure(_friendlyErrorMessage(e)));
      }
    });
  }
}
