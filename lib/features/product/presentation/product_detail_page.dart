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
  int _quantity = 1;

  double _rating = 0;
  int _reviewCount = 0;
  bool _isMetaLoading = true;
  String? _categoryLabel;

  List<Product> _relatedProducts = [];
  bool _isRelatedLoading = true;

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

  @override
  void initState() {
    super.initState();
    _fetchRating();
    _fetchCategory();
    _fetchRelatedProducts();
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
                _SpecRow(
                  label: 'Nama Produk',
                  value: widget.product.name,
                  colors: colors,
                ),
                _SpecRow(
                  label: 'Kategori',
                  value: _categoryLabel ?? '-',
                  colors: colors,
                ),
                _SpecRow(
                  label: 'Harga',
                  value: CurrencyFormatter.rupiah(widget.product.price),
                  colors: colors,
                ),
                _SpecRow(
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
      body: SafeArea(
        child: Column(
          children: [
            DetailTopBar(colors: colors, onShare: _shareProduct),
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
                            isWishlisted: context
                                .watch<WishlistBloc>()
                                .contains(widget.product.id),
                            colors: colors,
                            isDark: isDark,
                            onWishlistTap: _toggleWishlist,
                          ),
                          const SizedBox(height: 10),

                           RatingRow(
                             rating: _isMetaLoading
                                 ? '--'
                                 : (_rating > 0 ? _rating.toStringAsFixed(1) : '0.0'),
                             reviewCount: _isMetaLoading ? 0 : _reviewCount,
                             colors: colors,
                           ),
                          const SizedBox(height: 16),

                          _QuantitySelector(
                            quantity: _quantity,
                            stock: widget.product.stock,
                            colors: colors,
                            onChanged: (value) =>
                                setState(() => _quantity = value),
                          ),
                          const SizedBox(height: 16),

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

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            BottomBar(
              price: widget.product.price,
              quantity: _quantity,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Produk Serupa',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
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

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final int stock;
  final AppColorScheme colors;
  final ValueChanged<int> onChanged;

  const _QuantitySelector({
    required this.quantity,
    required this.stock,
    required this.colors,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final outOfStock = stock <= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, size: 20, color: colors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              outOfStock
                  ? 'Stok habis'
                  : 'Stok: $stock',
              style: TextStyle(
                color: outOfStock
                    ? AppColors.error
                    : (stock <= 5 ? AppColors.warning : colors.textSecondary),
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
          _QtyStepBtn(
            icon: Icons.remove_rounded,
            colors: colors,
            enabled: quantity > 1,
            onTap: () => onChanged(quantity - 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$quantity',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          _QtyStepBtn(
            icon: Icons.add_rounded,
            colors: colors,
            enabled: !outOfStock && quantity < stock,
            onTap: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _QtyStepBtn extends StatelessWidget {
  final IconData icon;
  final AppColorScheme colors;
  final bool enabled;
  final VoidCallback onTap;

  const _QtyStepBtn({
    required this.icon,
    required this.colors,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? colors.inputFill : colors.inputFill.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? colors.textPrimary : colors.textHint,
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;
  final AppColorScheme colors;

  const _SpecRow({
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}