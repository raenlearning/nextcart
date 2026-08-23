import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return InkWell(
      onTap: enabled
          ? () {
              HapticFeedback.selectionClick();
              onTap();
            }
          : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? colors.card : colors.card.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? colors.textPrimary : colors.textHint,
        ),
      ),
    );
  }
}
