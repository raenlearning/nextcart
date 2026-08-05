import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class RatingSuggestionRow extends StatelessWidget {
  final String rating;
  final int reviewCount;
  final int suggestedPercent;
  final int activeUsers;
  final AppColorScheme colors;

  const RatingSuggestionRow({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.suggestedPercent,
    required this.activeUsers,
    required this.colors,
  });

  String _formatCount(int v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}K';
    return '$v';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.thumb_up_alt_rounded, color: AppColors.info, size: 14),
            const SizedBox(width: 6),
            Text(
              '$suggestedPercent%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Direkomendasikan oleh ${_formatCount(activeUsers)} pengguna aktif',
                style: TextStyle(fontSize: 11.5, color: colors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}