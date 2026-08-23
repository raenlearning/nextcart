import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/helper/order_status_ui.dart';
import 'package:nextcart/core/theme/app_colors.dart';

void main() {
  group('statusLabel', () {
    test('maps known statuses to Indonesian labels', () {
      expect(OrderStatus.waitingPayment.statusLabel, 'Menunggu Bayar');
      expect(OrderStatus.processing.statusLabel, 'Diproses');
      expect(OrderStatus.delivered.statusLabel, 'Dikirim');
      expect(OrderStatus.completed.statusLabel, 'Selesai');
      expect(OrderStatus.cancelled.statusLabel, 'Dibatalkan');
    });

    test('uppercases unknown statuses with spaces replacing underscores', () {
      expect('on_the_way'.statusLabel, 'ON THE WAY');
    });
  });

  group('statusColor', () {
    test('maps each status to its semantic color', () {
      expect(OrderStatus.waitingPayment.statusColor, AppColors.warning);
      expect(OrderStatus.processing.statusColor, AppColors.primary);
      expect(OrderStatus.delivered.statusColor, AppColors.info);
      expect(OrderStatus.completed.statusColor, AppColors.success);
      expect(OrderStatus.cancelled.statusColor, AppColors.error);
    });

    test('falls back to slate500 for unknown status', () {
      expect('unknown'.statusColor, AppColors.slate500);
    });
  });

  group('statusIcon', () {
    test('returns distinct icons for each status', () {
      expect(OrderStatus.waitingPayment.statusIcon, Icons.hourglass_empty_rounded);
      expect(OrderStatus.processing.statusIcon, Icons.local_shipping_rounded);
      expect(OrderStatus.delivered.statusIcon, Icons.inventory_2_rounded);
      expect(OrderStatus.completed.statusIcon, Icons.check_circle_rounded);
      expect(OrderStatus.cancelled.statusIcon, Icons.cancel_rounded);
    });

    test('falls back to receipt icon for unknown status', () {
      expect('unknown'.statusIcon, Icons.receipt_long_rounded);
    });
  });

  group('isActionable', () {
    test('true for statuses admin can still change', () {
      expect(OrderStatus.processing.isActionable, isTrue);
      expect(OrderStatus.delivered.isActionable, isTrue);
      expect(OrderStatus.completed.isActionable, isTrue);
    });

    test('false for waiting_payment and cancelled', () {
      expect(OrderStatus.waitingPayment.isActionable, isFalse);
      expect(OrderStatus.cancelled.isActionable, isFalse);
    });
  });

  group('OrderStatus static helpers', () {
    test('label matches extension behavior', () {
      expect(OrderStatus.label(OrderStatus.completed), 'Selesai');
    });

    test('color matches extension behavior', () {
      expect(OrderStatus.color(OrderStatus.completed), AppColors.success);
    });

    test('all lists all five statuses', () {
      expect(OrderStatus.all, [
        OrderStatus.waitingPayment,
        OrderStatus.processing,
        OrderStatus.delivered,
        OrderStatus.completed,
        OrderStatus.cancelled,
      ]);
    });
  });
}