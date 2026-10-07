import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class OrderSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final AppColorScheme colors;

  const OrderSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: TextStyle(color: colors.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Cari pesanan berdasarkan produk...',
        hintStyle: TextStyle(color: colors.textHint, fontSize: 13),
        prefixIcon: Icon(
          Icons.search,
          size: 20,
          color: colors.textSecondary,
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: Icon(Icons.clear, size: 18, color: colors.textSecondary),
              onPressed: () {
                controller.clear();
                onChanged('');
              },
            );
          },
        ),
        filled: true,
        fillColor: colors.inputFill,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}