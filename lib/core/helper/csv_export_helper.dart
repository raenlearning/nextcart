import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CsvExportHelper {
  static List<List<dynamic>> _buildRows({
    required double grossRevenue,
    required int completedOrders,
    required int totalProducts,
    required int totalUsers,
    required List<Map<String, dynamic>> revenueChart,
    required List<Map<String, dynamic>> topProducts,
    required Map<String, int> orderStatusBreakdown,
  }) {
    final rows = <List<dynamic>>[];

    rows.add(['NextCart — Laporan Penjualan']);
    rows.add(const []);
    rows.add([
      'Pendapatan',
      'Pesanan Selesai',
      'Total Produk',
      'Total Pengguna',
    ]);
    rows.add([
      grossRevenue.toStringAsFixed(0),
      '$completedOrders',
      '$totalProducts',
      '$totalUsers',
    ]);

    rows.add(const []);
    rows.add(['Revenue (Per Hari)']);
    rows.add(['Tanggal', 'Jumlah']);
    for (final point in revenueChart) {
      final date = DateTime.tryParse(point['date'] as String? ?? '');
      rows.add([
        date != null ? DateFormat('yyyy-MM-dd').format(date) : '',
        (point['amount'] as num).toStringAsFixed(0),
      ]);
    }

    rows.add(const []);
    rows.add(['Status Pesanan']);
    rows.add(['Status', 'Jumlah']);
    orderStatusBreakdown.forEach((key, value) {
      rows.add([key, '$value']);
    });

    rows.add(const []);
    rows.add(['Produk Terlaris']);
    rows.add(['Nama', 'Terjual']);
    for (final product in topProducts) {
      rows.add([
        product['name']?.toString() ?? '',
        '${product['qty_sold'] ?? 0}',
      ]);
    }

    return rows;
  }

  static Future<void> exportAndShare({
    required double grossRevenue,
    required int completedOrders,
    required int totalProducts,
    required int totalUsers,
    required List<Map<String, dynamic>> revenueChart,
    required List<Map<String, dynamic>> topProducts,
    required Map<String, int> orderStatusBreakdown,
  }) async {
    final rows = _buildRows(
      grossRevenue: grossRevenue,
      completedOrders: completedOrders,
      totalProducts: totalProducts,
      totalUsers: totalUsers,
      revenueChart: revenueChart,
      topProducts: topProducts,
      orderStatusBreakdown: orderStatusBreakdown,
    );

    final csv = const ListToCsvConverter().convert(rows);

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/nextcart_report_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await file.writeAsString(csv);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: 'text/csv')]),
    );
  }
}