import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
import 'package:nextcart/features/cart/bloc/cart_bloc.dart';
import 'package:nextcart/features/cart/presentation/widgets/summary_row.dart';

class PriceSummary extends StatelessWidget {
  final double subtotal;
  final Map<String, dynamic>? voucher;
  final double shippingFee;
  final AppColorScheme colors;

  const PriceSummary({
    super.key,
    required this.subtotal,
    required this.voucher,
    required this.shippingFee,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final discount =
        context.read<CartBloc>().calculateDiscount(subtotal, voucher);
    final double deliveryFee = shippingFee;
    final double total = subtotal > 0 ? subtotal - discount + deliveryFee : 0;

    return Column(
      children: [
        SummaryRow(
          label: 'Voucher Diskon',
          value: CurrencyFormatter.rupiah(discount),
          colors: colors,
          valueColor: AppColors.success,
        ),
        const SizedBox(height: 10),
        SummaryRow(
          label: 'Biaya Pengiriman',
          value: CurrencyFormatter.rupiah(deliveryFee),
          colors: colors,
          valueColor: AppColors.sale,
        ),
        const SizedBox(height: 10),
        SummaryRow(
          label: 'Total',
          value: CurrencyFormatter.rupiah(total),
          colors: colors,
          isTotal: true,
        ),
      ],
    );
  }
}
