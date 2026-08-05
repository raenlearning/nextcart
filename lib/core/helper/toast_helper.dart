// core/helper/toast_helper.dart
import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class ToastHelper {
  ToastHelper._();

  static void showTopToast(BuildContext context, String message) {
    final colors = context.colors;
    final overlay = Overlay.of(context);
    
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
              border: Border.all(color: colors.border.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      color: colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    // Hapus otomatis setelah 2 detik
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }
}