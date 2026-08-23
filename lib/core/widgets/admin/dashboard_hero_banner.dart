import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/theme/app_fonts.dart';
import 'package:nextcart/core/widgets/admin/real_time_bar_chart.dart';

class DashboardHeroBanner extends StatelessWidget {
  final double grossRevenue;
  final int completedOrders;
  final int totalProducts;
  final int totalUsers;
  final List<Map<String, dynamic>> revenueChart;

  const DashboardHeroBanner({
    super.key,
    required this.grossRevenue,
    required this.completedOrders,
    required this.totalProducts,
    required this.totalUsers,
    this.revenueChart = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.card,
            colors.card,
            AppColors.primary.withAlpha(context.isDark ? 18 : 10),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withAlpha(14),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                "Laporan Penjualan",
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            formatCompactRupiah(grossRevenue),
            style: TextStyle(
              fontFamily: AppFonts.secondary,
              color: colors.textPrimary,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              height: 1.0,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 22),

          Row(
            children: [
              _HeroMetric(
                icon: FontAwesomeIcons.clipboardList,
                value: '$completedOrders',
                label: 'Pesanan',
              ),
              _HeroDivider(),
              _HeroMetric(
                icon: FontAwesomeIcons.users,
                value: _formatCompact(totalUsers),
                label: 'Total Pengguna',
              ),
              _HeroDivider(),
              _HeroMetric(
                icon: FontAwesomeIcons.bagShopping,
                value: _formatCompact(totalProducts),
                label: 'Produk Terjual',
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: colors.divider, height: 1),
          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 7),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                'Real-time',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
              const Spacer(),
              Text(
                'Updated just now',
                style: TextStyle(
                  fontSize: 11,
                  color: colors.textHint,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          RealTimeBarChart(data: revenueChart),
        ],
      ),
    );
  }

  String formatCompactRupiah(double value) {
    if (value >= 1000000000000) {
      return 'Rp ${(value / 1000000000000).toStringAsFixed(1)} T';
    }
    if (value >= 1000000000) {
      return 'Rp ${(value / 1000000000).toStringAsFixed(1)} M';
    }
    if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)} Jt';
    }
    if (value >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(1)} Rb';
    }
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  String _formatCompact(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }
}

class _HeroMetric extends StatelessWidget {
  final FaIconData icon;
  final String value;
  final String label;

  const _HeroMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FaIcon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 34,
    color: context.colors.divider,
    margin: const EdgeInsets.only(right: 16),
  );
}