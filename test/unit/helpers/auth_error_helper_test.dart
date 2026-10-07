import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nextcart/core/helper/auth_error_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('mapAuthErrorMessage', () {
    test('maps invalid_credentials', () {
      final e = AuthApiException(
        'Invalid login credentials',
        statusCode: '400',
        code: 'invalid_credentials',
      );
      expect(mapAuthErrorMessage(e), 'Email atau password salah.');
    });

    test('maps email_not_confirmed', () {
      final e = AuthApiException(
        'Email not confirmed',
        statusCode: '400',
        code: 'email_not_confirmed',
      );
      expect(
        mapAuthErrorMessage(e),
        'Email belum diverifikasi. Periksa kotak masuk Anda untuk tautan konfirmasi.',
      );
    });

    test('maps user_already_exists', () {
      final e = AuthApiException(
        'User already registered',
        statusCode: '400',
        code: 'user_already_exists',
      );
      expect(
        mapAuthErrorMessage(e),
        'Email sudah terdaftar. Silakan masuk atau gunakan email lain.',
      );
    });

    test('maps weak_password via AuthWeakPasswordException', () {
      final e = AuthWeakPasswordException(
        message: 'Password should be longer than 6 characters.',
        statusCode: '422',
        reasons: const ['length'],
      );
      expect(
        mapAuthErrorMessage(e),
        'Password terlalu lemah. Gunakan minimal 8 karakter dengan kombinasi huruf dan angka.',
      );
    });

    test('maps rate limit', () {
      final e = AuthApiException(
        'For security purposes, you can only request this once after 60 seconds.',
        statusCode: '429',
        code: 'over_email_send_rate_limit',
      );
      expect(
        mapAuthErrorMessage(e),
        'Terlalu banyak permintaan. Tunggu beberapa saat lalu coba lagi.',
      );
    });

    test('maps network retry exception', () {
      final e = AuthRetryableFetchException();
      expect(
        mapAuthErrorMessage(e),
        'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.',
      );
    });

    test('maps SocketException to network message', () {
      expect(
        mapAuthErrorMessage(const SocketException('down')),
        'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.',
      );
    });

    test('falls back to generic for unknown error', () {
      expect(
        mapAuthErrorMessage(Exception('boom')),
        'Terjadi kesalahan. Silakan coba lagi.',
      );
    });

    test('falls back to generic for unmapped code', () {
      final e = AuthApiException(
        'Something else',
        statusCode: '500',
        code: 'unknown_code',
      );
      expect(mapAuthErrorMessage(e), 'Terjadi kesalahan. Silakan coba lagi.');
    });
  });
}