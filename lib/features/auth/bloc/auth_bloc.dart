import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcart/core/service/push_service.dart';
import 'package:nextcart/features/auth/bloc/auth_state.dart';

import '../../../data/repository/auth_repository.dart';

part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required this._authRepository}) : super(AuthInitial()) {
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
          await PushService.instance.registerToken();
          emit(AuthSuccess(response.user!));
        } else {
          emit(AuthFailure('Gagal membuat akun.'));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
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
          await PushService.instance.registerToken();
          emit(AuthSuccess(response.user!));
        } else {
          emit(AuthFailure('User tidak ditemukan.'));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await PushService.instance.deleteToken();
        await _authRepository.signOut();
        emit(AuthInitial());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
