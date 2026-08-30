import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class TabItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const TabItem({super.key, 
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: selected ? context.colors.background : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: selected ? context.colors.textPrimary : context.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}