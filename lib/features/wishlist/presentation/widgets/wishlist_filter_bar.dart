import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/features/wishlist/presentation/widgets/filter_chip.dart';

class WishlistFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final List<Map<String, dynamic>> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategoryTap;
  final String sortBy;
  final ValueChanged<String?> onSortChanged;

  const WishlistFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryTap,
    required this.sortBy,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari di wishlist...',
              hintStyle: TextStyle(color: colors.textHint, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: colors.textHint, size: 20),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: searchController,
                builder: (context, value, _) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: Icon(Icons.clear, color: colors.textHint, size: 18),
                    onPressed: onClearSearch,
                  );
                },
              ),
              filled: true,
              fillColor: colors.inputFill,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return WishlistFilterChip(
                          label: 'Semua',
                          isActive: selectedCategoryId == null,
                          onTap: () => onCategoryTap(null),
                        );
                      }
                      final cat = categories[index - 1];
                      final id = cat['id'] as String;
                      return WishlistFilterChip(
                        label: cat['name'] as String,
                        isActive: selectedCategoryId == id,
                        onTap: () => onCategoryTap(id),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: colors.inputFill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: sortBy,
                    dropdownColor: colors.card,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: colors.textSecondary,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'newest',
                        child: Text('Terbaru'),
                      ),
                      DropdownMenuItem(
                        value: 'price_low',
                        child: Text('Termurah'),
                      ),
                      DropdownMenuItem(
                        value: 'price_high',
                        child: Text('Termahal'),
                      ),
                    ],
                    onChanged: onSortChanged,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}