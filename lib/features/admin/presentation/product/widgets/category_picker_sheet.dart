import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class CategoryPickerSheet extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String? selectedId;

  const CategoryPickerSheet({
    super.key,
    required this.categories,
    required this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text(
              'Pilih Kategori',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final id = cat['id'] as String;
                  final name = cat['name'] as String;
                  final isSelected = selectedId == id;
                  return ListTile(
                    onTap: () {
                      Navigator.pop(context, id);
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected
                            ? AppColors.primary
                            : context.colors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.primary,
                            size: 18,
                          )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}