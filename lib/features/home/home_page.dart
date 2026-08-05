import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/widgets/user/app_bar.dart';
import 'package:nextcart/core/widgets/user/category_chips.dart';
import 'package:nextcart/core/widgets/user/header_section.dart';
import 'package:nextcart/core/widgets/user/product_grid.dart';
import 'package:nextcart/core/widgets/user/promo_banner.dart';
import 'package:nextcart/core/widgets/user/search_bar.dart';
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
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
                'Teknologi Gen-Baru\nTanpa Ribet',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
                
              // ── Search 
              const HomeSearchBar(),
              const SizedBox(height: 24),
                
              // ── Promo banner 
              const HomeBanner(),
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
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    );
                  }
                  if (state is ProductError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    );
                  }
                  if (state is ProductLoaded) {
                    final products = state.products;
                    if (products.isEmpty) {
                      return Center(
                        child: Text(
                          'Belum ada produk.',
                          style: TextStyle(color: colors.textSecondary),
                        ),
                      );
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
    );
  }
}