import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/helper/toast_helper.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/features/cart/bloc/cart_bloc.dart';
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
            fontSize: 11.5,
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
        return ('Beli Lagi', true, null);
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
      return;
    }

    if (status == OrderStatus.completed || status == OrderStatus.cancelled) {
      _reorder(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fitur "$label" segera hadir')),
    );
  }

  void _reorder(BuildContext context) {
    final items = (order['order_items'] as List?) ?? const [];
    final bloc = context.read<CartBloc>();

    var added = 0;
    for (final raw in items) {
      final item = Map<String, dynamic>.from(raw as Map);
      final product = item['products'] as Map<String, dynamic>?;
      final productId =
          (product?['id'] ?? item['product_id'])?.toString() ?? '';
      final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
      if (productId.isEmpty) continue;
      bloc.add(AddToCart(productId, quantity: quantity));
      added++;
    }

    ToastHelper.showToast(
      context,
      added > 0
          ? '$added produk ditambahkan ke keranjang'
          : 'Produk sudah tidak tersedia',
      added > 0 ? ToastSeverity.success : ToastSeverity.warning,
    );
  }
}
