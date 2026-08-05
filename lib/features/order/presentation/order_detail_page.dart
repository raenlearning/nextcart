import 'package:flutter/material.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';

class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
          const SizedBox(height: 20),

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
                    _buildProductRow(colors, item),
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

  Widget _buildProductRow(AppColorScheme colors, Map<String, dynamic> item) {
    final product = item['products'] as Map<String, dynamic>?;
    final images = product?['images'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images[0] as String : null;
    final name = product?['name'] as String? ?? 'Produk Tidak Diketahui';
    final quantity = item['quantity'] as int? ?? 0;
    final priceAtPurchase = item['price_at_purchase'];

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
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