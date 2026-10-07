class RevenuePoint {
  final DateTime date;
  final double amount;

  const RevenuePoint({required this.date, required this.amount});
}

class TopProduct {
  final String productId;
  final String name;
  final String? imageUrl;
  final int qtySold;

  const TopProduct({
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.qtySold,
  });
}

class LowStockProduct {
  final String productId;
  final String name;
  final int stock;

  const LowStockProduct({
    required this.productId,
    required this.name,
    required this.stock,
  });
}

class AnalyticsSummary {
  final double grossRevenue;
  final int completedOrders;
  final int totalProducts;
  final int totalUsers;
  final List<RevenuePoint> revenueChart;
  final List<TopProduct> topProducts;
  final Map<String, int> orderStatusBreakdown;
  final List<LowStockProduct> lowStockProducts;

  const AnalyticsSummary({
    required this.grossRevenue,
    required this.completedOrders,
    required this.totalProducts,
    required this.totalUsers,
    required this.revenueChart,
    required this.topProducts,
    required this.orderStatusBreakdown,
    this.lowStockProducts = const [],
  });
}