import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
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
      // Abaikan; tetap pakai data lama.
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
            child: const Text('Terima', style: TextStyle(color: AppColors.success)),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan selesai. Terima kasih!'),
              backgroundColor: AppColors.success,
            ),
          );
          await _reload();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(map['error']?.toString() ?? 'Gagal konfirmasi pesanan.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal konfirmasi pesanan: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
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
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status card
          Container(
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
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          if (status == OrderStatus.waitingPayment && createdAt != null) ...[
            const SizedBox(height: 12),
            _PaymentCountdown(createdAt: createdAt),
          ],
          const SizedBox(height: 20),

          if (status != OrderStatus.cancelled)
            _OrderTimeline(currentStatus: status),
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

          _buildSectionTitle(colors, 'Informasi Pesanan'),

          const SizedBox(height: 8),
          
          _buildInfoCard(colors, [
            _InfoRow('No. Invoice', 'INV/${orderId.substring(0, orderId.length >= 8 ? 8 : orderId.length)}'),
            if (createdAt != null) _InfoRow('Tanggal Pesan', _formatDateTime(createdAt)),
            if (paymentMethod != null) _InfoRow('Metode Bayar', paymentMethod.replaceAll('_', ' ').toUpperCase()),
            if (paidAt != null) _InfoRow('Dibayar Pada', _formatDateTime(paidAt)),
          ]),
          const SizedBox(height: 20),

          _buildSectionTitle(colors, 'Alamat Pengiriman'),
          const SizedBox(height: 8),
          Container(
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
                Icon(Icons.location_on_outlined, color: colors.textSecondary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    order['shipping_address'] ?? '-',
                    style: TextStyle(color: colors.textPrimary, fontSize: 13.5, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionTitle(colors, 'Produk Dipesan (${items.length})'),
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
                    _buildProductRow(colors, item, status: status),
                    if (!isLast) Divider(height: 1, color: colors.divider, indent: 14, endIndent: 14),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionTitle(colors, 'Ringkasan Pembayaran'),
          const SizedBox(height: 8),
_buildInfoCard(colors, [
              _InfoRow(
                'Subtotal',
                CurrencyFormatter.rupiah(_calculateSubtotal(items)),
              ),
              if ((order['discount_amount'] as num?) != null &&
                  (order['discount_amount'] as num) > 0)
                _InfoRow(
                  'Voucher Diskon',
                  '- ${CurrencyFormatter.rupiah(order['discount_amount'])}',
                ),
              if ((order['delivery_fee'] as num?) != null &&
                  (order['delivery_fee'] as num) > 0)
                _InfoRow(
                  'Biaya Pengiriman',
                  CurrencyFormatter.rupiah(order['delivery_fee']),
                ),
              if ((order['tax_amount'] as num?) != null &&
                  (order['tax_amount'] as num) > 0)
                _InfoRow(
                  'PPN (11%)',
                  CurrencyFormatter.rupiah(order['tax_amount']),
                ),
            ], footer: _buildTotalRow(colors, order['total_amount'])),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(AppColorScheme colors, String title) {
    return Text(
      title,
      style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  Widget _buildInfoCard(AppColorScheme colors, List<_InfoRow> rows, {Widget? footer}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          ...rows.map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(row.label, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
                    Flexible(
                      child: Text(
                        row.value,
                        textAlign: TextAlign.right,
                        style: TextStyle(color: colors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              )),
          if (footer != null) ...[
            Divider(height: 20, color: colors.divider),
            footer,
          ],
        ],
      ),
    );
  }

  Widget _buildTotalRow(AppColorScheme colors, dynamic totalAmount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Total Pembayaran', style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(
          CurrencyFormatter.rupiah(totalAmount),
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildProductRow(AppColorScheme colors, Map<String, dynamic> item, {String status = ''}) {
    final product = item['products'] as Map<String, dynamic>?;
    final images = product?['images'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images[0] as String : null;
    final name = product?['name'] as String? ?? 'Produk Tidak Diketahui';
    final quantity = item['quantity'] as int? ?? 0;
    final priceAtPurchase = item['price_at_purchase'];
    final productId = product?['id'] as String?;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.inputFill,
                  borderRadius: BorderRadius.circular(10),
                  image: imageUrl != null
                      ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: imageUrl == null
                    ? Icon(Icons.shopping_bag_outlined, color: colors.textSecondary, size: 22)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$quantity x ${CurrencyFormatter.rupiah(priceAtPurchase)}',
                      style: TextStyle(color: colors.textSecondary, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              Text(
                CurrencyFormatter.rupiah((priceAtPurchase as num) * quantity),
                style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
            ],
          ),
          if (status == OrderStatus.completed && productId != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => context.push('/review-form', extra: productId),
                icon: const Icon(Icons.rate_review_outlined, size: 16),
                label: const Text('Beri Ulasan'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
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

  String _formatDateTime(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow {
  final String label;
  final String value;
  _InfoRow(this.label, this.value);
}

class _PaymentCountdown extends StatefulWidget {
  final DateTime createdAt;
  const _PaymentCountdown({required this.createdAt});

  @override
  State<_PaymentCountdown> createState() => _PaymentCountdownState();
}

class _PaymentCountdownState extends State<_PaymentCountdown> {
  late final DateTime _deadline = widget.createdAt.add(const Duration(hours: 2));
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final remaining = _deadline.difference(DateTime.now());
    final expired = remaining.isNegative;

    if (expired) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.timer_off_outlined, color: AppColors.warning, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Waktu pembayaran telah habis. Pesanan akan dibatalkan otomatis.',
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);
    String two(int v) => v.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: AppColors.warning, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Selesaikan pembayaran dalam',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${two(hours)}:${two(minutes)}:${two(seconds)}',
            style: const TextStyle(
              color: AppColors.warning,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  final String currentStatus;

  const _OrderTimeline({required this.currentStatus});

  static const _steps = [
    OrderStatus.waitingPayment,
    OrderStatus.processing,
    OrderStatus.delivered,
    OrderStatus.completed,
  ];

  int get _currentIndex {
    final idx = _steps.indexOf(currentStatus);
    return idx >= 0 ? idx : 0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Pesanan',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _steps.length; i++) ...[
            _TimelineItem(
              step: _steps[i],
              isDone: i < _currentIndex,
              isCurrent: i == _currentIndex,
              isFirst: i == 0,
              isLast: i == _steps.length - 1,
            ),
            if (i != _steps.length - 1) const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String step;
  final bool isDone;
  final bool isCurrent;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({
    required this.step,
    required this.isDone,
    required this.isCurrent,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final stepColor = OrderStatus.color(step);
    final color = isDone || isCurrent
        ? stepColor
        : colors.textHint.withValues(alpha: 0.4);
    final topLineColor = isDone || isCurrent ? stepColor : colors.divider;
    final bottomLineColor = isDone ? stepColor : colors.divider;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Column(
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: 6,
                  color: topLineColor,
                ),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent ? color : (isDone ? color : colors.card),
                  border: Border.all(color: color, width: isCurrent ? 5 : 2),
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 6,
                  color: bottomLineColor,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              OrderStatus.label(step),
              style: TextStyle(
                color: isDone || isCurrent
                    ? colors.textPrimary
                    : colors.textHint,
                fontSize: 13,
                fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
        if (isCurrent)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Saat ini',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}