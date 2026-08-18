import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
import 'package:nextcart/core/helper/toast_helper.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/widgets/cart_fly_animation.dart';
import 'package:nextcart/core/widgets/user/product/add_to_cart_button.dart';
import 'package:nextcart/core/widgets/user/product/low_stock_badge.dart';
import 'package:nextcart/core/widgets/user/product/product_image.dart';
import 'package:nextcart/core/widgets/user/product/rating_stars.dart';
import 'package:nextcart/core/widgets/user/product/wishlist_button.dart';
import 'package:nextcart/data/models/product_model.dart';
import 'package:nextcart/features/cart/bloc/cart_bloc.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final GlobalKey _cartButtonKey = GlobalKey();

  void _onAddToCart() {
    HapticFeedback.lightImpact();

    context.read<CartBloc>().add(AddToCart(widget.product.id));

    CartFlyAnimation.fly(
      context: context,
      startKey: _cartButtonKey,
      icon: Icons.shopping_bag,
      color: Colors.white,
      backgroundColor: AppColors.electricBlue,
    );

    ToastHelper.showTopToast(
      context,
      '${widget.product.name} berhasil ditambahkan ke keranjang!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;
    final imageUrl = widget.product.images.isNotEmpty
        ? widget.product.images.first
        : null;

    return GestureDetector(
      onTap: () => context.push('/product-detail', extra: widget.product),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(18),
          border: isDark ? Border.all(color: colors.border) : null,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area (full-bleed)
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(imageUrl: imageUrl),
                  if (widget.product.stock <= 5)
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: LowStockBadge(),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: WishlistButton(product: widget.product),
                  ),
                ],
              ),
            ),

            // ── Info area
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (widget.product.totalRating > 0) ...[
                    const SizedBox(height: 5),
                    RatingStars(rating: widget.product.totalRating),
                  ],
                  const SizedBox(height: 8),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          CurrencyFormatter.rupiah(widget.product.price),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      AddToCartButton(
                        key: _cartButtonKey,
                        onTap: _onAddToCart,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}