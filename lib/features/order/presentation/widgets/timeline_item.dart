import 'package:flutter/material.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class TimelineItem extends StatelessWidget {
  final String step;
  final bool isDone;
  final bool isCurrent;
  final bool isFirst;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.step,
    required this.isDone,
    required this.isCurrent,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final stepColor = OrderStatus.color(step);
    final color = isDone || isCurrent
        ? stepColor
        : colors.textHint.withValues(alpha: 0.4);
    final topLineColor = isDone || isCurrent ? stepColor : colors.divider;
    final bottomLineColor = isDone ? stepColor : colors.divider;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Column(
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: 6,
                  color: topLineColor,
                ),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent ? color : (isDone ? color : colors.card),
                  border: Border.all(color: color, width: isCurrent ? 5 : 2),
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 6,
                  color: bottomLineColor,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              OrderStatus.label(step),
              style: TextStyle(
                color: isDone || isCurrent
                    ? colors.textPrimary
                    : colors.textHint,
                fontSize: 12.5,
                fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
        if (isCurrent)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Saat ini',
                style: TextStyle(
                  color: color,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
