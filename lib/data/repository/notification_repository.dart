import 'package:supabase_flutter/supabase_flutter.dart';

class AppNotification {
  final String id;
  final String title;
  final String? body;
  final String type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    this.body,
    this.type = 'general',
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String?,
      type: json['type'] as String? ?? 'general',
      data: (json['data'] as Map?)?.cast<String, dynamic>(),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class NotificationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<AppNotification>> fetchNotifications() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _supabase
        .from('notifications')
        .select('id, title, body, type, data, is_read, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(String id) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id);
  }

  Future<void> markAllRead() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  /// Mendaftarkan token FCM perangkat ke tabel push_tokens (upsert per user+token).
  Future<void> registerPushToken(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || token.isEmpty) return;

    await _supabase.from('push_tokens').upsert({
      'user_id': userId,
      'token': token,
      'platform': 'mobile',
    }, onConflict: 'user_id,token');
  }

  Future<Map<String, dynamic>?> fetchOrder(String orderId) async {
    try {
      return await _supabase
          .from('orders')
          .select('''
            id,
            total_amount,
            status,
            shipping_address,
            created_at,
            discount_amount,
            delivery_fee,
            tax_amount,
            order_items (
              id,
              quantity,
              price_at_purchase,
              products (
                name,
                images
              )
            ),
            payments!payments_order_id_fkey (
              snap_token,
              status,
              method,
              paid_at
            )
          ''')
          .eq('id', orderId)
          .maybeSingle();
    } catch (_) {
      return null;
    }
  }

  /// Menghapus token perangkat tertentu dari tabel push_tokens (saat logout).
  Future<void> deletePushToken(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || token.isEmpty) return;

    await _supabase
        .from('push_tokens')
        .delete()
        .eq('user_id', userId)
        .eq('token', token);
  }
}