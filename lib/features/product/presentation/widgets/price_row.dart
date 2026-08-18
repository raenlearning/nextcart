import 'package:flutter/material.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class PriceRow extends StatelessWidget {
  final double price;
  final AppColorScheme colors;

  const PriceRow({super.key, required this.price, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Harga',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.rupiah(price),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.price,
                height: 1.1,
              ),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                'termasuk PPN',
                style: TextStyle(
                  fontSize: 11,
                  color: colors.textHint,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}