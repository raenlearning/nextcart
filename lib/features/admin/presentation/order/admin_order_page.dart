import 'package:flutter/material.dart';
import 'package:nextcart/core/constants/app_spacing.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/features/admin/presentation/order/widgets/admin_order_card.dart';
import 'package:nextcart/features/admin/presentation/order/widgets/order_search_bar.dart';
import 'package:nextcart/features/admin/presentation/order/widgets/status_filter_chips.dart';
import 'package:nextcart/features/admin/presentation/order/widgets/status_update_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminOrderPage extends StatefulWidget {
  const AdminOrderPage({super.key});

  @override
  State<AdminOrderPage> createState() => _AdminOrderPageState();
}

class _AdminOrderPageState extends State<AdminOrderPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _filteredOrders = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final Map<String, int> _statusCounts = {};

  final List<String> _statuses = ['all', ...OrderStatus.all];
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
        _applyLocalFilter();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final countsFuture = _fetchStatusCounts();

      var query = _supabase.from('orders').select('''
        id,
        total_amount,
        status,
        shipping_address,
        created_at,
        profiles (
          full_name,
          email,
          phone
        ),
        order_items (
          id,
          quantity,
          price_at_purchase,
          products (
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
      ''');

      if (_selectedStatus != 'all') {
        query = query.eq('status', _selectedStatus);
      }

      final data = await query.order('created_at', ascending: false).limit(100);

      if (!mounted) return;
      setState(() {
        _orders = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
        _applyLocalFilter();
      });
      await countsFuture;
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

  Future<void> _fetchStatusCounts() async {
    try {
      final counts = <String, int>{};

      Future<int> countOf(String? status) async {
        var query = _supabase.from('orders').select('id');
        if (status != null) query = query.eq('status', status);
        final res = await query.count(CountOption.exact);
        return res.count;
      }

      final results = await Future.wait([
        countOf(null),
        for (final status in OrderStatus.all) countOf(status),
      ]);
      counts['all'] = results[0];
      for (var i = 0; i < OrderStatus.all.length; i++) {
        counts[OrderStatus.all[i]] = results[i + 1];
      }

      if (mounted) setState(() => _statusCounts..clear()..addAll(counts));
    } catch (e) {
      debugPrint('Gagal memuat jumlah status pesanan: $e');
    }
  }

  void _applyLocalFilter() {
    if (_searchQuery.isEmpty) {
      _filteredOrders = List.from(_orders);
      return;
    }
    _filteredOrders = _orders.where((order) {
      final buyer = order['profiles'] as Map<String, dynamic>?;
      final name = (buyer?['full_name'] ?? '').toString().toLowerCase();
      final id = order['id'].toString().toLowerCase();
      return name.contains(_searchQuery) || id.contains(_searchQuery);
    }).toList();
  }

  void _onStatusChipTap(String status) {
    if (status == _selectedStatus) return;
    setState(() => _selectedStatus = status);
    _fetchOrders();
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = context.colors;
        return AlertDialog(
          backgroundColor: colors.card,
          title: const Text('Ubah Status Pesanan'),
          content: Text(
            'Ubah status pesanan menjadi "${OrderStatus.label(newStatus)}"?',
            style: TextStyle(color: colors.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Ubah'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await _supabase
          .from('orders')
          .update({'status': newStatus})
          .eq('id', orderId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status pesanan berhasil diperbarui menjadi ${OrderStatus.label(newStatus)}',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
      _fetchOrders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui status: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showStatusUpdateSheet(String orderId, String currentStatus) {
    if (currentStatus == OrderStatus.waitingPayment) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pesanan ini masih menunggu pembayaran, belum bisa diubah.',
          ),
        ),
      );
      return;
    }
    if (currentStatus == OrderStatus.cancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan ini sudah dibatalkan.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => StatusUpdateSheet(
        currentStatus: currentStatus,
        onStatusSelected: (status) => _updateOrderStatus(orderId, status),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colors),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: OrderSearchBar(
                controller: _searchController,
                hasQuery: _searchQuery.isNotEmpty,
                onClear: _searchController.clear,
              ),
            ),
            const SizedBox(height: 4),
            StatusFilterChips(
              statuses: _statuses,
              selectedStatus: _selectedStatus,
              counts: _statusCounts,
              onTap: _onStatusChipTap,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.4,
                      ),
                    )
                  : _filteredOrders.isEmpty
                  ? _buildEmptyState(colors)
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _fetchOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          4,
                          20,
                          AppSpacing.bottomNavSpace,
                        ),
                        itemCount: _filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = _filteredOrders[index];
                          return AdminOrderCard(
                            order: order,
                            onStatusTap: () => _showStatusUpdateSheet(
                              order['id'].toString(),
                              order['status'] as String? ??
                                  OrderStatus.waitingPayment,
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pesanan',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_orders.length} pesanan tercatat',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colors.card,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border),
            ),
            child: IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: colors.textPrimary,
                size: 20,
              ),
              tooltip: 'Muat ulang',
              onPressed: _fetchOrders,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColorScheme colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: colors.inputFill,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.receipt_long_rounded,
              size: 32,
              color: colors.textHint,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada pesanan di kategori ini.',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}