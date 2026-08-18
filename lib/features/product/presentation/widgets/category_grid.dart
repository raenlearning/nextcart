import 'package:flutter/material.dart';
import 'package:nextcart/core/constants/app_assets.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/features/product/presentation/widgets/category_chip.dart';

class CategoryGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String? selectedCategoryId;
  final bool isLoading;
  final bool isExpanded;
  final ValueChanged<String?> onCategoryTap;
  final VoidCallback onToggleExpand;

  const CategoryGrid({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.isLoading,
    required this.isExpanded,
    required this.onCategoryTap,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    final totalItems = categories.length + 1;
    final displayedCount =
        isExpanded ? totalItems : (totalItems > 4 ? 4 : totalItems);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Belanja Sesuai Kategori',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              if (totalItems > 4)
                IconButton(
                  onPressed: onToggleExpand,
                  icon: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayedCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              if (index == 0) {
                return CategoryChip(
                  label: 'Semua',
                  isSelected: selectedCategoryId == null,
                  onTap: () => onCategoryTap(null),
                  svgAsset: null,
                );
              }
              final category = categories[index - 1];
              final categoryId = category['id'] as String;
              final categoryName = category['name'] as String;

              return CategoryChip(
                label: categoryName,
                isSelected: selectedCategoryId == categoryId,
                onTap: () => onCategoryTap(categoryId),
                svgAsset: _getSvgAsset(categoryName),
              );
            },
          ),
        ],
      ),
    );
  }

  String? _getSvgAsset(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'smartphone':
        return AppAssets.categorySmartPhone;
      case 'laptop':
        return AppAssets.categoryLaptop;
      case 'audio':
        return AppAssets.categoryAudio;
      case 'gaming':
        return AppAssets.categoryGaming;
      case 'watch':
        return AppAssets.categoryWatch;
      case 'computer':
        return AppAssets.categoryComputer;
      case 'television':
        return AppAssets.categoryTelevision;
      case 'camera':
        return AppAssets.categoryCamera;
      default:
        return null;
    }
  }
}