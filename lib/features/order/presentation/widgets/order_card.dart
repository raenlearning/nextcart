import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
import 'package:nextcart/core/helper/date_formatter.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/features/order/presentation/widgets/order_action_button.dart';
import 'package:nextcart/features/order/presentation/widgets/status_pill.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final AppColorScheme colors;

  const OrderCard({super.key, required this.order, required this.colors});

  @override
  Widget build(BuildContext context) {
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
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: colors.inputFill,
                borderRadius: BorderRadius.circular(14),
                image: imageUrl != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(imageUrl),
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

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          StatusPill(
                            label: OrderStatus.label(status),
                            color: statusColor,
                          ),
                          if (paymentStatus == 'settlement') ...[
                            const SizedBox(width: 6),
                            const StatusPill(label: 'Dibayar', color: AppColors.success),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${createdAt != null ? formatDate(createdAt) : ''} · ${items.length} item',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                      OrderActionButton(
                        status: status,
                        order: order,
                        colors: colors,
                      ),
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
}
