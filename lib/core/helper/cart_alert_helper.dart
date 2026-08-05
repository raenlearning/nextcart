// core/helper/cart_alert_helper.dart
import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class CartAlertHelper {
  CartAlertHelper._();

  static void showSuccessBottomSheet({
    required BuildContext context,
    required String productName,
    required String? imageUrl,
  }) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colors.inputFill,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.border),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.broken_image_outlined,
                              color: colors.textHint,
                              size: 28,
                            ),
                          )
                        : Icon(
                            Icons.shopping_bag_outlined,
                            color: colors.textHint,
                            size: 28,
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: colors.card,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Teks Informasi Sukses
              Text(
                'Berhasil Ditambahkan!',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  color: colors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
