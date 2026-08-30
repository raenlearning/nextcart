import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const HomeSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        if (actionLabel != null && onActionTap != null)
          GestureDetector(
            onTap: onActionTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  Text(
                    actionLabel!,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}