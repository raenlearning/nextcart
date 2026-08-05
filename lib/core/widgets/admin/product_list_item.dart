import 'package:flutter/material.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class ProductListItem extends StatelessWidget {
  final dynamic product;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ProductListItem({
    super.key,
    required this.product,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = product.isActive == true;
    final bool hasImage = product.images.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.background,
          border: Border(
            bottom: BorderSide(color: context.colors.divider, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            _ProductThumbnail(
              hasImage: hasImage,
              imageUrl: hasImage ? product.images.first : null,
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ActiveBadge(isActive: isActive),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  _PriceStockRow(price: product.price, stock: product.stock),
                ],
              ),
            ),

            // Delete button
            _DeleteButton(onTap: onDelete),
          ],
        ),
      ),
    );
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────────

class _ProductThumbnail extends StatelessWidget {
  final bool hasImage;
  final String? imageUrl;

  const _ProductThumbnail({required this.hasImage, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: context.colors.inputFill,
        border: Border.all(color: AppColors.slate200),
        image: hasImage
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: hasImage
          ? null
          : const Icon(
              Icons.image_outlined,
              color: AppColors.slate300,
              size: 22,
            ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  final bool isActive;
  const _ActiveBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDCFCE7) : AppColors.slate100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.success : AppColors.slate500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Aktif' : 'Tidak Aktif',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF16A34A) : AppColors.slate500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceStockRow extends StatelessWidget {
  final dynamic price;
  final dynamic stock;

  const _PriceStockRow({required this.price, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          CurrencyFormatter.rupiah(price),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: AppColors.slate300,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$stock stocks',
          style: TextStyle(
            fontSize: 12,
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onTap;
  const _DeleteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.error,
          size: 16,
        ),
      ),
    );
  }
}
