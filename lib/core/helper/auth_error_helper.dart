import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

const String _networkMessage =
    'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.';
const String _genericMessage = 'Terjadi kesalahan. Silakan coba lagi.';

String mapAuthErrorMessage(Object error) {
  if (error is AuthRetryableFetchException) {
    return _networkMessage;
  }
  if (error is AuthWeakPasswordException) {
    return 'Password terlalu lemah. Gunakan minimal 8 karakter dengan kombinasi huruf dan angka.';
  }
  if (error is AuthApiException) {
    final mapped = _mapCode(error.code);
    if (mapped != null) return mapped;
    debugPrint('Unmapped auth error: $error');
    return _genericMessage;
  }
  if (error is SocketException ||
      error is TimeoutException ||
      error is http.ClientException) {
    return _networkMessage;
  }
  return _genericMessage;
}

String? _mapCode(String? code) {
  switch (code) {
    case 'invalid_credentials':
      return 'Email atau password salah.';
    case 'email_not_confirmed':
      return 'Email belum diverifikasi. Periksa kotak masuk Anda untuk tautan konfirmasi.';
    case 'user_already_exists':
    case 'email_exists':
      return 'Email sudah terdaftar. Silakan masuk atau gunakan email lain.';
    case 'weak_password':
      return 'Password terlalu lemah. Gunakan minimal 8 karakter dengan kombinasi huruf dan angka.';
    case 'over_email_send_rate_limit':
    case 'over_request_rate_limit':
      return 'Terlalu banyak permintaan. Tunggu beberapa saat lalu coba lagi.';
    case 'email_address_invalid':
    case 'validation_failed':
      return 'Format email tidak valid.';
    case 'signup_disabled':
      return 'Pendaftaran sedang ditutup. Silakan coba lagi nanti.';
    case 'same_password':
      return 'Kata sandi baru tidak boleh sama dengan sebelumnya.';
    case 'invalid_jwt':
    case 'reauthentication_needed':
      return 'Sesi kedaluwarsa. Silakan masuk kembali.';
    case 'provider_disabled':
      return 'Login dengan Google sedang dinonaktifkan.';
    default:
      return null;
  }
}