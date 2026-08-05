import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:nextcart/core/router/app_router.dart';
import 'package:nextcart/data/repository/notification_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Menangani inisialisasi Firebase Cloud Messaging: mendaftarkan token perangkat,
/// dan navigasi saat notifikasi diklik.
class PushService {
  PushService._();

  static final PushService instance = PushService._();
  final NotificationRepository _repository = NotificationRepository();

  /// Dipanggil sekali saat aplikasi dimulai. Tidak melempar bila Firebase belum
  /// dikonfigurasi, sehingga aplikasi tetap berjalan normal.
  Future<void> init() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase init skipped: $e');
      return;
    }

    final messaging = FirebaseMessaging.instance;

    try {
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('Permission request skipped: $e');
    }

    // Notifikasi yang membuka app dari background/terminated -> halaman Notifikasi
    FirebaseMessaging.onMessageOpenedApp.listen((_) => _navigateToInbox());

    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      _navigateToInbox();
    }
  }

  /// Mendaftarkan token FCM untuk user yang sedang login.
  Future<void> registerToken() async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return;
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _repository.registerPushToken(token);
      }
    } catch (e) {
      debugPrint('Register push token failed: $e');
    }
  }

  /// Menghapus token perangkat milik user saat logout.
  Future<void> deleteToken() async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      final token = await FirebaseMessaging.instance.getToken();
      if (uid != null && token != null) {
        await _repository.deletePushToken(token);
      }
    } catch (e) {
      debugPrint('Delete push token failed: $e');
    }
  }

  void _navigateToInbox() {
    final router = AppRouter.router;
    // Pindah ke halaman notifikasi bila rute tersedia (user dalam status login).
    try {
      router.go('/notifications');
    } catch (e) {
      debugPrint('Navigasi notifikasi gagal: $e');
    }
  }
}