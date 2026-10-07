import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class ExpandableSectionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppColorScheme colors;
  final VoidCallback onTap;

  const ExpandableSectionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: colors.textHint),
          ],
        ),
      ),
    );
  }
}