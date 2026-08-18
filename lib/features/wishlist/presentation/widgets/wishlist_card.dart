import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class WishlistCard extends StatelessWidget {
  final Map<String, dynamic> wishlistItem;
  final AppColorScheme colors;
  final VoidCallback onMoveToCart;
  final VoidCallback onRemove;

  const WishlistCard({
    super.key,
    required this.wishlistItem,
    required this.colors,
    required this.onMoveToCart,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final product = wishlistItem['products'] as Map<String, dynamic>?;
    if (product == null) return const SizedBox.shrink();

    final images = product['images'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images[0] as String : null;
    final category = product['categories'] as Map<String, dynamic>?;
    final categoryName = category?['name'] as String? ?? '';
    final name = product['name'] as String? ?? 'Produk';
    final price = product['price'];

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (_, _) => Icon(
                        Icons.image_not_supported_outlined,
                        color: colors.textHint,
                        size: 40,
                      ),
                      errorWidget: (_, _, _) => Icon(
                        Icons.image_not_supported_outlined,
                        color: colors.textHint,
                        size: 40,
                      ),
                    )
                  : Icon(
                      Icons.shopping_bag_outlined,
                      color: colors.textHint,
                      size: 40,
                    ),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.rupiah(price),
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.favorite,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onMoveToCart,
                child: Container(
                  width: 25,
                  height: 25,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: colors.textPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: colors.background,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}