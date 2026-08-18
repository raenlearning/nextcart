import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final AppColorScheme colors;
  final bool enabled;

  const StepBtn({
    super.key,
    required this.icon,
    required this.onTap,
    required this.colors,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: enabled ? colors.card : colors.card.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 12,
          color: enabled ? colors.textPrimary : colors.textHint,
        ),
      ),
    );
  }
}
