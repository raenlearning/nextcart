import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nextcart/core/constants/app_assets.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/features/order/presentation/widgets/order_list.dart';
import 'package:nextcart/features/order/presentation/widgets/order_status_tabs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  final SupabaseClient _supabase = Supabase.instance.client;
  late final TabController _tabController;

  List<Map<String, dynamic>> _allOrders = [];
  bool _isLoading = true;

  List<Map<String, dynamic>> get _activeOrders => _allOrders
      .where(
        (o) => [
          OrderStatus.waitingPayment,
          OrderStatus.processing,
        ].contains(o['status']),
      )
      .toList();

  List<Map<String, dynamic>> get _completedOrders =>
      _allOrders.where((o) => o['status'] == OrderStatus.completed).toList();

  List<Map<String, dynamic>> get _cancelledOrders =>
      _allOrders.where((o) => o['status'] == OrderStatus.cancelled).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> refresh() => _fetchOrders();

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          _allOrders = [];
          _isLoading = false;
        });
        return;
      }

      final data = await _supabase
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
          .order('created_at', ascending: false)
          .limit(50);

      if (!mounted) return;
      setState(() {
        _allOrders = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat pesanan: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: OrderStatusTabs(controller: _tabController, colors: colors),
        ),
      ),
      body: _isLoading
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
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                OrderList(
                  orders: _activeOrders,
                  emptyMessage: 'Belum ada pesanan aktif',
                  colors: colors,
                  onRefresh: _fetchOrders,
                ),
                OrderList(
                  orders: _completedOrders,
                  emptyMessage: 'Belum ada pesanan selesai',
                  colors: colors,
                  onRefresh: _fetchOrders,
                ),
                OrderList(
                  orders: _cancelledOrders,
                  emptyMessage: 'Belum ada pesanan dibatalkan',
                  colors: colors,
                  onRefresh: _fetchOrders,
                ),
              ],
            ),
    );
  }
}
