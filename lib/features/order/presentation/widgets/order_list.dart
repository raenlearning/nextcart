import 'package:flutter/material.dart';
import 'package:nextcart/core/constants/app_spacing.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/features/order/presentation/widgets/order_card.dart';
import 'package:nextcart/features/order/presentation/widgets/order_empty_state.dart';

class OrderList extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final String emptyMessage;
  final AppColorScheme colors;
  final Future<void> Function() onRefresh;

  const OrderList({
    super.key,
    required this.orders,
    required this.emptyMessage,
    required this.colors,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return OrderEmptyState(message: emptyMessage, colors: colors);
    }

    final totalItems = orders.fold<int>(
      0,
      (sum, o) => sum + ((o['order_items'] as List?)?.length ?? 0),
    );

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, AppSpacing.bottomNavSpace),
        itemCount: orders.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jumlah Produk',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '($totalItems)',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }
          return OrderCard(order: orders[index - 1], colors: colors);
        },
      ),
    );
  }
}
