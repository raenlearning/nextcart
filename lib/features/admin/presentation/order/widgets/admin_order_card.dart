import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/theme/app_fonts.dart';
import 'package:nextcart/features/admin/presentation/order/widgets/order_status_action_button.dart';

class AdminOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onStatusTap;

  const AdminOrderCard({
    super.key,
    required this.order,
    required this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 5,
                  ),
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
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (paymentMethod != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
                  final imageUrl =
                      images.isNotEmpty ? images[0] as String : null;

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
                                    image: CachedNetworkImageProvider(imageUrl),
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
                                  fontFamily: AppFonts.secondary,
                                  color: colors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFeatures: const [FontFeature.tabularFigures()],
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
                              fontFamily: AppFonts.secondary,
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              letterSpacing: -0.3,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 140,
                      child: OrderStatusActionButton(
                        status: status,
                        onPressed: onStatusTap,
                      ),
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
}