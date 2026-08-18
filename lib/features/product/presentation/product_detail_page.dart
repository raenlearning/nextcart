import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/data/models/product_model.dart';
import 'package:nextcart/data/repository/product_repository.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
import 'package:nextcart/core/widgets/user/product_grid.dart';
import 'package:nextcart/features/product/presentation/widgets/meta_row.dart';
import 'package:nextcart/features/wishlist/bloc/wishlist_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/image_hero.dart';
import 'widgets/name_row.dart';
import 'widgets/price_row.dart';
import 'widgets/description.dart';
import 'widgets/expandable_section_row.dart';
import 'widgets/detail_top_bar.dart';
import 'widgets/bottom_bar.dart';
import 'widgets/quantity_selector.dart';
import 'widgets/spec_row.dart';

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
  int _quantity = 1;

  double _rating = 0;
  int _reviewCount = 0;
  bool _isMetaLoading = true;
  String? _categoryLabel;

  List<Product> _relatedProducts = [];
  bool _isRelatedLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleWishlist() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }
    context.read<WishlistBloc>().add(WishlistToggle(widget.product.id));
  }

  Future<void> _loadDetail() async {
    // Jalankan fetch rating, kategori, dan produk terkait secara paralel.
    await Future.wait([
      _fetchRating(),
      _fetchCategory(),
      _fetchRelatedProducts(),
    ]);
  }

  Future<void> _fetchRelatedProducts() async {
    try {
      final repo = context.read<ProductRepository>();
      final related = await repo.getProductsByCategory(widget.product.categoryId);
      if (mounted) {
        setState(() {
          _relatedProducts =
              related.where((p) => p.id != widget.product.id).toList();
          _isRelatedLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isRelatedLoading = false);
    }
  }

  Future<void> _fetchCategory() async {
    try {
      final data = await _supabase
          .from('categories')
          .select('name')
          .eq('id', widget.product.categoryId)
          .maybeSingle();
      if (mounted) {
        setState(() => _categoryLabel = data?['name'] as String?);
      }
    } catch (_) {}
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

  void _openSpecs() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final colors = context.colors;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spesifikasi Produk',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                SpecRow(
                  label: 'Nama Produk',
                  value: widget.product.name,
                  colors: colors,
                ),
                SpecRow(
                  label: 'Kategori',
                  value: _categoryLabel ?? '-',
                  colors: colors,
                ),
                SpecRow(
                  label: 'Harga',
                  value: CurrencyFormatter.rupiah(widget.product.price),
                  colors: colors,
                ),
                SpecRow(
                  label: 'Stok',
                  value: '${widget.product.stock}',
                  colors: colors,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _shareProduct() {
    final imageUrl = widget.product.images.isNotEmpty
        ? widget.product.images.first
        : null;
    Clipboard.setData(
      ClipboardData(
        text: '${widget.product.name}\n'
            'Rp ${CurrencyFormatter.rupiah(widget.product.price)}\n'
            '${imageUrl ?? 'Lihat produk di NextCart'}',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link produk disalin ke clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
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
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.1),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30 ,vertical: 10),
                  child: ImageHero(
                    product: widget.product,
                    pageController: _pageController,
                    height: size.height * 0.35,
                    isDark: isDark,
                    colors: colors,
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PriceRow(
                          price: widget.product.price,
                          colors: colors,
                        ),
                        const SizedBox(height: 12),

                        NameRow(
                          name: widget.product.name,
                          isWishlisted: context
                              .watch<WishlistBloc>()
                              .contains(widget.product.id),
                          colors: colors,
                          isDark: isDark,
                          onWishlistTap: _toggleWishlist,
                        ),
                        const SizedBox(height: 10),

                        GestureDetector(
                          onTap: _openReviews,
                          child: RatingRow(
                            rating: _isMetaLoading
                                ? '--'
                                : (_rating > 0
                                    ? _rating.toStringAsFixed(1)
                                    : '0.0'),
                            reviewCount: _isMetaLoading ? 0 : _reviewCount,
                            colors: colors,
                          ),
                        ),

                        const SizedBox(height: 20),
                        Divider(color: colors.divider, height: 1),
                        const SizedBox(height: 20),

                        QuantitySelector(
                          quantity: _quantity,
                          stock: widget.product.stock,
                          colors: colors,
                          onChanged: (value) =>
                              setState(() => _quantity = value),
                        ),
                        const SizedBox(height: 20),

                        Description(
                          description: widget.product.description,
                          colors: colors,
                        ),
                        const SizedBox(height: 20),

                        ExpandableSectionRow(
                          icon: Icons.description_outlined,
                          label: 'Spesifikasi Produk',
                          colors: colors,
                          onTap: _openSpecs,
                        ),
                        const SizedBox(height: 10),
                        ExpandableSectionRow(
                          icon: Icons.reviews_outlined,
                          label: 'Ulasan Produk',
                          colors: colors,
                          onTap: _openReviews,
                        ),

                        const SizedBox(height: 24),
                        _buildRelatedProducts(colors),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: DetailTopBar(colors: colors, onShare: _shareProduct),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(
        price: widget.product.price,
        quantity: _quantity,
        colors: colors,
        isDark: isDark,
        product: widget.product,
        addToCartKey: _addToCartKey,
      ),
    );
  }

  Widget _buildRelatedProducts(AppColorScheme colors) {
    if (_isRelatedLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    if (_relatedProducts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Produk Serupa',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _relatedProducts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 150,
                child: ProductCard(product: _relatedProducts[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}