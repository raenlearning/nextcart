import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class RatingRow extends StatelessWidget {
  final String rating;
  final int reviewCount;
  final AppColorScheme colors;

  const RatingRow({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.colors,
  });

  String _formatCount(int v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}K';
    return '$v';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, color: AppColors.rating, size: 16),
        const SizedBox(width: 4),
        Text(
          rating,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${_formatCount(reviewCount)} Ulasan',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}
