import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class PeriodFilterTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const PeriodFilterTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _periods = ['24h', '7d', '30d', '6m', '1y'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: _periods.map((p) {
          final isActive = p == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(70),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  p,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : colors.textSecondary,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}