import 'package:google_sign_in/google_sign_in.dart';
import 'package:nextcart/core/helper/auth_error_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  static const String _googleServerClientId =
      '745491795053-ugj2u267vbr0pb5gb1am3n1qiefa155q.apps.googleusercontent.com';

  AuthRepository({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': 'buyer'}, 
      );
      return response;
    } catch (e) {
      throw Exception(mapAuthErrorMessage(e));
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception(mapAuthErrorMessage(e));
    }
  }

  Future<User> signInWithGoogle() async {
    final String idToken;
    final String? accessToken;
    try {
      final googleUser =
          await GoogleSignIn(serverClientId: _googleServerClientId).signIn();
      if (googleUser == null) {
        throw Exception('Login Google dibatalkan.');
      }
      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        throw Exception('Gagal mendapatkan token Google.');
      }
      idToken = googleAuth.idToken!;
      accessToken = googleAuth.accessToken;
    } catch (e) {
      throw Exception('Login Google gagal: $e');
    }

    try {
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      final user = response.user;
      if (user == null) {
        throw Exception('Gagal masuk dengan Google.');
      }
      return user;
    } catch (e) {
      throw Exception(mapAuthErrorMessage(e));
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetPasswordForEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception(mapAuthErrorMessage(e));
    }
  }

}
