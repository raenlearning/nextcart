import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

/// Bottom sheet filter generik.
/// [options] adalah map dari value (nullable String) ke label yang ditampilkan.
/// Key `null` digunakan sebagai opsi "Semua".
class ProductFilterSheet extends StatelessWidget {
  final String title;
  final Map<String?, String> options;
  final String? selectedValue;
  final ValueChanged<String?> onSelected;

  const ProductFilterSheet({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Options
            ...options.entries.map(
              (entry) => _SheetOptionItem(
                label: entry.value,
                selected: selectedValue == entry.key,
                onTap: () {
                  onSelected(entry.key);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetOptionItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SheetOptionItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: selected ? AppColors.primary : context.colors.textPrimary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 18)
          : null,
    );
  }
}