import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class OrderStatusChart extends StatelessWidget {
  final Map<String, int> statusBreakdown;

  const OrderStatusChart({super.key, required this.statusBreakdown});

  static const _colors = {
    'pending': AppColors.warning,
    'processing': AppColors.info,
    'delivered': AppColors.secondary,
    'completed': AppColors.success,
    'cancelled': AppColors.error,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = statusBreakdown.values.fold(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withAlpha(8),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.donut_large_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'Status Pesanan',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: colors.textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (total == 0)
            Center(
              child: Text(
                'Belum ada pesanan.',
                style: TextStyle(color: colors.textSecondary),
              ),
            )
          else
            ...statusBreakdown.entries.map((e) {
              final pct = e.value / total;
              final color = _colors[e.key] ?? AppColors.slate300;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withAlpha(90),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 9),
                        Text(
                          _capitalize(e.key),
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${e.value}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${(pct * 100).toStringAsFixed(0)}%)',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: colors.inputFill,
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 7,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}