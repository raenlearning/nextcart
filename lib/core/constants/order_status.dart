import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class OrderStatus {
  static const waitingPayment = 'waiting_payment';
  static const processing = 'processing';
  static const delivered = 'delivered';
  static const completed = 'completed';
  static const cancelled = 'cancelled';

  static const all = [waitingPayment, processing, delivered, completed, cancelled];

  static Color color(String status) {
    switch (status) {
      case waitingPayment: return AppColors.warning;
      case processing: return AppColors.primary;
      case delivered: return AppColors.info;
      case completed: return AppColors.success;
      case cancelled: return AppColors.error;
      default: return AppColors.slate500;
    }
  }

  static String label(String status) {
    switch (status) {
      case waitingPayment: return 'Menunggu Bayar';
      case processing: return 'Diproses';
      case delivered: return 'Dikirim';
      case completed: return 'Selesai';
      case cancelled: return 'Dibatalkan';
      default: return status.replaceAll('_', ' ').toUpperCase();
    }
  }
}