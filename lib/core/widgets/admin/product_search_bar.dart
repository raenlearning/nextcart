import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class ProductSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasActiveFilter;
  final VoidCallback onFilterTap;

  const ProductSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hasActiveFilter,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: context.colors.inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focusNode.hasFocus ? AppColors.primary : context.colors.border,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(color: context.colors.textPrimary, fontSize: 12.5),
        decoration: InputDecoration(
          hintText: 'Cari Produk...',
          hintStyle:
              TextStyle(color: context.colors.textSecondary, fontSize: 12.8),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18,
            color: context.colors.textHint,
          ),
          suffixIcon: InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(16),
            child: Icon(
              Icons.tune_rounded,
              size: 18,
              color: hasActiveFilter ? AppColors.primary : context.colors.textHint,
            ),
          ),
        ),
      ),
    );
  }
}