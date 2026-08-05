import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class ProductFilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const ProductFilterChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withAlpha(15) : context.colors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : context.colors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: active ? AppColors.primary : context.colors.textSecondary,
              ),
            ),

            const SizedBox(width: 4),
            
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: active ? AppColors.primary : context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}