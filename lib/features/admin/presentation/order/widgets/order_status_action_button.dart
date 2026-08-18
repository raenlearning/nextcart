import 'package:flutter/material.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class OrderStatusActionButton extends StatelessWidget {
  final String status;
  final VoidCallback onPressed;

  const OrderStatusActionButton({
    super.key,
    required this.status,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = _actionFor(status);
    final isDisabled =
        status == OrderStatus.waitingPayment || status == OrderStatus.cancelled;

    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? color.withValues(alpha: 0.14) : color,
          foregroundColor: isDisabled ? color : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        icon: Icon(icon, size: 15),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  (String, IconData, Color) _actionFor(String status) {
    switch (status) {
      case OrderStatus.waitingPayment:
        return (
          'Menunggu Bayar',
          Icons.hourglass_empty_rounded,
          AppColors.slate400
        );
      case OrderStatus.processing:
        return ('Proses Kirim', Icons.local_shipping_rounded, AppColors.primary);
      case OrderStatus.delivered:
        return ('Selesaikan', Icons.inventory_2_rounded, AppColors.info);
      case OrderStatus.completed:
        return ('Selesai', Icons.check_circle_rounded, AppColors.success);
      case OrderStatus.cancelled:
        return ('Dibatalkan', Icons.cancel_rounded, AppColors.slate400);
      default:
        return ('Ubah Status', Icons.edit_road_rounded, AppColors.primary);
    }
  }
}