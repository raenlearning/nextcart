import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nextcart/core/theme/app_colors.dart';

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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: colors.inputFill,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hari Ini',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            formatCompactRupiah(grossRevenue),
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 22),

          // 3 quick metrics
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

class PeriodFilterTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const PeriodFilterTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _periods = ['24h', '7d', '30d', '6m', '1y'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: _periods.map((p) {
          final isActive = p == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(70),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  p,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : colors.textSecondary,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class RealTimeBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const RealTimeBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (data.isEmpty) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'Belum ada data.',
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
        ),
      );
    }

    final amounts = data.map((d) => (d['amount'] as double)).toList();
    final maxY = amounts.reduce((a, b) => a > b ? a : b);
    final step = (data.length / 6).ceil();
    final barWidth = data.length > 30 ? 3.0 : (data.length > 12 ? 6.0 : 10.0);

    return SizedBox(
      height: 140,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY == 0 ? 10 : maxY * 1.2,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: step.toDouble(),
                reservedSize: 22,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= data.length) {
                    return const SizedBox.shrink();
                  }
                  final raw = data[idx]['date'] as String;
                  final date = DateTime.parse(raw);
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('d/M').format(date),
                      style: TextStyle(
                        color: colors.textHint,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) =>
                  context.isDark ? AppColors.slate700 : Colors.white,
              tooltipBorderRadius: BorderRadius.circular(10),
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                _fmt(rod.toY),
                const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          barGroups: List.generate(data.length, (i) {
            final value = amounts[i];
            final ratio = maxY == 0 ? 0.0 : value / maxY;
            final Color barColor;
            if (ratio > 0.66) {
              barColor = AppColors.success;
            } else if (ratio > 0.33) {
              barColor = AppColors.warning;
            } else if (ratio > 0) {
              barColor = AppColors.error;
            } else {
              barColor = colors.inputFill;
            }
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: value,
                  color: barColor,
                  width: barWidth,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

class OrderStatusChart extends StatelessWidget {
  final Map<String, int> statusBreakdown;

  const OrderStatusChart({super.key, required this.statusBreakdown});

  static const _colors = {
    'pending': AppColors.warning,
    'processing': AppColors.info,
    'delivered': AppColors.secondary,
    'completed': AppColors.success,
    'cancelled': AppColors.error,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = statusBreakdown.values.fold(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withAlpha(8),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.donut_large_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'Status Pesanan',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: colors.textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (total == 0)
            Center(
              child: Text(
                'Belum ada pesanan.',
                style: TextStyle(color: colors.textSecondary),
              ),
            )
          else
            ...statusBreakdown.entries.map((e) {
              final pct = e.value / total;
              final color = _colors[e.key] ?? AppColors.slate300;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withAlpha(90),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 9),
                        Text(
                          _capitalize(e.key),
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${e.value}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${(pct * 100).toStringAsFixed(0)}%)',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: colors.inputFill,
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 7,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─── Product Rating (top products) with tabs, matching reference design ─────

class TopProductsList extends StatefulWidget {
  final List<Map<String, dynamic>> products;

  const TopProductsList({super.key, required this.products});

  @override
  State<TopProductsList> createState() => _TopProductsListState();
}

class _TopProductsListState extends State<TopProductsList> {
  static const _tabs = ['Produk Terjual'];
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final products = widget.products;

    final qtys = products.map((p) => p['qty_sold'] as int).toList();
    final avgQty = qtys.isEmpty
        ? 0
        : qtys.reduce((a, b) => a + b) / qtys.length;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withAlpha(8),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                size: 24,
                color: AppColors.neonLime,
              ),
              const SizedBox(width: 10),
              Text(
                'Rating Produk',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: colors.textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tabs
          Row(
            children: List.generate(_tabs.length, (i) {
              final isActive = i == _activeTab;
              return Padding(
                padding: const EdgeInsets.only(right: 18),
                child: GestureDetector(
                  onTap: () => setState(() => _activeTab = i),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _tabs[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isActive
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: isActive
                              ? colors.textPrimary
                              : colors.textSecondary,
                        ),
                      ),
                      if (i == 0) ...[
                        const SizedBox(width: 3),
                        Icon(
                          Icons.arrow_downward_rounded,
                          size: 13,
                          color: isActive
                              ? colors.textPrimary
                              : colors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Divider(color: colors.divider, height: 1),
          const SizedBox(height: 6),

          if (products.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Belum ada data penjualan.',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
            )
          else
            ...products.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final product = entry.value;
              final imageUrl = product['image'] as String?;
              final name = product['name'] as String;
              final qty = product['qty_sold'] as int;

              final pct = avgQty == 0 ? 0.0 : ((qty - avgQty) / avgQty) * 100;
              final isUp = pct >= 0;
              final trendColor = isUp ? AppColors.success : AppColors.error;
              final rankColor = rank <= 3 ? AppColors.primary : colors.textHint;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Rank badge
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: rank <= 3
                            ? AppColors.primary.withAlpha(22)
                            : colors.inputFill,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: rankColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Thumbnail
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: colors.inputFill,
                        border: Border.all(color: colors.border),
                        image: imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: imageUrl == null
                          ? Icon(
                              Icons.image_outlined,
                              size: 18,
                              color: colors.textHint,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),

                    // Name + rank
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                              letterSpacing: -0.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$qty units sold',
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Trend badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: trendColor.withAlpha(18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUp
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 11,
                            color: trendColor,
                          ),
                          const SizedBox(width: 1),
                          Text(
                            '${pct.abs().toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: trendColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

// Mini Metric Card (kept for reuse elsewhere)
class MiniMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const MiniMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withAlpha(6),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(22),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
