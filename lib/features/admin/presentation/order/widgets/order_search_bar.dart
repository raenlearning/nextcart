import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class OrderSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool hasQuery;
  final VoidCallback onClear;

  const OrderSearchBar({
    super.key,
    required this.controller,
    required this.hasQuery,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withAlpha(6),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Cari nama pembeli atau ID pesanan...',
          hintStyle: TextStyle(
            color: colors.textHint,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colors.textSecondary,
            size: 21,
          ),
          suffixIcon: hasQuery
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: colors.textSecondary,
                    size: 18,
                  ),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}