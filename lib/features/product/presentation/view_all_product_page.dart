import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nextcart/core/widgets/user/product_grid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/constants/app_assets.dart';
import 'package:nextcart/data/models/product_model.dart';

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
  Timer? _debounce;
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;
  String _searchQuery = '';
  List<Product> _products = [];
  bool _isLoadingCategories = true;
  bool _isLoadingProducts = true;
  String? _errorMessage;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _fetchCategories();
    _fetchProducts();
    _searchController.addListener(_onSearchChanged);
    if (widget.focusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusSearchField());
    }
  }

  FocusNode _searchFocusNode = FocusNode();

  void _focusSearchField() {
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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

      setState(() {
        _categories = fetchedList;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _errorMessage = null;
    });
    try {
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
      final data = await query.order('created_at', ascending: false);
      setState(() {
        _products = (data as List)
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat produk: $e';
        _isLoadingProducts = false;
      });
    }
  }

  void _onCategoryTap(String? categoryId) {
    if (categoryId == _selectedCategoryId) return;
    setState(() => _selectedCategoryId = categoryId);
    _fetchProducts();
  }

  String? _getSvgAsset(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'smartphone':
        return AppAssets.categorySmartPhone;
      case 'laptop':
        return AppAssets.categoryLaptop;
      case 'audio':
        return AppAssets.categoryAudio;
      case 'gaming':
        return AppAssets.categoryGaming;
      case 'watch':
        return AppAssets.categoryWatch;
      case 'computer':
        return AppAssets.categoryComputer;
      case 'television':
        return AppAssets.categoryTelevision;
      case 'camera':
        return AppAssets.categoryCamera;
      default:
        return null;
    }
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
          await _fetchCategories();
          await _fetchProducts();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            children: [
              _buildSearchBar(colors),
              _buildCategoryChips(colors),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: colors.divider),
              ),
              _buildProductGrid(colors),
            ],
          ),
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

  Widget _buildCategoryChips(AppColorScheme colors) {
    if (_isLoadingCategories) {
      return const Padding(
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
      );
    }

    final int totalItems = _categories.length + 1;

    final int displayedCount = _isExpanded
        ? totalItems
        : (totalItems > 4 ? 4 : totalItems);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Belanja Sesuai Kategori',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              if (totalItems > 4)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayedCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildChip(
                  colors,
                  label: 'Semua',
                  isSelected: _selectedCategoryId == null,
                  onTap: () => _onCategoryTap(null),
                  svgAsset: null,
                );
              }
              final category = _categories[index - 1];
              final categoryId = category['id'] as String;
              final categoryName = category['name'] as String;

              return _buildChip(
                colors,
                label: categoryName,
                isSelected: _selectedCategoryId == categoryId,
                onTap: () => _onCategoryTap(categoryId),
                svgAsset: _getSvgAsset(categoryName),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    AppColorScheme colors, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required String? svgAsset,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppColors.primary
                  : (context.isDark
                        ? colors.inputFill
                        : const Color(0xFFF3EAE6)),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : colors.border.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Center(
              child: svgAsset != null
                  ? SvgPicture.asset(
                      svgAsset,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        isSelected ? Colors.white : colors.textPrimary,
                        BlendMode.srcIn,
                      ),
                    )
                  : Icon(
                      label == 'Semua'
                          ? Icons.apps_rounded
                          : Icons.devices_other_rounded,
                      size: 22,
                      color: isSelected ? Colors.white : colors.textPrimary,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? AppColors.primary : colors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(AppColorScheme colors) {
    if (_isLoadingProducts) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: colors.textHint),
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
      );
    }
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 40),
            Icon(Icons.search_off_rounded, size: 48, color: colors.textHint),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tidak ada produk untuk "$_searchQuery"'
                  : 'Belum ada produk di kategori ini',
              style: TextStyle(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      itemCount: _products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 14,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (context, index) => ProductCard(product: _products[index]),
    );
  }
}
