import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class OrderStatusTabs extends StatelessWidget {
  final TabController controller;
  final AppColorScheme colors;

  const OrderStatusTabs({
    super.key,
    required this.controller,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: colors.textPrimary,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: colors.background,
        unselectedLabelColor: colors.textPrimary.withValues(alpha: 0.6),
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        tabs: const [
          Tab(text: "Aktif"),
          Tab(text: "Selesai"),
          Tab(text: "Dibatalkan"),
        ],
      ),
    );
  }
}
