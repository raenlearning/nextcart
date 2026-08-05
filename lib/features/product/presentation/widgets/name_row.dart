import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class NameRow extends StatelessWidget {
  final String name;
  final bool isWishlisted;
  final AppColorScheme colors;
  final bool isDark;
  final VoidCallback onWishlistTap;

  const NameRow({
    super.key,
    required this.name,
    required this.isWishlisted,
    required this.colors,
    required this.isDark,
    required this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onWishlistTap,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: isWishlisted ? 1.1 : 1.0,
            child: Icon(
              isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isWishlisted ? AppColors.favorite : colors.textHint,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }
}