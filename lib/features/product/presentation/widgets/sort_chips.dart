import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class SortOption {
  final String id;
  final String label;
  final IconData icon;

  const SortOption(this.id, this.label, this.icon);

  static const newest = SortOption('newest', 'Terbaru', Icons.schedule_rounded);
  static const priceAsc = SortOption('price_asc', 'Termurah', Icons.arrow_upward_rounded);
  static const priceDesc = SortOption('price_desc', 'Termahal', Icons.arrow_downward_rounded);
  static const rating = SortOption('rating', 'Rating', Icons.star_rounded);

  static const all = [newest, priceAsc, priceDesc, rating];
}

class SortChips extends StatelessWidget {
  final String selectedId;
  final ValueChanged<SortOption> onSelected;

  const SortChips({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (final option in SortOption.all) ...[
            _SortChip(
              option: option,
              isSelected: option.id == selectedId,
              colors: colors,
              onTap: () => onSelected(option),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final SortOption option;
  final bool isSelected;
  final AppColorScheme colors;
  final VoidCallback onTap;

  const _SortChip({
    required this.option,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : colors.inputFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : colors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              option.icon,
              size: 14,
              color: isSelected ? Colors.white : colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              option.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}