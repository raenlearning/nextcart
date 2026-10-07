import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/constants/store_info.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
import 'package:nextcart/core/helper/date_formatter.dart';
import 'package:nextcart/core/helper/toast_helper.dart';
import 'package:nextcart/core/helper/whatsapp_helper.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/theme/app_fonts.dart';
import 'package:nextcart/data/repository/review_repository.dart';
import 'package:nextcart/features/order/presentation/widgets/info_card.dart';
import 'package:nextcart/features/order/presentation/widgets/order_item_tile.dart';
import 'package:nextcart/features/order/presentation/widgets/order_timeline.dart';
import 'package:nextcart/features/order/presentation/widgets/payment_countdown.dart';
import 'package:nextcart/features/order/presentation/widgets/section_title.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderDetailPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Map<String, dynamic> _order = widget.order;
  bool _isConfirming = false;
  final ReviewRepository _reviewRepository = ReviewRepository();
  final Set<String> _reviewedProductIds = {};

  @override
  void initState() {
    super.initState();
    _loadReviewStatus();
  }

  Future<void> _loadReviewStatus() async {
    final items = _order['order_items'] as List<dynamic>? ?? [];
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final productIds = items
          .map((e) =>
              (e as Map<String, dynamic>)['products'] as Map<String, dynamic>?)
          .whereType<Map<String, dynamic>>()
          .map((p) => p['id'] as String?)
          .whereType<String>()
          .toSet();

      final data = await Supabase.instance.client
          .from('reviews')
          .select('product_id')
          .inFilter('product_id', productIds.toList())
          .eq('user_id', userId);

      final reviewed = (data as List)
          .map((e) => (e as Map<String, dynamic>)['product_id'] as String)
          .toSet();

      if (mounted) {
        setState(() => _reviewedProductIds.addAll(reviewed));
      }
    } catch (_) {
    }
  }

  Future<void> _reload() async {
    try {
      final data = await Supabase.instance.client
          .from('orders')
          .select('''
            id,
            total_amount,
            status,
            shipping_address,
            created_at,
            discount_amount,
            delivery_fee,
            tax_amount,
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
          .eq('id', widget.order['id'])
          .single();
      if (mounted) {
        setState(() => _order = Map<String, dynamic>.from(data));
      }
    } catch (_) {
    }
  }

  Future<void> _confirmReceived() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Terima Pesanan'),
        content: const Text(
          'Pastikan pesanan sudah benar-benar kamu terima dalam kondisi baik.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Terima',
              style: TextStyle(color: AppColors.success),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isConfirming = true);
    try {
      final result = await Supabase.instance.client.rpc(
        'confirm_order_received',
        params: {'p_order_id': widget.order['id']},
      );
      final map = Map<String, dynamic>.from(result as Map);
        if (mounted) {
        if (map['ok'] == true) {
          ToastHelper.showToast(context, 'Pesanan selesai. Terima kasih!', ToastSeverity.success);
          await _reload();
        } else {
          ToastHelper.showToast(
            context,
            map['error']?.toString() ?? 'Gagal konfirmasi pesanan.',
            ToastSeverity.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showToast(context, 'Gagal konfirmasi pesanan: ${e.toString()}', ToastSeverity.error);
      }
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final order = _order;

    final items = order['order_items'] as List<dynamic>? ?? [];
    final status = order['status'] as String? ?? OrderStatus.waitingPayment;
    final statusColor = OrderStatus.color(status);
    final createdAt = DateTime.tryParse(order['created_at'] ?? '');
    final orderId = order['id'].toString();

    final payment = order['payments'] as Map<String, dynamic>?;
    final paymentMethod = payment?['method'] as String?;
    final paidAt = payment?['paid_at'] != null
        ? DateTime.tryParse(payment!['paid_at'])
        : null;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text(
          'Detail Pesanan',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Hubungi toko',
            onPressed: () => WhatsAppHelper.openChat(
              'Halo ${StoreInfo.name}, saya ingin bertanya tentang pesanan '
              '#${widget.order['id'].toString().substring(0, 6)}.',
            ),
            icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 20),
            color: AppColors.success,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusCard(colors, statusColor, status),
          if (status == OrderStatus.waitingPayment && createdAt != null) ...[
            const SizedBox(height: 12),
            PaymentCountdown(createdAt: createdAt),
          ],
          const SizedBox(height: 20),

          if (status != OrderStatus.cancelled)
            OrderTimeline(currentStatus: status),
          const SizedBox(height: 20),

          if (status == OrderStatus.delivered) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isConfirming ? null : _confirmReceived,
                icon: _isConfirming
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline, size: 20),
                label: const Text('Terima Pesanan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          SectionTitle(colors: colors, title: 'Informasi Pesanan'),
          const SizedBox(height: 8),
          InfoCard(
            colors: colors,
            rows: [
              InfoRow(
                'No. Invoice',
                'INV/${orderId.substring(0, orderId.length >= 8 ? 8 : orderId.length)}',
              ),
              if (createdAt != null)
                InfoRow('Tanggal Pesan', formatDateTime(createdAt)),
              if (paymentMethod != null)
                InfoRow(
                  'Metode Bayar',
                  paymentMethod.replaceAll('_', ' ').toUpperCase(),
                ),
              if (paidAt != null)
                InfoRow('Dibayar Pada', formatDateTime(paidAt)),
            ],
          ),
          const SizedBox(height: 20),

          SectionTitle(colors: colors, title: 'Alamat Pengiriman'),
          const SizedBox(height: 8),
          _buildAddressCard(colors, order['shipping_address'] ?? '-'),
          const SizedBox(height: 20),

          SectionTitle(
            colors: colors,
            title: 'Produk Dipesan (${items.length})',
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: List.generate(items.length, (index) {
                final item = items[index] as Map<String, dynamic>;
                final isLast = index == items.length - 1;
                return Column(
                  children: [
                    OrderItemTile(
                      item: item,
                      status: status,
                      hasReviewed: _reviewedProductIds.contains(_productIdOf(item)),
                      onReview: _openReview,
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        color: colors.divider,
                        indent: 14,
                        endIndent: 14,
                      ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          SectionTitle(colors: colors, title: 'Ringkasan Pembayaran'),
          const SizedBox(height: 8),
          InfoCard(
            colors: colors,
            rows: [
              InfoRow('Subtotal', CurrencyFormatter.rupiah(_calculateSubtotal(items))),
              if ((order['discount_amount'] as num?) != null &&
                  (order['discount_amount'] as num) > 0)
                InfoRow(
                  'Voucher Diskon',
                  '- ${CurrencyFormatter.rupiah(order['discount_amount'])}',
                ),
              if ((order['delivery_fee'] as num?) != null &&
                  (order['delivery_fee'] as num) > 0)
                InfoRow(
                  'Biaya Pengiriman',
                  CurrencyFormatter.rupiah(order['delivery_fee']),
                ),
            ],
            footer: _buildTotalRow(colors, order['total_amount']),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    AppColorScheme colors,
    Color statusColor,
    String status,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: statusColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Status : ${OrderStatus.label(status)}',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AppColorScheme colors, String address) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.location_on_outlined,
            color: colors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              address,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(AppColorScheme colors, dynamic totalAmount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total Pembayaran',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        Text(
          CurrencyFormatter.rupiah(totalAmount),
          style: TextStyle(
            fontFamily: AppFonts.secondary,
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  String? _productIdOf(Map<String, dynamic> item) {
    final product = item['products'] as Map<String, dynamic>?;
    return product?['id'] as String?;
  }

  Future<void> _openReview(String productId) async {
    final hasReviewed = await _reviewRepository.hasAlreadyReviewed(productId);
    if (!mounted) return;

    if (hasReviewed) {
      await context.push('/review-list', extra: productId);
      return;
    }

    final result = await context.push<bool>('/review-form', extra: productId);
    if (result == true && mounted) {
      setState(() => _reviewedProductIds.add(productId));
    }
  }

  double _calculateSubtotal(List<dynamic> items) {
    double subtotal = 0;
    for (var item in items) {
      final map = item as Map<String, dynamic>;
      final price = (map['price_at_purchase'] as num).toDouble();
      final qty = map['quantity'] as int? ?? 0;
      subtotal += price * qty;
    }
    return subtotal;
  }
}
