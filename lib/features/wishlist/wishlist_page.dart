import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
import 'package:nextcart/features/cart/bloc/cart_bloc.dart';
import 'package:nextcart/features/wishlist/bloc/wishlist_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => WishlistPageState();
}

class WishlistPageState extends State<WishlistPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;
  String _sortBy = 'newest';
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchWishlist(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    _fetchWishlist(reset: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMore && !_isLoadingMore) {
        _loadMore();
      }
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchWishlist(reset: true);
    });
  }

  Future<void> _fetchCategories() async {
    try {
      final data = await _supabase
          .from('categories')
          .select('id, name')
          .order('name', ascending: true);
      if (mounted) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (_) {}
  }

  void _fetchWishlist({bool reset = false}) {
    if (reset) _page = 1;
    context.read<WishlistBloc>().add(WishlistLoadList(
          search: _searchController.text.trim(),
          categoryId: _selectedCategoryId,
          sortBy: _sortBy,
          page: _page,
          refresh: reset,
        ));
  }

  void _loadMore() {
    _isLoadingMore = true;
    _page += 1;
    context.read<WishlistBloc>().add(WishlistLoadList(
          search: _searchController.text.trim(),
          categoryId: _selectedCategoryId,
          sortBy: _sortBy,
          page: _page,
        ));
  }

  void _moveToCart(Map<String, dynamic> item) {
    final product = item['products'] as Map<String, dynamic>?;
    if (product == null) return;

    context.read<CartBloc>().add(AddToCart(product['id'] as String));
    context.read<WishlistBloc>().add(WishlistRemove(product['id'] as String));
    _fetchWishlist(reset: true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk dipindahkan ke keranjang'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _removeFromWishlist(Map<String, dynamic> item) {
    final product = item['products'] as Map<String, dynamic>?;
    final productId = product?['id'] as String?;
    if (productId == null) return;

    context.read<WishlistBloc>().add(WishlistRemove(productId));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Dihapus dari wishlist'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Batal',
          textColor: AppColors.primary,
          onPressed: () {
            context.read<WishlistBloc>().add(WishlistToggle(productId));
            _fetchWishlist(reset: true);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Wishlist',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: refresh,
            icon: Icon(Icons.refresh, color: colors.textSecondary),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(colors),
          Expanded(
            child: BlocConsumer<WishlistBloc, WishlistState>(
              listener: (context, state) {
                if (state is WishlistListLoaded) {
                  _hasMore = state.hasMore;
                  _isLoadingMore = false;
                }
              },
              builder: (context, state) {
                if (state is WishlistListLoaded) {
                  final items = state.items;
                  if (state.isLoading && items.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  if (items.isEmpty) {
                    return _buildEmptyState(colors);
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: refresh,
                    child: GridView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                      itemCount: items.length + (_hasMore ? 1 : 0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.7,
                      ),
                      itemBuilder: (context, index) {
                        if (index >= items.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }
                        return _buildWishlistCard(colors, items[index]);
                      },
                    ),
                  );
                }
                if (state is WishlistError) {
                  return _buildErrorState(colors, state.message);
                }
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        children: [
          // Search
          TextField(
            controller: _searchController,
            onChanged: (_) => _onSearchChanged(),
            decoration: InputDecoration(
              hintText: 'Cari di wishlist...',
              hintStyle: TextStyle(color: colors.textHint, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: colors.textHint, size: 20),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchController,
                builder: (context, value, _) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: Icon(Icons.clear, color: colors.textHint, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _fetchWishlist(reset: true);
                    },
                  );
                },
              ),
              filled: true,
              fillColor: colors.inputFill,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Category chips + sort
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _FilterChip(
                          label: 'Semua',
                          isActive: _selectedCategoryId == null,
                          onTap: () {
                            setState(() => _selectedCategoryId = null);
                            _fetchWishlist(reset: true);
                          },
                        );
                      }
                      final cat = _categories[index - 1];
                      final id = cat['id'] as String;
                      return _FilterChip(
                        label: cat['name'] as String,
                        isActive: _selectedCategoryId == id,
                        onTap: () {
                          setState(() => _selectedCategoryId = id);
                          _fetchWishlist(reset: true);
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: colors.inputFill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    dropdownColor: colors.card,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: colors.textSecondary,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'newest',
                        child: Text('Terbaru'),
                      ),
                      DropdownMenuItem(
                        value: 'price_low',
                        child: Text('Termurah'),
                      ),
                      DropdownMenuItem(
                        value: 'price_high',
                        child: Text('Termahal'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _sortBy = value);
                      _fetchWishlist(reset: true);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColorScheme colors) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite_border, size: 64, color: colors.textHint),
                const SizedBox(height: 12),
                Text(
                  'Wishlist kamu masih kosong',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppColorScheme colors, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 56, color: colors.textHint),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Gagal memuat wishlist',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistCard(
    AppColorScheme colors,
    Map<String, dynamic> wishlistItem,
  ) {
    final product = wishlistItem['products'] as Map<String, dynamic>?;
    if (product == null) return const SizedBox.shrink();

    final images = product['images'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images[0] as String : null;
    final category = product['categories'] as Map<String, dynamic>?;
    final categoryName = category?['name'] as String? ?? '';
    final name = product['name'] as String? ?? 'Produk';
    final price = product['price'];

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar produk
          Expanded(
            child: Center(
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.image_not_supported_outlined,
                        color: colors.textHint,
                        size: 40,
                      ),
                    )
                  : Icon(
                      Icons.shopping_bag_outlined,
                      color: colors.textHint,
                      size: 40,
                    ),
            ),
          ),
          const SizedBox(height: 10),

          // Nama & harga
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.rupiah(price),
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),

          // Kategori & tombol aksi
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.favorite,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Move to cart
              GestureDetector(
                onTap: () => _moveToCart(wishlistItem),
                child: Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
              // Remove
              GestureDetector(
                onTap: () => _removeFromWishlist(wishlistItem),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: colors.textPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: colors.background,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : colors.inputFill,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? AppColors.primary : colors.border,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isActive ? Colors.white : colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
