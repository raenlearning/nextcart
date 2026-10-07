import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class ProductEmptyState extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onAdd;
  final VoidCallback onReset;

  const ProductEmptyState({
    super.key,
    required this.hasFilter,
    required this.onAdd,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hasFilter ? 'Tidak ada hasil' : 'Belum ada produk',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilter
                  ? 'Coba ubah filter atau kata kunci pencarian.'
                  : 'Mulai tambahkan produk pertama ke toko.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: context.colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: hasFilter ? onReset : onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                hasFilter ? 'Reset Filter' : 'Tambah Produk',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}