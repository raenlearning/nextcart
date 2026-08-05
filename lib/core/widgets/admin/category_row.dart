
import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class CategoryRow extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String? selectedId;
  final VoidCallback onAdd;

  const CategoryRow({super.key, 
    required this.categories,
    required this.selectedId,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, String> nameById = {
      for (final c in categories) c['id'] as String: c['name'] as String,
    };
    final String? selectedName = selectedId != null
        ? nameById[selectedId]
        : null;

    return GestureDetector(
      onTap: onAdd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: context.colors.inputFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedName ?? 'Tambah Kategori',
                style: TextStyle(
                  fontSize: 14,
                  color: selectedName != null
                      ? context.colors.textPrimary
                      : context.colors.textHint,
                ),
              ),
            ),
            const Icon(Icons.add_rounded, color: AppColors.primary, size: 18),
            const SizedBox(width: 2),
            const Text(
              'Tambah',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}