import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
import 'package:nextcart/features/cart/bloc/cart_bloc.dart';
import 'package:nextcart/features/cart/presentation/widgets/item_thumbnail.dart';
import 'package:nextcart/features/cart/presentation/widgets/quantity_stepper.dart';

class CartItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final AppColorScheme colors;

  const CartItemTile({super.key, required this.item, required this.colors});

  @override
  Widget build(BuildContext context) {
    final product = item['products'] as Map<String, dynamic>?;
    final images = product?['images'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images[0] as String : null;
    final price = (product?['price'] as num?) ?? 0;
    final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
    final int? stock = (product?['stock'] as num?)?.toInt();
    final itemId = item['id'] as String;
    final storeName = product?['store_name'] as String? ?? 'NextCart Store';
    final outOfStock = stock == 0;
    final atStockLimit = stock != null && stock > 0 && quantity >= stock;
    final isLowStock = stock != null && stock > 0 && stock <= 5;

    return Dismissible(
      key: ValueKey(itemId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) => context.read<CartBloc>().add(RemoveFromCart(itemId)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ItemThumbnail(imageUrl: imageUrl, colors: colors),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product?['name'] ?? 'Produk Terhapus',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    storeName,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  QuantityStepper(
                    quantity: quantity,
                    colors: colors,
                    incrementEnabled: !outOfStock && !atStockLimit,
                    onDecrement: () {
                      if (quantity > 1) {
                        context.read<CartBloc>().add(
                          UpdateCartQuantity(itemId, quantity - 1),
                        );
                      } else {
                        context.read<CartBloc>().add(RemoveFromCart(itemId));
                      }
                    },
                    onIncrement: () {
                      if (!outOfStock && !atStockLimit) {
                        context.read<CartBloc>().add(
                          UpdateCartQuantity(itemId, quantity + 1),
                        );
                      }
                    },
                  ),
                  if (outOfStock)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Stok habis, silakan hapus produk',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else if (isLowStock)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Stok tersisa $stock',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              CurrencyFormatter.rupiah(price),
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
