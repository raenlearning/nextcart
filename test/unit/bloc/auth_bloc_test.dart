import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextcart/data/repository/auth_repository.dart';
import 'package:nextcart/features/auth/bloc/auth_bloc.dart';
import 'package:nextcart/features/auth/bloc/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUser extends Mock implements User {}

void main() {
  late MockAuthRepository repository;
  late MockUser user;

  setUp(() {
    repository = MockAuthRepository();
    user = MockUser();
    when(() => user.id).thenReturn('user-1');
    when(() => user.email).thenReturn('a@b.c');
  });

  group('AuthBloc', () {
    AuthBloc buildBloc() => AuthBloc(
          authRepository: repository,
          registerToken: () async {},
          deleteToken: () async {},
        );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when register succeeds',
      build: buildBloc,
      act: (bloc) => bloc.add(AuthRegisterRequested(
        email: 'a@b.c',
        password: 'password123',
        fullName: 'Andi',
      )),
      setUp: () {
        when(() => repository.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              fullName: any(named: 'fullName'),
            )).thenAnswer((_) async => AuthResponse(user: user));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuccess>().having((s) => s.user.id, 'user id', 'user-1'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when register returns null user',
      build: buildBloc,
      act: (bloc) => bloc.add(AuthRegisterRequested(
        email: 'a@b.c',
        password: 'password123',
        fullName: 'Andi',
      )),
      setUp: () {
        when(() => repository.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              fullName: any(named: 'fullName'),
            )).thenAnswer((_) async => AuthResponse(user: null));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having(
          (s) => s.errorMessage,
          'message',
          'Gagal membuat akun.',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when register throws',
      build: buildBloc,
      act: (bloc) => bloc.add(AuthRegisterRequested(
        email: 'a@b.c',
        password: 'password123',
        fullName: 'Andi',
      )),
      setUp: () {
        when(() => repository.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              fullName: any(named: 'fullName'),
            )).thenThrow(Exception('network down'));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having(
          (s) => s.errorMessage,
          'message',
          contains('network down'),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when login succeeds',
      build: buildBloc,
      act: (bloc) => bloc.add(AuthLoginRequested(
        email: 'a@b.c',
        password: 'password123',
      )),
      setUp: () {
        when(() => repository.signIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => AuthResponse(user: user));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuccess>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when login returns null user',
      build: buildBloc,
      act: (bloc) => bloc.add(AuthLoginRequested(
        email: 'a@b.c',
        password: 'password123',
      )),
      setUp: () {
        when(() => repository.signIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => AuthResponse(user: null));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having(
          (s) => s.errorMessage,
          'message',
          'User tidak ditemukan.',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when login throws wrong credentials',
      build: buildBloc,
      act: (bloc) => bloc.add(AuthLoginRequested(
        email: 'a@b.c',
        password: 'salah',
      )),
      setUp: () {
        when(() => repository.signIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Email atau password salah.'));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having(
          (s) => s.errorMessage,
          'message',
          'Email atau password salah.',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when google sign-in succeeds',
      build: buildBloc,
      act: (bloc) => bloc.add(AuthGoogleSignInRequested()),
      setUp: () {
        when(() => repository.signInWithGoogle())
            .thenAnswer((_) async => user);
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuccess>().having((s) => s.user.id, 'user id', 'user-1'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when google sign-in fails',
      build: buildBloc,
      act: (bloc) => bloc.add(AuthGoogleSignInRequested()),
      setUp: () {
        when(() => repository.signInWithGoogle())
            .thenThrow(Exception('Google gagal'));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having(
          (s) => s.errorMessage,
          'message',
          contains('Google gagal'),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthInitial] on logout',
      build: buildBloc,
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      setUp: () {
        when(() => repository.signOut()).thenAnswer((_) async {});
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthInitial>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthForgotPasswordSent] on reset email',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(AuthForgotPasswordRequested(email: 'a@b.c')),
      setUp: () {
        when(() => repository.resetPasswordForEmail(any()))
            .thenAnswer((_) async {});
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthForgotPasswordSent>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when reset email throws',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(AuthForgotPasswordRequested(email: 'a@b.c')),
      setUp: () {
        when(() => repository.resetPasswordForEmail(any()))
            .thenThrow(Exception('bad email'));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>(),
      ],
    );
  });
}
