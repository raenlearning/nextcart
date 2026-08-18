import 'package:flutter/material.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/features/order/courier_tracking_page.dart';

class OrderActionButton extends StatelessWidget {
  final String status;
  final Map<String, dynamic> order;
  final AppColorScheme colors;

  const OrderActionButton({
    super.key,
    required this.status,
    required this.order,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final (label, enabled, outlineColor) = _actionFor(status);

    return GestureDetector(
      onTap: enabled
          ? () => _handleTap(context, status, label)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: enabled
              ? (outlineColor == null ? colors.textPrimary : Colors.transparent)
              : colors.inputFill,
          borderRadius: BorderRadius.circular(24),
          border: outlineColor != null
              ? Border.all(color: outlineColor, width: 1.4)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: !enabled
                ? colors.textHint
                : (outlineColor ?? colors.background),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  (String, bool, Color?) _actionFor(String status) {
    switch (status) {
      case OrderStatus.waitingPayment:
        return ('Bayar', true, AppColors.warning);
      case OrderStatus.processing:
      case OrderStatus.delivered:
        return ('Lacak', true, null);
      case OrderStatus.completed:
        return ('Beli Lagi', true, null);
      case OrderStatus.cancelled:
        return ('Dibatalkan', false, null);
      default:
        return ('Detail', true, null);
    }
  }

  void _handleTap(BuildContext context, String status, String label) {
    if (status == OrderStatus.processing || status == OrderStatus.delivered) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourierTrackingPage(
            orderId: order['id'].toString(),
            destinationAddress: order['shipping_address'] ?? '-',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fitur "$label" segera hadir')),
      );
    }
  }
}
