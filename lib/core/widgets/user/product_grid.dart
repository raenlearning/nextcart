import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
import 'package:nextcart/core/helper/toast_helper.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/widgets/cart_fly_animation.dart';
import 'package:nextcart/data/models/product_model.dart';
import 'package:nextcart/features/cart/bloc/cart_bloc.dart';
import 'package:nextcart/features/wishlist/bloc/wishlist_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeProductGrid extends StatelessWidget {
  final List<Product> products;

  const HomeProductGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.66,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => ProductCard(product: products[index]),
    );
  }
}

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

    ToastHelper.showTopToast(context, '${widget.product.name} berhasil ditambahkan ke keranjang!');
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
            // ── Image area
            Expanded(
              child: Stack(
                children: [
                  _ProductImage(imageUrl: imageUrl),
                  if (widget.product.stock <= 5)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _LowStockBadge(),
                    ),
                  Positioned(top: 8, right: 8, child: _WishlistButton(product: widget.product)),
                ],
              ),
            ),

            // ── Info area
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
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
                   const SizedBox(height: 5),

                   // Rating
                   if (widget.product.totalRating > 0)
                     _RatingRow(rating: widget.product.totalRating),
                   if (widget.product.totalRating > 0)
                     const SizedBox(height: 8),

                   // Price + Cart button
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
                       _AddToCartButton(
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

class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  const _ProductImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      // Memberikan batas tinggi yang pasti agar semua gambar di grid berukuran seragam
      height: 140,
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      padding: const EdgeInsets.all(12),
      // Memastikan gambar berada di tengah dan diskalakan secara proporsional
      child: Center(
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colors.textHint,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.broken_image_outlined,
                  size: 36,
                  color: colors.textHint,
                ),
              )
            : Icon(Icons.image_not_supported, size: 40, color: colors.textHint),
      ),
    );
  }
}

class _LowStockBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, color: AppColors.rating, size: 11),
          SizedBox(width: 3),
          Text(
            'Stok Menipis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistButton extends StatelessWidget {
  final Product product;
  const _WishlistButton({required this.product});

  void _toggleWishlist(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }
    context.read<WishlistBloc>().add(WishlistToggle(product.id));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isWishlisted =
        context.watch<WishlistBloc>().contains(product.id);

    return GestureDetector(
      onTap: () => _toggleWishlist(context),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: colors.card,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isWishlisted ? Icons.favorite : Icons.favorite_border,
          color: isWishlisted ? AppColors.favorite : colors.textSecondary,
          size: 16,
        ),
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddToCartButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.electricBlue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.electricBlue.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.shopping_cart_outlined,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final double rating;

  const _RatingRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        ...List.generate(5, (index) {
          if (index < rating.floor()) {
            return const Icon(
              Icons.star_rounded,
              color: AppColors.rating,
              size: 14,
            );
          } else if (index < rating && (rating - index) >= 0.3) {
            return const Icon(
              Icons.star_half_rounded,
              color: AppColors.rating,
              size: 14,
            );
          } else {
            return Icon(
              Icons.star_border_rounded,
              color: colors.textHint,
              size: 14,
            );
          }
        }),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12,
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
