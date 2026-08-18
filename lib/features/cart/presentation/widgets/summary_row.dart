import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final AppColorScheme colors;
  final bool isTotal;
  final Color? valueColor;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    required this.colors,
    this.isTotal = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: isTotal ? 15 : 13.5,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? colors.textPrimary,
            fontSize: isTotal ? 15 : 13.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
