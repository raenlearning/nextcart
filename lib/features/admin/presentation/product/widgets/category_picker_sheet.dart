import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/constants/app_assets.dart';

class CategoryPickerSheet extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String? selectedId;

  const CategoryPickerSheet({
    super.key,
    required this.categories,
    required this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pilih Kategori',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final id = (cat['id'] ?? '').toString();
                  final name = (cat['name'] ?? '').toString();
                  final isSelected = selectedId == id;

                  String? image = cat['image_url']?.toString();
                  if (image == null || image.isEmpty) {
                    final products = cat['products'] as List?;
                    if (products != null && products.isNotEmpty) {
                      final img =
                          (products.first as Map<String, dynamic>)['images'];
                      if (img is List && img.isNotEmpty) {
                        image = img.first?.toString();
                      } else if (img != null) {
                        image = img.toString();
                      }
                    }
                  }
                  if (image == null || image.isEmpty) {
                    image = _categoryAsset(name);
                  }

                  return ListTile(
                    onTap: () {
                      Navigator.pop(context, id);
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      backgroundImage: image != null && image.isNotEmpty
                          ? (image.startsWith('http')
                              ? CachedNetworkImageProvider(image)
                              : AssetImage(image))
                          : null,
                      child: image == null
                          ? const Icon(
                              Icons.category_outlined,
                              size: 16,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? AppColors.primary
                            : context.colors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.primary,
                            size: 18,
                          )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _categoryAsset(String categoryName) {
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