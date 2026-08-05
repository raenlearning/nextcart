import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/data/models/product_model.dart';
import 'package:nextcart/features/product/presentation/widgets/meta_row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/image_hero.dart';
import 'widgets/name_row.dart';
import 'widgets/description.dart';
import 'widgets/expandable_section_row.dart';
import 'widgets/detail_top_bar.dart';
import 'widgets/bottom_bar.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final PageController _pageController = PageController();
  final SupabaseClient _supabase = Supabase.instance.client;
  final GlobalKey _addToCartKey = GlobalKey();
  bool _isWishlisted = false;
  bool _isWishlistLoading = false;
  String? _wishlistItemId;

  double _rating = 0;
  int _reviewCount = 0;
  bool _isMetaLoading = true;

  late final Map<String, dynamic> _meta = () {
    final r = Random(widget.product.id.hashCode);
    final pct = 10 + r.nextInt(21);
    return {
      'discountPercent': pct,
      'originalPrice': widget.product.price / (1 - pct / 100),
      'suggestedPercent': 70 + r.nextInt(26),
      'activeUsers': 5000 + r.nextInt(60000),
    };
  }();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkWishlistStatus() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final data = await _supabase
          .from('wishlist_items')
          .select('id')
          .eq('user_id', userId)
          .eq('product_id', widget.product.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _isWishlisted = data != null;
          _wishlistItemId = data?['id'];
        });
      }
    } catch (e) {
      debugPrint('Gagal cek status wishlist: $e');
    }
  }

  Future<void> _toggleWishlist() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    if (_isWishlistLoading) return;
    setState(() => _isWishlistLoading = true);

    final wasWishlisted = _isWishlisted;
    setState(() => _isWishlisted = !wasWishlisted);

    try {
      if (wasWishlisted) {
        if (_wishlistItemId != null) {
          await _supabase
              .from('wishlist_items')
              .delete()
              .eq('id', _wishlistItemId!);
          _wishlistItemId = null;
        }
      } else {
        final inserted = await _supabase
            .from('wishlist_items')
            .insert({'user_id': userId, 'product_id': widget.product.id})
            .select('id')
            .single();

        _wishlistItemId = inserted['id'];
      }
    } catch (e) {
      setState(() => _isWishlisted = wasWishlisted);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasWishlisted
                  ? 'Gagal menghapus dari wishlist'
                  : 'Gagal menambahkan ke wishlist',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isWishlistLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
    _fetchRating();
  }

  Future<void> _fetchRating() async {
    try {
      final data = await _supabase
          .from('products')
          .select('total_rating, rating_count')
          .eq('id', widget.product.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _rating = (data?['total_rating'] as num?)?.toDouble() ?? 0;
          _reviewCount = (data?['rating_count'] as num?)?.toInt() ?? 0;
          _isMetaLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isMetaLoading = false);
    }
  }

  Future<void> _openReviews() async {
    await context.push('/review-list', extra: widget.product.id);
    _fetchRating();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;
    final size = MediaQuery.of(context).size;

    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            DetailTopBar(colors: colors),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageHero(
                      product: widget.product,
                      pageController: _pageController,
                      height: size.height * 0.45,
                      isDark: isDark,
                      colors: colors,
                    ),

                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NameRow(
                            name: widget.product.name,
                            isWishlisted: _isWishlisted,
                            colors: colors,
                            isDark: isDark,
                            onWishlistTap: _toggleWishlist,
                          ),
                          const SizedBox(height: 10),

                           RatingSuggestionRow(
                             rating: _isMetaLoading
                                 ? '--'
                                 : (_rating > 0 ? _rating.toStringAsFixed(1) : '0.0'),
                             reviewCount: _isMetaLoading ? 0 : _reviewCount,
                             suggestedPercent: _meta['suggestedPercent'] as int,
                             activeUsers: _meta['activeUsers'] as int,
                             colors: colors,
                           ),
                          const SizedBox(height: 24),

                          Description(
                            description: widget.product.description,
                            colors: colors,
                          ),
                          const SizedBox(height: 20),

                          ExpandableSectionRow(
                            icon: Icons.description_outlined,
                            label: 'Spesifikasi Produk',
                            colors: colors,
                            onTap: () {},
                          ),
                          const SizedBox(height: 10),
                          ExpandableSectionRow(
                            icon: Icons.reviews_outlined,
                            label: 'Ulasan Produk',
                            colors: colors,
                            onTap: _openReviews,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            BottomBar(
              price: widget.product.price,
              originalPrice: _meta['originalPrice'] as double,
              discountPercent: _meta['discountPercent'] as int,
              colors: colors,
              isDark: isDark,
              product: widget.product,
              addToCartKey: _addToCartKey,
            ),
          ],
        ),
      ),
    );
  }
}