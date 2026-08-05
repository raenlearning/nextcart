import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextcart/data/models/analytic_model.dart';

abstract class AdminAnalyticsRepository {
  Future<AnalyticsSummary> fetchSummary({
    required DateTime from,
    required String period,
  });
}

class SupabaseAdminAnalyticsRepository implements AdminAnalyticsRepository {
  const SupabaseAdminAnalyticsRepository();

  @override
  Future<AnalyticsSummary> fetchSummary({
    required DateTime from,
    required String period,
  }) async {
    final supabase = Supabase.instance.client;

    final result = await supabase.rpc('get_seller_analytics', params: {
      'p_from': from.toIso8601String(),
    });

    if (result == null) {
      throw Exception('Respons null dar server analytics.');
    }

    final data = result as Map<String, dynamic>;

    final List<dynamic> revenueChartRaw = data['revenue_chart'] as List<dynamic>;
    final revenueChart = revenueChartRaw.map((e) {
      final map = e as Map<String, dynamic>;
      return RevenuePoint(
        date: DateTime.parse(map['date'] as String),
        amount: (map['amount'] as num).toDouble(),
      );
    }).toList();

    final statusRaw = data['order_status_breakdown'] as Map<String, dynamic>;
    final Map<String, int> statusBreakdown = statusRaw.map(
      (key, value) => MapEntry(key, value as int),
    );

    final topProductsRaw = data['top_products'] as List<dynamic>;
    final topProducts = topProductsRaw.map((e) {
      final map = e as Map<String, dynamic>;
      return TopProduct(
        productId: (map['id'] ?? '').toString(),
        name: map['name'] as String,
        imageUrl: map['image'] as String?,
        qtySold: (map['qty_sold'] as num?)?.toInt() ?? 0,
      );
    }).toList();

    final usersCount = await supabase
        .from('profiles')
        .select('id')
        .count(CountOption.exact);

    return AnalyticsSummary(
      grossRevenue: (data['gross_revenue'] as num).toDouble(),
      completedOrders: (data['completed_orders'] as num).toInt(),
      totalProducts: (data['total_products'] as num).toInt(),
      totalUsers: usersCount.count,
      revenueChart: revenueChart,
      topProducts: topProducts,
      orderStatusBreakdown: statusBreakdown,
    );
  }
}