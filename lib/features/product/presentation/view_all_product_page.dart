import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nextcart/core/constants/app_assets.dart';
import 'package:nextcart/core/widgets/user/product_grid.dart';
import 'package:nextcart/core/widgets/shimmer_box.dart';
import 'package:nextcart/core/widgets/user/promo_banner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/data/models/product_model.dart';
import 'package:nextcart/features/product/presentation/widgets/category_grid.dart';
import 'package:nextcart/features/product/presentation/widgets/flash_sale_banner.dart';
import 'package:nextcart/features/product/presentation/widgets/sort_chips.dart';
import 'package:nextcart/features/product/presentation/widgets/trust_badges_row.dart';

class ViewAllProductsPage extends StatefulWidget {
  final String title;
  final String? initialCategoryId;
  final bool focusSearch;

  const ViewAllProductsPage({
    super.key,
    required this.title,
    this.initialCategoryId,
    this.focusSearch = false,
  });

  @override
  State<ViewAllProductsPage> createState() => _ViewAllProductsPageState();
}

class _ViewAllProductsPageState extends State<ViewAllProductsPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 20;
  Timer? _debounce;
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;
  String _searchQuery = '';
  String _sortOption = SortOption.newest.id;
  List<Product> _products = [];
  bool _isLoadingCategories = true;
  bool _isLoadingProducts = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  bool _isExpanded = false;
  final GlobalKey _productGridKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _fetchCategories();
    _fetchProducts();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    if (widget.focusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusSearchField());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      _loadMoreProducts();
    }
  }

  void _focusSearchField() {
    _searchFocusNode.requestFocus();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() => _searchQuery = _searchController.text.trim());
      _fetchProducts();
    });
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final data = await _supabase
          .from('categories')
          .select('id, name')
          .order('name', ascending: true);

      List<Map<String, dynamic>> fetchedList = List<Map<String, dynamic>>.from(
        data,
      );

      final otherIndex = fetchedList.indexWhere(
        (element) => element['name'].toString().toLowerCase() == 'other',
      );

      if (otherIndex != -1) {
        final otherCategory = fetchedList.removeAt(otherIndex);
        fetchedList.add(otherCategory);
      }

      if (!mounted) return;
      setState(() {
        _categories = fetchedList;
        _isLoadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _errorMessage = null;
      _products = [];
      _hasMore = true;
      _isLoadingMore = false;
    });
    try {
      final data = await _productQuery().range(0, _pageSize - 1);
      if (!mounted) return;
      setState(() {
        _products = (data as List)
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
        _hasMore = _products.length == _pageSize;
        _isLoadingProducts = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat produk: $e';
        _isLoadingProducts = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore || _isLoadingProducts) return;
    setState(() => _isLoadingMore = true);
    try {
      final offset = _products.length;
      final data = await _productQuery().range(offset, offset + _pageSize - 1);
      if (!mounted) return;
      setState(() {
        final newItems = (data as List)
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
        _products.addAll(newItems);
        _hasMore = newItems.length == _pageSize;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  PostgrestTransformBuilder<PostgrestList> _productQuery() {
    var query = _supabase
        .from('products')
        .select(
          'id, name, description, price, stock, category_id, images, seller_id, is_active',
        )
        .eq('is_active', true);
    if (_selectedCategoryId != null) {
      query = query.eq('category_id', _selectedCategoryId!);
    }
    if (_searchQuery.isNotEmpty) {
      query = query.ilike('name', '%$_searchQuery%');
    }
    switch (_sortOption) {
      case 'price_asc':
        return query.order('price', ascending: true);
      case 'price_desc':
        return query.order('price', ascending: false);
      case 'rating':
        return query.order('total_rating', ascending: false);
      default:
        return query.order('created_at', ascending: false);
    }
  }

  void _onSortChanged(SortOption option) {
    if (option.id == _sortOption) return;
    setState(() => _sortOption = option.id);
    _fetchProducts();
  }

  void _scrollToProducts() {
    final context = _productGridKey.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      alignment: 0.0,
    );
  }

  void _onCategoryTap(String? categoryId) {
    if (categoryId == _selectedCategoryId) return;
    setState(() => _selectedCategoryId = categoryId);
    _fetchProducts();
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
          widget.title,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future.wait([_fetchCategories(), _fetchProducts()]);
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: _buildSearchBar(colors)),
            const SliverToBoxAdapter(child: SizedBox(height: 4)),
            const SliverToBoxAdapter(child: HomeBannerCarousel()),
            SliverToBoxAdapter(
              child: CategoryGrid(
                categories: _categories,
                selectedCategoryId: _selectedCategoryId,
                isLoading: _isLoadingCategories,
                isExpanded: _isExpanded,
                onCategoryTap: _onCategoryTap,
                onToggleExpand: () =>
                    setState(() => _isExpanded = !_isExpanded),
              ),
            ),
            SliverToBoxAdapter(
              child: FlashSaleBanner(onCta: _scrollToProducts),
            ),
            const SliverToBoxAdapter(child: TrustBadgesRow()),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isLoadingProducts && _products.isNotEmpty) ...[
                      Text(
                        'Menampilkan ${_products.length} produk',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textHint,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    SortChips(
                      selectedId: _sortOption,
                      onSelected: _onSortChanged,
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 4)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(),
              ),
            ),
            ..._buildProductSlivers(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: colors.inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: TextStyle(color: colors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Cari produk...',
            hintStyle: TextStyle(color: colors.textHint, fontSize: 14),
            prefixIcon: Icon(
              Icons.search,
              color: colors.textSecondary,
              size: 20,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                      color: colors.textSecondary,
                      size: 18,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                      _fetchProducts();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProductSlivers(AppColorScheme colors) {
    if (_isLoadingProducts) {
      return const [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          sliver: SliverToBoxAdapter(
            child: ShimmerProductGrid(
              padding: EdgeInsets.zero,
              childAspectRatio: 0.62,
            ),
          ),
        ),
      ];
    }
    if (_errorMessage != null) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off_rounded,
                      size: 48, color: colors.textHint),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchProducts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }
    if (_products.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                SvgPicture.asset(
                  AppAssets.emptySearch,
                  width: 200,
                  height: 180,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Tidak ada produk untuk "$_searchQuery"'
                      : 'Belum ada produk di kategori ini',
                  style: TextStyle(color: colors.textSecondary, fontSize: 13.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Coba kata kunci atau kategori lain ya',
                  style: TextStyle(color: colors.textHint, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        key: _productGridKey,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 14,
            childAspectRatio: 0.62,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => ProductCard(product: _products[index]),
            childCount: _products.length,
          ),
        ),
      ),
      if (_isLoadingMore)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
    ];
  }
}