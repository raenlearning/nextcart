import 'dart:math';
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

  double get _rating {
    final r = Random(widget.product.id.hashCode);
    return double.parse((4.0 + r.nextDouble()).toStringAsFixed(1));
  }

  (int, double) get _discountAndOriginal {
    final r = Random(widget.product.id.hashCode);
    final pct = 10 + r.nextInt(21);
    return (pct, widget.product.price / (1 - pct / 100));
  }

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
    final (discountPct, originalPrice) = _discountAndOriginal;

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
                  _RatingRow(rating: _rating),
                  const SizedBox(height: 8),

                  // Price + Cart button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 0,
                          children: [
                            Text(
                              CurrencyFormatter.rupiah(widget.product.price),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: colors.textPrimary,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.rupiah(originalPrice),
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.textHint,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: colors.textHint,
                              ),
                            ),
                          ],
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

class _WishlistButton extends StatefulWidget {
  final Product product;
  const _WishlistButton({required this.product});

  @override
  State<_WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<_WishlistButton> {
  bool _isWishlisted = false;

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final data = await Supabase.instance.client
          .from('wishlist_items')
          .select('id')
          .eq('user_id', userId)
          .eq('product_id', widget.product.id)
          .maybeSingle();
      if (mounted) {
        setState(() => _isWishlisted = data != null);
      }
    } catch (_) {}
  }

  Future<void> _toggleWishlist() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }
    setState(() => _isWishlisted = !_isWishlisted);
    try {
      if (_isWishlisted) {
        await Supabase.instance.client
            .from('wishlist_items')
            .insert({'user_id': userId, 'product_id': widget.product.id});
      } else {
        final existing = await Supabase.instance.client
            .from('wishlist_items')
            .select('id')
            .eq('user_id', userId)
            .eq('product_id', widget.product.id)
            .maybeSingle();
        if (existing != null) {
          await Supabase.instance.client
              .from('wishlist_items')
              .delete()
              .eq('id', existing['id']);
        }
      }
    } catch (_) {
      setState(() => _isWishlisted = !_isWishlisted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: _toggleWishlist,
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
          _isWishlisted ? Icons.favorite : Icons.favorite_border,
          color: _isWishlisted ? AppColors.favorite : colors.textSecondary,
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
