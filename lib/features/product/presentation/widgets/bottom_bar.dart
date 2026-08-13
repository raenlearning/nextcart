import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcart/core/helper/cart_alert_helper.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/widgets/cart_fly_animation.dart';
import 'package:nextcart/data/models/product_model.dart';
import 'package:nextcart/features/cart/bloc/cart_bloc.dart';

class BottomBar extends StatelessWidget {
  final double price;
  final int quantity;
  final AppColorScheme colors;
  final bool isDark;
  final Product product;
  final GlobalKey addToCartKey;

  const BottomBar({
    super.key,
    required this.price,
    required this.quantity,
    required this.colors,
    required this.isDark,
    required this.product,
    required this.addToCartKey,
  });

  bool get _outOfStock => product.stock <= 0;

  void _addToCart(BuildContext context) {
    HapticFeedback.lightImpact();

    context.read<CartBloc>().add(AddToCart(product.id));

    CartFlyAnimation.fly(
      context: context,
      startKey: addToCartKey,
      icon: Icons.shopping_bag,
      color: Colors.white,
      backgroundColor: AppColors.primary,
    );

    final imageUrl = product.images.isNotEmpty ? product.images.first : null;
    CartAlertHelper.showSuccessBottomSheet(
      context: context,
      productName: product.name,
      imageUrl: imageUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 15),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_outOfStock && product.stock <= 5) ...[
                  Text(
                    'Stok menipis, tersisa ${product.stock}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Row(
                  children: [
                    Text(
                      CurrencyFormatter.rupiah(price),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          if (_outOfStock)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: colors.textHint.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Stok Habis',
                style: TextStyle(
                  color: colors.textHint,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            GestureDetector(
              key: addToCartKey,
              onTap: () => _addToCart(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.textPrimary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      color: colors.background,
                      size: 20,
                    ),

                    SizedBox(width: 5),

                    Text(
                      quantity > 1
                          ? 'Tambah $quantity ke keranjang'
                          : 'Tambah ke keranjang',
                      style: TextStyle(
                        color: colors.background,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
