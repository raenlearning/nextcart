part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;

  AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
  });
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({required this.email, required this.password});
}

class AuthLogoutRequested extends AuthEvent {}