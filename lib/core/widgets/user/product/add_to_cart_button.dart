import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/widgets/pressable_scale.dart';

class AddToCartButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddToCartButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.9,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.electricBlue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.electricBlue.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child:  Center(
          child: const FaIcon(
            FontAwesomeIcons.bagShopping,
            size: 14,
            color: Colors.white,
          
          ),
        )
      ),
    );
  }
}