import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: () => context.push('/view-all', extra: {'focusSearch': true}),
      borderRadius: BorderRadius.circular(16),
      child: IgnorePointer(
        child: TextField(
          enabled: false,
          style: TextStyle(color: colors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Cari produk teknologi...',
            hintStyle: TextStyle(color: colors.textHint, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: colors.textSecondary),
            filled: true,
            fillColor: colors.inputFill,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}