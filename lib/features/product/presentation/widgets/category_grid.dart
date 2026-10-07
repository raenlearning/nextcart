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
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 5),
              child: CategoryChip(
                label: 'Semua',
                imageAsset: null,
                isSelected: selectedCategoryId == null,
                onTap: () => onCategoryTap(null),
              ),
            );
          }
                  final category = categories[index - 1];
                  final categoryId = (category['id'] ?? '').toString();
                  final categoryName = (category['name'] ?? '').toString();

          return Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 5),
            child: CategoryChip(
              label: categoryName,
              imageAsset: _resolveImage(category, categoryName),
              isSelected: selectedCategoryId == categoryId,
              onTap: () => onCategoryTap(categoryId),
            ),
          );
        },
      ),
    );
  }

  String? _resolveImage(Map<String, dynamic> category, String categoryName) {
    String? image = category['image_url']?.toString();
    if (image == null || image.isEmpty) {
      final products = category['products'] as List?;
      if (products != null && products.isNotEmpty) {
        final img = (products.first as Map<String, dynamic>)['images'];
        if (img is List && img.isNotEmpty) {
          image = img.first?.toString();
        } else if (img != null) {
          image = img.toString();
        }
      }
    }
    if (image == null || image.isEmpty) image = _getImageAsset(categoryName);
    return (image == null || image.isEmpty) ? null : image;
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
      case 'tv':
      case 'televisi':
        return AppAssets.categoryTelevision;
      case 'camera':
      case 'kamera':
        return AppAssets.categoryCamera;
      case 'other':
      case 'others':
      case 'lainnya':
        return AppAssets.categoryOther;
      default:
        return null;
    }
  }
}
