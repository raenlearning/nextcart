import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final String? imageAsset;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.imageAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAll = label == 'Semua';
    final hasImage = imageAsset != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: imageAsset!.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: imageAsset!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) =>
                              Container(color: AppColors.primary.withValues(alpha: 0.12)),
                          errorWidget: (_, _, _) =>
                              Container(color: AppColors.primary.withValues(alpha: 0.12)),
                        )
                      : Image.asset(
                          imageAsset!,
                          fit: BoxFit.cover,
                        ),
                )
              else
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, Color(0xFF0F766E)],
                    ),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
              if (!hasImage)
                Center(
                  child: FaIcon(
                    isAll
                        ? FontAwesomeIcons.shapes
                        : FontAwesomeIcons.boxOpen,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 9.5,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
