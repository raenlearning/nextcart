import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/theme/app_fonts.dart';
import 'package:nextcart/core/widgets/bento_tile.dart';

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

String formatCompactCount(int v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return '$v';
}

class AdminRevenueTile extends StatelessWidget {
  final double grossRevenue;

  const AdminRevenueTile({super.key, required this.grossRevenue});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BentoTile(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Laporan Penjualan',
                style: TextStyle(
                  fontSize: 10.5,
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            formatCompactRupiah(grossRevenue),
            style: TextStyle(
              fontFamily: AppFonts.secondary,
              color: colors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              height: 1.0,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                'Real-time',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'Updated just now',
                style: TextStyle(
                  fontSize: 9,
                  color: colors.textHint,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AdminStatTile extends StatelessWidget {
  final FaIconData icon;
  final Color color;
  final String label;
  final String value;
  final bool alert;
  final VoidCallback? onTap;

  const AdminStatTile({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.alert = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BentoTile(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: alert ? AppColors.error.withValues(alpha: 0.08) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 16, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.secondary,
              color: alert ? AppColors.error : colors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.0,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: alert ? AppColors.error : colors.textSecondary,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminChartTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const AdminChartTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BentoTile(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: colors.textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
