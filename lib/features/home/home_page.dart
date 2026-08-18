import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/constants/app_assets.dart';
import 'package:nextcart/core/widgets/user/app_bar.dart';
import 'package:nextcart/core/widgets/user/category_chips.dart';
import 'package:nextcart/core/widgets/user/header_section.dart';
import 'package:nextcart/core/widgets/user/product_grid.dart';
import 'package:nextcart/core/widgets/user/promo_banner.dart';
import 'package:nextcart/core/widgets/user/search_bar.dart';
import 'package:nextcart/core/widgets/shimmer_box.dart';
import 'package:nextcart/core/constants/app_spacing.dart';
import 'package:nextcart/features/product/bloc/product_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  String _selectedCategoryId = 'all';
  List<Map<String, dynamic>> _categoriesList = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(FetchPopularProducts());
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select('id, name')
          .order('name', ascending: true);

      if (mounted) {
        setState(() {
          _categoriesList = [
            {'id': 'all', 'name': 'Semua'},
            ...List<Map<String, dynamic>>.from(response as List),
          ];
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _refresh() async {
    await _fetchCategories();
    if (!mounted) return;
    context.read<ProductBloc>().add(
          _selectedCategoryId == 'all'
              ? FetchPopularProducts()
              : FetchProductsByCategory(_selectedCategoryId),
        );
  }

  void _onCategorySelected(String categoryId) {
    if (_selectedCategoryId == categoryId) return;
    setState(() => _selectedCategoryId = categoryId);
    if (categoryId == 'all') {
      context.read<ProductBloc>().add(FetchPopularProducts());
    } else {
      context.read<ProductBloc>().add(FetchProductsByCategory(categoryId));
    }
  }

  Future<void> _logout() async {
    await _supabase.auth.signOut();
    if (mounted) {
      context.go('/auth');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil keluar dari akun.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, AppSpacing.bottomNavSpace),
          child: SafeArea(
            top: true,
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeAppBar(
                  onLogoutTap: _logout,
                ),
                const SizedBox(height: 24),

                Text(
                  'Teknologi Gen-Baru',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: colors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Tanpa Ribet',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Search
                const HomeSearchBar(),
                const SizedBox(height: 24),

                // ── Promo banner
                const HomeBannerCarousel(),
                const SizedBox(height: 24),

                // ── Category chips
                HomeCategoryChips(
                  categories: _categoriesList,
                  isLoading: _isLoadingCategories,
                  selectedId: _selectedCategoryId,
                  onSelected: _onCategorySelected,
                ),
                const SizedBox(height: 24),

                // ── Popular section header
                HomeSectionHeader(
                  title: 'Populer',
                  actionLabel: 'Lihat Semua',
                  onActionTap: () {
                    context.push('/view-all');
                  },
                ),
                const SizedBox(height: 16),

                // ── Product grid
                BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state is ProductLoading) {
                      return const ShimmerProductGrid();
                    }
                    if (state is ProductError) {
                      return _ErrorRetry(
                        message: state.message,
                        onRetry: () {
                          context.read<ProductBloc>().add(
                                _selectedCategoryId == 'all'
                                    ? FetchPopularProducts()
                                    : FetchProductsByCategory(
                                        _selectedCategoryId,
                                      ),
                              );
                        },
                      );
                    }
                    if (state is ProductLoaded) {
                      final products = state.products;
                      if (products.isEmpty) {
                        return _EmptyProducts(colors: colors);
                      }
                      return HomeProductGrid(products: products);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.cloud_off_rounded, size: 40, color: colors.textHint),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat produk',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  final AppColorScheme colors;

  const _EmptyProducts({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            SvgPicture.asset(
              AppAssets.emptySearch,
              width: 160,
              height: 145,
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada produk di kategori ini.',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
