import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final int score;
  final bool hasText;

  const PasswordStrengthIndicator({
    super.key,
    required this.score,
    required this.hasText,
  });

  static const _labels = ['Lemah', 'Cukup', 'Baik', 'Kuat'];
  static const _colors = [
    AppColors.error,
    AppColors.warning,
    AppColors.info,
    AppColors.success,
  ];

  @override
  Widget build(BuildContext context) {
    final clamped = score.clamp(1, 4) - 1;

    return AnimatedOpacity(
      opacity: hasText ? 1 : 0.3,
      duration: const Duration(milliseconds: 200),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(4, (i) {
                final active = i < score;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 4,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: active
                          ? _colors[clamped]
                          : AppColors.slate200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            hasText ? _labels[clamped] : 'Keamanan password',
            style: TextStyle(
              fontSize: 12,
              color: hasText
                  ? _colors[clamped]
                  : context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
