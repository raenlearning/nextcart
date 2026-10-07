import 'package:flutter/material.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/features/order/presentation/widgets/timeline_item.dart';

class OrderTimeline extends StatelessWidget {
  final String currentStatus;

  const OrderTimeline({super.key, required this.currentStatus});

  static const _steps = [
    OrderStatus.waitingPayment,
    OrderStatus.processing,
    OrderStatus.delivered,
    OrderStatus.completed,
  ];

  int get _currentIndex {
    final idx = _steps.indexOf(currentStatus);
    return idx >= 0 ? idx : 0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Pesanan',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _steps.length; i++) ...[
            TimelineItem(
              step: _steps[i],
              isDone: i < _currentIndex,
              isCurrent: i == _currentIndex,
              isFirst: i == 0,
              isLast: i == _steps.length - 1,
            ),
            if (i != _steps.length - 1) const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}
