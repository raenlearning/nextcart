import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final String? svgAsset;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.svgAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final asset = svgAsset;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppColors.primary
                  : (context.isDark
                        ? colors.inputFill
                        : const Color(0xFFF3EAE6)),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : colors.border.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Center(
              child: asset != null
                  ? SvgPicture.asset(
                      asset,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        isSelected ? Colors.white : colors.textPrimary,
                        BlendMode.srcIn,
                      ),
                    )
                  : Icon(
                      label == 'Semua'
                          ? Icons.apps_rounded
                          : Icons.devices_other_rounded,
                      size: 22,
                      color: isSelected ? Colors.white : colors.textPrimary,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? AppColors.primary : colors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}