import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/theme/app_fonts.dart';
import 'package:nextcart/features/cart/presentation/widgets/step_btn.dart';

class QuantityStepper extends StatelessWidget {
  final int quantity;
  final AppColorScheme colors;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool incrementEnabled;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.colors,
    required this.onDecrement,
    required this.onIncrement,
    this.incrementEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StepBtn(icon: Icons.remove, onTap: onDecrement, colors: colors),
          SizedBox(
            width: 24,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.secondary,
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          StepBtn(
            icon: Icons.add,
            onTap: onIncrement,
            colors: colors,
            enabled: incrementEnabled,
          ),
        ],
      ),
    );
  }
}
