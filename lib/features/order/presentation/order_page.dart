// lib/features/order/order_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
import 'package:nextcart/features/order/courier_tracking_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_assets.dart';

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
          .order('created_at', ascending: false);

      setState(() {
        _allOrders = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
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
          child: _buildTabBar(colors),
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
                    style: TextStyle(color: colors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(
                  colors,
                  _activeOrders,
                  'Belum ada pesanan aktif',
                ),
                _buildOrderList(
                  colors,
                  _completedOrders,
                  'Belum ada pesanan selesai',
                ),
                _buildOrderList(
                  colors,
                  _cancelledOrders,
                  'Belum ada pesanan dibatalkan',
                ),
              ],
            ),
    );
  }

  Widget _buildTabBar(AppColorScheme colors) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,

        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,

        indicator: BoxDecoration(
          color: context.colors.textPrimary,
          borderRadius: BorderRadius.circular(10),
        ),

        labelColor: context.colors.background,
        unselectedLabelColor: context.colors.textPrimary.withValues(alpha: 0.6),

        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),

        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),

        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStatePropertyAll(Colors.transparent),

        tabs: const [
          Tab(text: "Aktif"),
          Tab(text: "Selesai"),
          Tab(text: "Dibatalkan"),
        ],
      ),
    );
  }

  Widget _buildOrderList(
    AppColorScheme colors,
    List<Map<String, dynamic>> orders,
    String emptyMessage,
  ) {
    if (orders.isEmpty) {
      return _buildEmptyState(colors, emptyMessage);
    }

    final totalItems = orders.fold<int>(
      0,
      (sum, o) => sum + ((o['order_items'] as List?)?.length ?? 0),
    );

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchOrders,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jumlah Produk',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                '($totalItems)',
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...orders.map((order) => _buildOrderCard(colors, order)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColorScheme colors, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            AppAssets.emptyOrders,
            width: 120,
            height: 120,
            repeat: true,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: colors.textSecondary, fontSize: 13.5),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(AppColorScheme colors, Map<String, dynamic> order) {
    final items = order['order_items'] as List<dynamic>? ?? [];
    final status = order['status'] as String? ?? OrderStatus.waitingPayment;
    final statusColor = OrderStatus.color(status);
    final createdAt = DateTime.tryParse(order['created_at'] ?? '');

    final firstItem = items.isNotEmpty
        ? items[0] as Map<String, dynamic>
        : null;
    final firstProduct = firstItem?['products'] as Map<String, dynamic>?;
    final images = firstProduct?['images'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images[0] as String : null;

    final payment = order['payments'] as Map<String, dynamic>?;
    final paymentStatus = payment?['status'] as String?;

    final orderId = order['id'].toString();
    final shortId = orderId.length >= 6 ? orderId.substring(0, 6) : orderId;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        context.push('/order-detail', extra: order);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail produk
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: colors.inputFill,
                borderRadius: BorderRadius.circular(14),
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null
                  ? Icon(
                      Icons.shopping_bag_outlined,
                      color: colors.textSecondary,
                      size: 26,
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Info pesanan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris 1: nomor invoice + badge status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '#$shortId',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),

                      Row(
                        children: [
                          _buildPill(OrderStatus.label(status), statusColor),
                          if (paymentStatus == 'settlement') ...[
                            const SizedBox(width: 6),
                            _buildPill('Dibayar', AppColors.success),
                          ],
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Baris 2: tanggal + jumlah item
                  Text(
                    '${createdAt != null ? _formatDate(createdAt) : ''} · ${items.length} item',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Baris 3: harga + tombol aksi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyFormatter.rupiah(order['total_amount']),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      _buildCompactActionButton(colors, status, order),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCompactActionButton(
    AppColorScheme colors,
    String status,
    Map<String, dynamic> order,
  ) {
    String label;
    bool enabled = true;
    Color? outlineColor;

    switch (status) {
      case OrderStatus.waitingPayment:
        label = 'Bayar';
        outlineColor = AppColors.warning;
        break;
      case OrderStatus.processing:
      case OrderStatus.delivered:
        label = 'Lacak';
        break;
      case OrderStatus.completed:
        label = 'Beli Lagi';
        break;
      case OrderStatus.cancelled:
        label = 'Dibatalkan';
        enabled = false;
        break;
      default:
        label = 'Detail';
    }

    return GestureDetector(
      onTap: enabled
          ? () {
              if (status == OrderStatus.processing ||
                  status == OrderStatus.delivered) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourierTrackingPage(
                      orderId: order['id'].toString(),
                      destinationAddress: order['shipping_address'] ?? '-',
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fitur "$label" segera hadir')),
                );
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: enabled
              ? (outlineColor == null ? colors.textPrimary : Colors.transparent)
              : colors.inputFill,
          borderRadius: BorderRadius.circular(24),
          border: outlineColor != null
              ? Border.all(color: outlineColor, width: 1.4)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: !enabled
                ? colors.textHint
                : (outlineColor ?? colors.background),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
