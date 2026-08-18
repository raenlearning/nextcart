import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;

  const RatingStars({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        ...List.generate(5, (index) {
          if (index < rating.floor()) {
            return const Icon(
              Icons.star_rounded,
              color: AppColors.rating,
              size: 14,
            );
          } else if (index < rating && (rating - index) >= 0.3) {
            return const Icon(
              Icons.star_half_rounded,
              color: AppColors.rating,
              size: 14,
            );
          } else {
            return Icon(
              Icons.star_border_rounded,
              color: colors.textHint,
              size: 14,
            );
          }
        }),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12,
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}