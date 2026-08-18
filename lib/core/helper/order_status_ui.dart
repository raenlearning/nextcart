import 'package:flutter/material.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/theme/app_colors.dart';

extension OrderStatusUi on String {
  String get statusLabel {
    switch (this) {
      case OrderStatus.waitingPayment:
        return 'Menunggu Bayar';
      case OrderStatus.processing:
        return 'Diproses';
      case OrderStatus.delivered:
        return 'Dikirim';
      case OrderStatus.completed:
        return 'Selesai';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
      default:
        return replaceAll('_', ' ').toUpperCase();
    }
  }

  Color get statusColor {
    switch (this) {
      case OrderStatus.waitingPayment:
        return AppColors.warning;
      case OrderStatus.processing:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.info;
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
      default:
        return AppColors.slate500;
    }
  }

  IconData get statusIcon {
    switch (this) {
      case OrderStatus.waitingPayment:
        return Icons.hourglass_empty_rounded;
      case OrderStatus.processing:
        return Icons.local_shipping_rounded;
      case OrderStatus.delivered:
        return Icons.inventory_2_rounded;
      case OrderStatus.completed:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  /// Status yang masih bisa diubah oleh admin.
  bool get isActionable =>
      this != OrderStatus.waitingPayment && this != OrderStatus.cancelled;
}
