import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nextcart/core/helper/toast_helper.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/data/repository/notification_repository.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  final NotificationRepository _repository = NotificationRepository();
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _repository.fetchNotifications();
      if (mounted) setState(() => _notifications = data);
    } catch (e) {
      if (mounted) setState(() => _error = 'Gagal memuat notifikasi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllRead() async {
    try {
      await _repository.markAllRead();
      await _load();
    } catch (e) {
      if (mounted) {
        ToastHelper.showToast(context, 'Gagal menandai dibaca: $e', ToastSeverity.error);
      }
    }
  }

  Future<void> _open(AppNotification notification) async {
    if (!notification.isRead) {
      await _repository.markAsRead(notification.id);
      _load();
    }
    final orderId = notification.data?['order_id']?.toString();
    if (orderId != null) {
      final order = await _repository.fetchOrder(orderId);
      if (order != null && mounted) {
        context.push('/order-detail', extra: order);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Notifikasi',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _notifications.isEmpty ? null : _markAllRead,
            child: const Text('Tandai dibaca'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2))
          : _error != null
              ? Center(
                  child: Text(_error!,
                      style: TextStyle(color: colors.textSecondary)))
              : _notifications.isEmpty
                  ? _EmptyState(colors: colors)
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _load,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) => _NotificationCard(
                          notification: _notifications[index],
                          onTap: () => _open(_notifications[index]),
                        ),
                      ),
                    ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  IconData _iconFor(String type) {
    switch (type) {
      case 'order':
        return Icons.local_shipping_outlined;
      case 'promo':
        return Icons.local_offer_outlined;
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'shop':
        return Icons.storefront_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead ? colors.border : AppColors.primary,
            width: notification.isRead ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconFor(notification.type),
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (notification.body != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.body!,
                      style: TextStyle(
                          color: colors.textSecondary, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('d MMM yyyy, HH:mm', 'id_ID')
                        .format(notification.createdAt),
                    style: TextStyle(color: colors.textHint, fontSize: 10.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppColorScheme colors;
  const _EmptyState({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 56, color: colors.textHint),
          const SizedBox(height: 16),
          Text(
            'Belum ada notifikasi',
            style: TextStyle(
              color: colors.textHint,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}