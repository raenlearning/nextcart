import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nextcart/core/theme/app_colors.dart';

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
            style: TextStyle(color: colors.textSecondary, fontSize: 11.5),
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
                        fontSize: 8.5,
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
                  fontSize: 11.5,
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