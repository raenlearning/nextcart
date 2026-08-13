import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nextcart/core/router/app_router.dart';
import 'package:nextcart/data/repository/notification_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushService {
  PushService._();

  static final PushService instance = PushService._();
  final NotificationRepository _repository = NotificationRepository();
  
  final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

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

    FirebaseMessaging.onMessage.listen(_showForegroundMessage);

  
    FirebaseMessaging.onMessageOpenedApp.listen((message) =>
        _handleOpenMessage(message.data));

    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      _handleOpenMessage(initial.data);
    }

    messaging.onTokenRefresh.listen((_) => registerToken());
  }

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

  void _showForegroundMessage(RemoteMessage message) {
    final messenger = messengerKey.currentState;
    final title = message.notification?.title ?? 'Notifikasi';
    final body = message.notification?.body ?? '';
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$title\n$body',
              maxLines: 2, overflow: TextOverflow.ellipsis),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Lihat',
            onPressed: () => _handleOpenMessage(message.data),
          ),
        ),
      );
  }

  void _handleOpenMessage(Map<String, dynamic> data) {
    final orderId = data['order_id'] as String?;
    if (orderId != null && orderId.isNotEmpty) {
      _openOrder(orderId);
    } else {
      _navigateToInbox();
    }
  }

  Future<void> _openOrder(String orderId) async {
    final router = AppRouter.router;
    try {
      final order = await _repository.fetchOrder(orderId);
      if (order != null) {
        router.push('/order-detail', extra: order);
      } else {
        router.go('/notifications');
      }
    } catch (e) {
      debugPrint('Buka order dari notifikasi gagal: $e');
      router.go('/notifications');
    }
  }

  void _navigateToInbox() {
    final router = AppRouter.router;
    try {
      router.go('/notifications');
    } catch (e) {
      debugPrint('Navigasi notifikasi gagal: $e');
    }
  }
}
