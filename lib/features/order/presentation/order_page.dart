import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nextcart/core/constants/app_assets.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/helper/toast_helper.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/features/order/presentation/widgets/order_list.dart';
import 'package:nextcart/features/order/presentation/widgets/order_search_bar.dart';
import 'package:nextcart/features/order/presentation/widgets/order_status_tabs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderScreen extends StatefulWidget {
  final SupabaseClient? supabaseClient;

  const OrderScreen({super.key, this.supabaseClient});

  @override
  State<OrderScreen> createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  static const int _pageSize = 5;

  late final SupabaseClient _supabase =
      widget.supabaseClient ?? Supabase.instance.client;
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  String _searchQuery = '';

  final Map<int, List<Map<String, dynamic>>> _ordersByTab = {
    0: [],
    1: [],
    2: [],
  };
  final Map<int, int> _pageByTab = {0: 1, 1: 1, 2: 1};
  final Map<int, bool> _hasMoreByTab = {0: true, 1: true, 2: true};
  final Map<int, bool> _isLoadingMoreByTab = {0: false, 1: false, 2: false};
  final Map<int, bool> _isLoadingTab = {0: true, 1: false, 2: false};

  bool _isInitialLoading = true;

  static const _tabStatuses = {
    0: [OrderStatus.waitingPayment, OrderStatus.processing],
    1: [OrderStatus.completed],
    2: [OrderStatus.cancelled],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _fetchTab(0, reset: true, initial: true);
    _fetchTab(1, reset: true);
    _fetchTab(2, reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final index = _tabController.index;
      if (_ordersByTab[index]?.isEmpty ?? true) {
        _fetchTab(index, reset: true);
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() => _searchQuery = value.trim());
      for (final tab in [0, 1, 2]) {
        _fetchTab(tab, reset: true);
      }
    });
  }

  Future<void> refresh() async {
    final current = _tabController.index;
    await _fetchTab(current, reset: true);
  }

  Future<void> _fetchTab(int tabIndex, {bool reset = false, bool initial = false}) async {
    if (reset) {
      setState(() {
        _pageByTab[tabIndex] = 1;
        _hasMoreByTab[tabIndex] = true;
        _isLoadingMoreByTab[tabIndex] = false;
        _isLoadingTab[tabIndex] = true;
      });
    }

    if (_isLoadingMoreByTab[tabIndex] == true && !reset) return;

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _ordersByTab[tabIndex] = [];
        _isInitialLoading = false;
        _hasMoreByTab[tabIndex] = false;
      });
      return;
    }

    final statuses = _tabStatuses[tabIndex]!;
    final page = _pageByTab[tabIndex]!;

    if (!reset) setState(() => _isLoadingMoreByTab[tabIndex] = true);

    try {
      var query = _supabase
          .from('orders')
          .select('''
            id,
            total_amount,
            status,
            shipping_address,
            created_at,
            order_items (
              id,
              quantity,
              price_at_purchase,
              products (
                id,
                name,
                images
              )
            ),
            payments!payments_order_id_fkey (
              snap_token,
              status,
              method,
              paid_at
            )
          ''')
          .eq('user_id', userId)
          .inFilter('status', statuses);

      if (_searchQuery.isNotEmpty) {
        query = query.ilike(
          'order_items.products.name',
          '%$_searchQuery%',
        );
      }

      final data = await query
          .order('created_at', ascending: false)
          .range(
            (page - 1) * _pageSize,
            (page * _pageSize) - 1,
          );

      if (!mounted) return;
      final items = List<Map<String, dynamic>>.from(data);
      setState(() {
        _ordersByTab[tabIndex] = reset
            ? items
            : [...?_ordersByTab[tabIndex], ...items];
        _pageByTab[tabIndex] = page + 1;
        _hasMoreByTab[tabIndex] = items.length >= _pageSize;
        _isLoadingMoreByTab[tabIndex] = false;
        _isLoadingTab[tabIndex] = false;
        if (initial) _isInitialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMoreByTab[tabIndex] = false;
        _isLoadingTab[tabIndex] = false;
        _isInitialLoading = false;
      });
      ToastHelper.showToast(context, 'Gagal memuat pesanan: ${e.toString()}', ToastSeverity.error);
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
          'Riwayat Pesanan',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: OrderSearchBar(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  colors: colors,
                ),
              ),
              OrderStatusTabs(controller: _tabController, colors: colors),
            ],
          ),
        ),
      ),
      body: _isInitialLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    AppAssets.loadingChart,
                    width: 60,
                    height: 60,
                    repeat: true,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Memuat pesanan...',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTab(0, 'Belum ada pesanan aktif'),
                _buildTab(1, 'Belum ada pesanan selesai'),
                _buildTab(2, 'Belum ada pesanan dibatalkan'),
              ],
            ),
    );
  }

  Widget _buildTab(int index, String emptyMessage) {
    final colors = context.colors;
    return OrderList(
      orders: _ordersByTab[index] ?? [],
      isLoading: _isLoadingTab[index] ?? false,
      isLoadingMore: _isLoadingMoreByTab[index] ?? false,
      hasMore: _hasMoreByTab[index] ?? true,
      emptyMessage: _searchQuery.isNotEmpty
          ? 'Tidak ada pesanan untuk "$_searchQuery"'
          : emptyMessage,
      colors: colors,
      onRefresh: () => _fetchTab(index, reset: true),
      onLoadMore: () => _fetchTab(index),
    );
  }
}