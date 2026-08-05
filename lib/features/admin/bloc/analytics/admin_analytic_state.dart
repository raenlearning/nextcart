
abstract class AdminAnalyticsState {}

class AdminAnalyticsInitial extends AdminAnalyticsState {}

class AdminAnalyticsLoading extends AdminAnalyticsState {}

class AdminAnalyticsLoaded extends AdminAnalyticsState {
  final double grossRevenue;

  final int completedOrders;

  final int totalProducts;

  final int totalUsers;

  final List<Map<String, dynamic>> revenueChart;

  final List<Map<String, dynamic>> topProducts;

  final Map<String, int> orderStatusBreakdown;

  final String period;

  AdminAnalyticsLoaded({
    required this.grossRevenue,
    required this.completedOrders,
    required this.totalProducts,
    required this.totalUsers,
    required this.revenueChart,
    required this.topProducts,
    required this.orderStatusBreakdown,
    required this.period,
  });
}

class AdminAnalyticsError extends AdminAnalyticsState {
  final String message;
  AdminAnalyticsError(this.message);
}