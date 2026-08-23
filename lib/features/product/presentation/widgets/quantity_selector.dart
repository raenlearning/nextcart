import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/theme/app_fonts.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final int stock;
  final AppColorScheme colors;
  final ValueChanged<int> onChanged;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.stock,
    required this.colors,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final outOfStock = stock <= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, size: 20, color: colors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              outOfStock ? 'Stok habis' : 'Stok: $stock',
              style: TextStyle(
                fontFamily: AppFonts.secondary,
                color: outOfStock
                    ? AppColors.error
                    : (stock <= 5 ? AppColors.warning : colors.textSecondary),
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          _QtyStepBtn(
            icon: Icons.remove_rounded,
            colors: colors,
            enabled: quantity > 1,
            onTap: () => onChanged(quantity - 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$quantity',
              style: TextStyle(
                fontFamily: AppFonts.secondary,
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          _QtyStepBtn(
            icon: Icons.add_rounded,
            colors: colors,
            enabled: !outOfStock && quantity < stock,
            onTap: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _QtyStepBtn extends StatelessWidget {
  final IconData icon;
  final AppColorScheme colors;
  final bool enabled;
  final VoidCallback onTap;

  const _QtyStepBtn({
    required this.icon,
    required this.colors,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? colors.inputFill
              : colors.inputFill.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? colors.textPrimary : colors.textHint,
        ),
      ),
    );
  }
}