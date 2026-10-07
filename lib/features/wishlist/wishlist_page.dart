import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nextcart/core/constants/app_assets.dart';
import 'package:nextcart/core/helper/toast_helper.dart';
import 'package:nextcart/core/constants/app_spacing.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/widgets/shimmer_box.dart';
import 'package:nextcart/features/cart/bloc/cart_bloc.dart';
import 'package:nextcart/features/wishlist/bloc/wishlist_bloc.dart';
import 'package:nextcart/features/wishlist/presentation/widgets/wishlist_card.dart';
import 'package:nextcart/features/wishlist/presentation/widgets/wishlist_filter_bar.dart';
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

    if (mounted) {
      ToastHelper.showTopToast(context, 'Produk dipindahkan ke keranjang');
    }
  }

  void _removeFromWishlist(Map<String, dynamic> item) {
    final product = item['products'] as Map<String, dynamic>?;
    final productId = product?['id'] as String?;
    if (productId == null) return;

    context.read<WishlistBloc>().add(WishlistRemove(productId));

    if (!mounted) return;
    ToastHelper.showToast(context, 'Dihapus dari wishlist', ToastSeverity.info);
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
            fontSize: 17,
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
          WishlistFilterBar(
            searchController: _searchController,
            onSearchChanged: (_) => _onSearchChanged(),
            onClearSearch: () {
              _searchController.clear();
              _fetchWishlist(reset: true);
            },
            categories: _categories,
            selectedCategoryId: _selectedCategoryId,
            onCategoryTap: (id) {
              setState(() => _selectedCategoryId = id);
              _fetchWishlist(reset: true);
            },
            sortBy: _sortBy,
            onSortChanged: (value) {
              if (value == null) return;
              setState(() => _sortBy = value);
              _fetchWishlist(reset: true);
            },
          ),
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
                    return const ShimmerProductGrid(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        AppSpacing.bottomNavSpace,
                      ),
                      childAspectRatio: 0.7,
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
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        AppSpacing.bottomNavSpace,
                      ),
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
                        final item = items[index];
                        return WishlistCard(
                          wishlistItem: item,
                          colors: colors,
                          onMoveToCart: () => _moveToCart(item),
                          onRemove: () => _removeFromWishlist(item),
                        );
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

  Widget _buildEmptyState(AppColorScheme colors) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 60),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AppAssets.emptyWishlist,
                  width: 220,
                  height: 200,
                ),
                const SizedBox(height: 16),
                Text(
                  'Wishlist kamu masih kosong',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
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
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
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
}