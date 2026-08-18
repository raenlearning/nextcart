import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class LowStockBadge extends StatelessWidget {
  const LowStockBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, color: AppColors.rating, size: 11),
          SizedBox(width: 3),
          Text(
            'Stok Menipis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}