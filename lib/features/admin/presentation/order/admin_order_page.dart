import 'package:flutter/material.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';

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

      final data = await query.order('created_at', ascending: false);

      setState(() {
        _orders = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
        _applyLocalFilter();
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
    try {
      await _supabase
          .from('orders')
          .update({'status': newStatus})
          .eq('id', orderId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status pesanan berhasil diperbarui menjadi $newStatus',
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
    final colors = context.colors;

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
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final availableStatuses = [
          OrderStatus.processing,
          OrderStatus.delivered,
          OrderStatus.completed,
        ];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                child: Row(
                  children: [
                    Text(
                      'Ubah Status Pengiriman',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: availableStatuses.map((status) {
                    final isSelected = status == currentStatus;
                    final statusColor = OrderStatus.color(status);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          if (!isSelected) {
                            _updateOrderStatus(orderId, status);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? statusColor.withValues(alpha: 0.10)
                                : colors.inputFill,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? statusColor : colors.border,
                              width: isSelected ? 1.4 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  OrderStatus.label(status),
                                  style: TextStyle(
                                    color: isSelected ? statusColor : colors.textPrimary,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle_rounded, color: statusColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
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
            _buildSearchBar(colors),
            const SizedBox(height: 4),
            _buildStatusChips(colors),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.4),
                    )
                  : _filteredOrders.isEmpty
                  ? _buildEmptyState(colors)
                  : RefreshIndicator(
                      color: Colors.black,
                      onRefresh: _fetchOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                        itemCount: _filteredOrders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(colors, _filteredOrders[index]);
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
                  'Kelola Pesanan',
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
              icon: Icon(Icons.refresh_rounded, color: colors.textPrimary, size: 20),
              tooltip: 'Muat ulang',
              onPressed: _fetchOrders,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withAlpha(6),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Cari nama pembeli atau ID pesanan...',
            hintStyle: TextStyle(color: colors.textHint, fontSize: 13.5, fontWeight: FontWeight.w500),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colors.textSecondary,
              size: 21,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: colors.textSecondary,
                      size: 18,
                    ),
                    onPressed: () => _searchController.clear(),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChips(AppColorScheme colors) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _statuses.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = _statuses[index];
          final isSelected = status == _selectedStatus;
          final chipColor = status == 'all' ? Colors.black : OrderStatus.color(status);

          return GestureDetector(
            onTap: () => _onStatusChipTap(status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? chipColor : colors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? chipColor : colors.border,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (status != 'all') ...[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : chipColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    OrderStatus.label(status),
                    style: TextStyle(
                      color: isSelected ? Colors.white : colors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
            decoration: BoxDecoration(color: colors.inputFill, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(Icons.receipt_long_rounded, size: 32, color: colors.textHint),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada pesanan di kategori ini.',
            style: TextStyle(color: colors.textSecondary, fontSize: 13.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(AppColorScheme colors, Map<String, dynamic> order) {
    final buyer = order['profiles'] as Map<String, dynamic>?;
    final items = order['order_items'] as List<dynamic>? ?? [];
    final status = order['status'] as String? ?? OrderStatus.waitingPayment;
    final statusColor = OrderStatus.color(status);

    final payment = order['payments'] as Map<String, dynamic>?;
    final paymentMethod = payment?['method'] as String?;

    final orderId = order['id'].toString();
    final shortId = orderId.length >= 8 ? orderId.substring(0, 8) : orderId;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withAlpha(8),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID + status badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'INV/$shortId',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    OrderStatus.label(status),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: colors.divider),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info pembeli
                Text(
                  buyer?['full_name'] ?? 'User Terhapus',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  order['shipping_address'] ?? '-',
                  style: TextStyle(color: colors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (paymentMethod != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.inputFill,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 13,
                          color: colors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          paymentMethod.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            color: colors.textHint,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                ...items.take(2).map((item) {
                  final product = item['products'] as Map<String, dynamic>?;
                  final images = product?['images'] as List<dynamic>? ?? [];
                  final imageUrl = images.isNotEmpty ? images[0] as String : null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: colors.inputFill,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.border),
                            image: imageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(imageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: imageUrl == null
                              ? Icon(
                                  Icons.shopping_bag_rounded,
                                  color: colors.textSecondary,
                                  size: 19,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product?['name'] ?? 'Produk Tidak Diketahui',
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '${item['quantity']} x ${CurrencyFormatter.rupiah(item['price_at_purchase'])}',
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                if (items.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '+ ${items.length - 2} produk lainnya',
                      style: TextStyle(
                        color: colors.textHint,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                Divider(height: 24, color: colors.divider),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Pembayaran',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyFormatter.rupiah(order['total_amount']),
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 140,
                      child: _buildActionButton(status, orderId),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String status, String orderId) {
    String label;
    IconData icon;
    Color color;

    switch (status) {
      case OrderStatus.waitingPayment:
        label = 'Menunggu Bayar';
        icon = Icons.hourglass_empty_rounded;
        color = AppColors.slate400;
        break;
      case OrderStatus.processing:
        label = 'Proses Kirim';
        icon = Icons.local_shipping_rounded;
        color = Colors.black;
        break;
      case OrderStatus.delivered:
        label = 'Selesaikan';
        icon = Icons.inventory_2_rounded;
        color = AppColors.info;
        break;
      case OrderStatus.completed:
        label = 'Selesai';
        icon = Icons.check_circle_rounded;
        color = AppColors.success;
        break;
      case OrderStatus.cancelled:
        label = 'Dibatalkan';
        icon = Icons.cancel_rounded;
        color = AppColors.slate400;
        break;
      default:
        label = 'Ubah Status';
        icon = Icons.edit_road_rounded;
        color = Colors.black;
    }

    final isDisabled =
        status == OrderStatus.waitingPayment || status == OrderStatus.cancelled;

    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: () => _showStatusUpdateSheet(orderId, status),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? color.withValues(alpha: 0.14) : color,
          foregroundColor: isDisabled ? color : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        icon: Icon(icon, size: 15),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}