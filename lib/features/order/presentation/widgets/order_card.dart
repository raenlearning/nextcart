import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
import 'package:nextcart/core/helper/date_formatter.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/theme/app_fonts.dart';
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

    final secondItem = items.length > 1
        ? items[1] as Map<String, dynamic>
        : null;
    final secondProduct = secondItem?['products'] as Map<String, dynamic>?;
    final secondImages = secondProduct?['images'] as List<dynamic>? ?? [];
    final secondImageUrl = secondImages.isNotEmpty ? secondImages[0] as String : null;

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
            SizedBox(
              width: 68,
              height: 68,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 62,
                    height: 62,
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
                  if (secondImageUrl != null)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.divider, width: 1),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(secondImageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  else if (items.length > 1)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.divider, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            '+${items.length - 1}',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
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
                          fontSize: 14,
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
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyFormatter.rupiah(order['total_amount']),
                        style: TextStyle(
                          fontFamily: AppFonts.secondary,
                          color: colors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFeatures: const [FontFeature.tabularFigures()],
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
