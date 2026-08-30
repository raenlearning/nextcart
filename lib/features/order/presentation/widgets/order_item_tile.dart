import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/theme/app_fonts.dart';

class OrderItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final String status;
  final bool hasReviewed;
  final ValueChanged<String> onReview;

  const OrderItemTile({
    super.key,
    required this.item,
    required this.status,
    required this.hasReviewed,
    required this.onReview,
  });

  String? get _productId {
    final product = item['products'] as Map<String, dynamic>?;
    return product?['id'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final product = item['products'] as Map<String, dynamic>?;
    final images = product?['images'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images[0] as String : null;
    final name = product?['name'] as String? ?? 'Produk Tidak Diketahui';
    final quantity = item['quantity'] as int? ?? 0;
    final priceAtPurchase = item['price_at_purchase'];

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.inputFill,
                  borderRadius: BorderRadius.circular(10),
                  image: imageUrl != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageUrl == null
                    ? Icon(
                        Icons.shopping_bag_outlined,
                        color: colors.textSecondary,
                        size: 22,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$quantity x ${CurrencyFormatter.rupiah(priceAtPurchase)}',
                      style: TextStyle(
                        fontFamily: AppFonts.secondary,
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                CurrencyFormatter.rupiah((priceAtPurchase as num) * quantity),
                style: TextStyle(
                  fontFamily: AppFonts.secondary,
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          if (status == OrderStatus.completed && _productId != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => onReview(_productId!),
                icon: const Icon(Icons.rate_review_outlined, size: 16),
                label: Text(hasReviewed ? 'Lihat Ulasan' : 'Beri Ulasan'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
