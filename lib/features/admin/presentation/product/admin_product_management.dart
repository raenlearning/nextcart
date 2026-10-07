import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:nextcart/core/widgets/admin/product_filter_chip.dart';
import 'package:nextcart/core/widgets/admin/product_filter_sheet.dart';
import 'package:nextcart/core/widgets/admin/product_list_item.dart';
import 'package:nextcart/core/widgets/admin/product_search_bar.dart';
import 'package:nextcart/core/constants/app_spacing.dart';
import 'package:nextcart/features/admin/bloc/product/admin_product_bloc.dart';
import 'package:nextcart/features/admin/bloc/product/admin_product_event.dart';
import 'package:nextcart/features/admin/bloc/product/admin_product_state.dart';
import 'package:nextcart/data/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextcart/core/helper/toast_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';

class AdminProductManagementPage extends StatefulWidget {
  const AdminProductManagementPage({super.key});

  @override
  State<AdminProductManagementPage> createState() =>
      _AdminProductManagementPageState();
}

class _AdminProductManagementPageState
    extends State<AdminProductManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final _supabase = Supabase.instance.client;

  String? _selectedStatusFilter;
  String? _selectedCategoryFilter;
  String _searchQuery = '';
  Map<String, String> _categoryNames = {};

  @override
  void initState() {
    super.initState();
    context.read<AdminProductBloc>().add(FetchAdminProducts());
    _searchController.addListener(
      () => setState(() => _searchQuery = _searchController.text.toLowerCase()),
    );
    _searchFocusNode.addListener(() => setState(() {}));
    _fetchCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select('id, name')
          .order('name', ascending: true);
      if (mounted) {
        setState(() {
          _categoryNames = {
            for (final item in response as List)
              item['id'].toString(): item['name'].toString(),
          };
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch categories: $e');
    }
  }

  Future<void> _navigateToForm([Product? product]) async {
    final result = await context.push('/add-product', extra: product);
    if (result == true && mounted) {
      context.read<AdminProductBloc>().add(FetchAdminProducts());
    }
  }

  void _showSnack(String msg, Color color) {
    ToastSeverity severity;
    if (color == AppColors.error) {
      severity = ToastSeverity.error;
    } else if (color == AppColors.warning) {
      severity = ToastSeverity.warning;
    } else if (color == AppColors.success) {
      severity = ToastSeverity.success;
    } else {
      severity = ToastSeverity.info;
    }
    ToastHelper.showToast(context, msg, severity);
  }

  void _showStatusFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ProductFilterSheet(
        title: 'Filter Status',
        options: const {
          null: 'Semua',
          'active': 'Aktif',
          'inactive': 'Tidak Aktif',
        },
        selectedValue: _selectedStatusFilter,
        onSelected: (value) => setState(() => _selectedStatusFilter = value),
      ),
    );
  }

  void _showCategoryFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ProductFilterSheet(
        title: 'Filter Kategori',
        options: {
          null: 'Semua Kategori',
          for (final e in _categoryNames.entries) e.key: e.value,
        },
        selectedValue: _selectedCategoryFilter,
        onSelected: (value) => setState(() => _selectedCategoryFilter = value),
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.colors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
             Text(
              'Hapus Produk?',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        content:  Text(
          'Produk akan dihapus secara permanen dan tidak bisa dikembalikan.',
          style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.textSecondary,
                    side: BorderSide(color: context.colors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.read<AdminProductBloc>().add(DeleteAdminProduct(id));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Hapus',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<dynamic> _applyFilters(List<dynamic> products) {
    return products.where((p) {
      final matchSearch =
          _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery);
      final matchStatus = _selectedStatusFilter == null ||
          (_selectedStatusFilter == 'active' && p.isActive == true) ||
          (_selectedStatusFilter == 'inactive' && p.isActive == false);
      final matchCategory = _selectedCategoryFilter == null ||
          p.categoryId.toString() == _selectedCategoryFilter;
      return matchSearch && matchStatus && matchCategory;
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: BlocConsumer<AdminProductBloc, AdminProductState>(
          listener: (context, state) {
            if (state is AdminProductActionSuccess) {
              _showSnack(state.message, AppColors.secondary);
              context.read<AdminProductBloc>().add(FetchAdminProducts());
              Future.microtask(() {
                context.read<AdminProductBloc>().add(ResetAdminProductState());
              });
            } else if (state is AdminProductError) {
              _showSnack(state.message, AppColors.error);
            }
          },
          builder: (context, state) {
            final allProducts =
                state is AdminProductLoaded ? state.products : <dynamic>[];
            final filtered = _applyFilters(allProducts);
            final hasActiveFilter =
                _selectedStatusFilter != null || _selectedCategoryFilter != null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(onAdd: () => _navigateToForm()),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: ProductSearchBar(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    hasActiveFilter: hasActiveFilter,
                    onFilterTap: _showStatusFilterSheet,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: _FilterChipRow(
                    selectedStatusFilter: _selectedStatusFilter,
                    selectedCategoryFilter: _selectedCategoryFilter,
                    categoryNames: _categoryNames,
                    hasActiveFilter: hasActiveFilter,
                    onStatusTap: _showStatusFilterSheet,
                    onCategoryTap: _showCategoryFilterSheet,
                    onReset: () => setState(() {
                      _selectedStatusFilter = null;
                      _selectedCategoryFilter = null;
                    }),
                  ),
                ),

                 Expanded(
                   child: state is AdminProductLoading
                       ? Center(
                           child: Lottie.asset(
                             AppAssets.loadingChart,
                             width: 60,
                             height: 60,
                             repeat: true,
                           ),
                         )
                       : filtered.isEmpty
                           ? Center(
                               child: Column(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Lottie.asset(
                                     AppAssets.emptyProducts,
                                     width: 120,
                                     height: 120,
                                     repeat: true,
                                   ),
                                   const SizedBox(height: 16),
                                    Text(
                                      hasActiveFilter || _searchQuery.isNotEmpty
                                          ? 'Tidak ada produk cocok'
                                          : 'Belum ada produk',
                                      style: TextStyle(
                                        color: context.colors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                   const SizedBox(height: 12),
                                   ElevatedButton(
                                     onPressed: () => _navigateToForm(),
                                     child: const Text('Tambah Produk'),
                                   ),
                                 ],
                               ),
                             )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(0, 4, 0, AppSpacing.bottomNavSpace),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final product = filtered[index];
                                return ProductListItem(
                                  product: product,
                                  onTap: () => _navigateToForm(product),
                                  onDelete: () => _confirmDelete(product.id),
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onAdd;
  const _Header({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
      child: Row(
        children: [
           Expanded(
            child: Text(
              'Produk',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
                fontFamily: 'Geist',
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
            label: const Text(
              'Tambah Produk',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipRow extends StatelessWidget {
  final String? selectedStatusFilter;
  final String? selectedCategoryFilter;
  final Map<String, String> categoryNames;
  final bool hasActiveFilter;
  final VoidCallback onStatusTap;
  final VoidCallback onCategoryTap;
  final VoidCallback onReset;

  const _FilterChipRow({
    required this.selectedStatusFilter,
    required this.selectedCategoryFilter,
    required this.categoryNames,
    required this.hasActiveFilter,
    required this.onStatusTap,
    required this.onCategoryTap,
    required this.onReset,
  });

  String get _statusLabel {
    if (selectedStatusFilter == null) return 'Status';
    return selectedStatusFilter == 'active' ? 'Aktif' : 'Tidak Aktif';
  }

  String get _categoryLabel {
    if (selectedCategoryFilter == null) return 'Kategori';
    return categoryNames[selectedCategoryFilter] ?? selectedCategoryFilter!;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProductFilterChip(
          label: _statusLabel,
          active: selectedStatusFilter != null,
          onTap: onStatusTap,
        ),
        const SizedBox(width: 8),
        ProductFilterChip(
          label: _categoryLabel,
          active: selectedCategoryFilter != null,
          onTap: onCategoryTap,
        ),
        if (hasActiveFilter) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onReset,
            child: const Text(
              'Reset',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}