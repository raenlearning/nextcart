import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nextcart/core/helper/cart_alert_helper.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/theme/app_fonts.dart';
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

    context
        .read<CartBloc>()
        .add(AddToCart(product.id, quantity: quantity));

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_outOfStock && product.stock <= 5) ...[
            Text(
              'Stok menipis, tersisa ${product.stock}',
              style: const TextStyle(
                fontFamily: AppFonts.secondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.warning,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 4),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      CurrencyFormatter.rupiah(price * quantity),
                      style: TextStyle(
                        fontFamily: AppFonts.secondary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (quantity > 1) ...[
                      const SizedBox(height: 2),
                      Text(
                        '($quantity x ${CurrencyFormatter.rupiah(price)})',
                        style: TextStyle(
                          fontFamily: AppFonts.secondary,
                          fontSize: 11,
                          color: colors.textHint,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              if (_outOfStock)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
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
              else ...[
                _CartButton(
                  key: addToCartKey,
                  colors: colors,
                  isDark: isDark,
                  quantity: quantity,
                  onTap: () => _addToCart(context),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  final AppColorScheme colors;
  final bool isDark;
  final int quantity;
  final VoidCallback onTap;

  const _CartButton({
    super.key,
    required this.colors,
    required this.isDark,
    required this.quantity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(
              FontAwesomeIcons.bagShopping,
              color: Colors.white,
              size: 20,
            ),

            const SizedBox(width: 8),
            Text(
              quantity > 1 ? 'Keranjang ($quantity)' : 'Keranjang',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
