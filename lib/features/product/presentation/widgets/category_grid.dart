import 'package:flutter/material.dart';
import 'package:nextcart/core/constants/app_assets.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/features/product/presentation/widgets/category_chip.dart';

class CategoryGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String? selectedCategoryId;
  final bool isLoading;
  final ValueChanged<String?> onCategoryTap;

  const CategoryGrid({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.isLoading,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
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

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return CategoryChip(
              label: 'Semua',
              imageAsset: null,
              isSelected: selectedCategoryId == null,
              onTap: () => onCategoryTap(null),
            );
          }
          final category = categories[index - 1];
          final categoryId = category['id'] as String;
          final categoryName = category['name'] as String;

          return CategoryChip(
            label: categoryName,
            imageAsset: _getImageAsset(categoryName),
            isSelected: selectedCategoryId == categoryId,
            onTap: () => onCategoryTap(categoryId),
          );
        },
      ),
    );
  }

  String? _getImageAsset(String categoryName) {
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
