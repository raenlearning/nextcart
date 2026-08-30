import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nextcart/core/helper/cart_alert_helper.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/theme/app_fonts.dart';
import 'package:nextcart/core/widgets/cart_fly_animation.dart';
import 'package:nextcart/data/models/product_model.dart';
import 'package:nextcart/features/cart/bloc/cart_bloc.dart';

class BottomBar extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final AppColorScheme colors;
  final Product product;
  final GlobalKey addToCartKey;

  const BottomBar({
    super.key,
    required this.quantity,
    required this.onQuantityChanged,
    required this.colors,
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
            color: Colors.black.withAlpha(15),
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
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: AppColors.warning,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              _QuantityPill(
                quantity: quantity,
                colors: colors,
                outOfStock: _outOfStock,
                maxStock: product.stock,
                onDecrement: quantity > 1
                    ? () => onQuantityChanged(quantity - 1)
                    : null,
                onIncrement: !_outOfStock && quantity < product.stock
                    ? () => onQuantityChanged(quantity + 1)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AddToCartButton(
                  colors: colors,
                  outOfStock: _outOfStock,
                  onTap: () => _addToCart(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityPill extends StatelessWidget {
  final int quantity;
  final AppColorScheme colors;
  final bool outOfStock;
  final int maxStock;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const _QuantityPill({
    required this.quantity,
    required this.colors,
    required this.outOfStock,
    required this.maxStock,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colors.border, width: 1.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepIcon(
            icon: Icons.remove_rounded,
            colors: colors,
            enabled: onDecrement != null,
            onTap: onDecrement,
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.secondary,
                color: outOfStock ? colors.textHint : colors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          _StepIcon(
            icon: Icons.add_rounded,
            colors: colors,
            enabled: onIncrement != null,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  final IconData icon;
  final AppColorScheme colors;
  final bool enabled;
  final VoidCallback? onTap;

  const _StepIcon({
    required this.icon,
    required this.colors,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled
          ? () {
              HapticFeedback.selectionClick();
              onTap!();
            }
          : null,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(
          icon,
          size: 20,
          color: enabled ? colors.textPrimary : colors.textHint,
        ),
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  final AppColorScheme colors;
  final bool outOfStock;
  final VoidCallback onTap;

  const _AddToCartButton({
    required this.colors,
    required this.outOfStock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: outOfStock ? null : onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: outOfStock ? colors.inputFill : AppColors.primary,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.cartPlus,
              size: 20,
              color: Colors.white,
            ),

            SizedBox(width: 4),

            Text(
              outOfStock ? 'Stok Habis' : ' Keranjang',
              style: TextStyle(
                color: outOfStock ? colors.textHint : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
