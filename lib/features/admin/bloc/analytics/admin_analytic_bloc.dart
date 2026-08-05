import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcart/data/models/analytic_model.dart';
import 'package:nextcart/data/repository/admin_analytic_repository.dart';
import 'package:nextcart/features/admin/bloc/analytics/admin_analytic_event.dart';
import 'package:nextcart/features/admin/bloc/analytics/admin_analytic_state.dart';

class AdminAnalyticsBloc extends Bloc<AdminAnalyticsEvent, AdminAnalyticsState> {
  final AdminAnalyticsRepository _repository;

  AdminAnalyticsBloc({required this._repository})
      : super(AdminAnalyticsInitial()) {
    on<FetchAdminAnalytics>(_onFetch);
  }

  Future<void> _onFetch(
    FetchAdminAnalytics event,
    Emitter<AdminAnalyticsState> emit,
  ) async {
    emit(AdminAnalyticsLoading());
    try {
      final now = DateTime.now();
      final DateTime from = _periodStart(event.period, now);

      final AnalyticsSummary summary = await _repository.fetchSummary(
        from: from,
        period: event.period,
      );

      final List<Map<String, dynamic>> revenueChart = summary.revenueChart
          .map((p) => {'date': p.date.toIso8601String(), 'amount': p.amount})
          .toList();

      final List<Map<String, dynamic>> topProducts = summary.topProducts
          .map((p) => {
                'image': p.imageUrl,
                'name': p.name,
                'qty_sold': p.qtySold,
              })
          .toList();

      emit(AdminAnalyticsLoaded(
        grossRevenue: summary.grossRevenue,
        completedOrders: summary.completedOrders,
        totalProducts: summary.totalProducts,
        totalUsers: summary.totalUsers,
        revenueChart: revenueChart,
        topProducts: topProducts,
        orderStatusBreakdown: summary.orderStatusBreakdown,
        period: event.period,
      ));
    } catch (e) {
      emit(AdminAnalyticsError('Gagal memuat data: $e'));
    }
  }

  DateTime _periodStart(String period, DateTime now) {
    switch (period) {
      case '24h': return now.subtract(const Duration(hours: 24));
      case '7d': return now.subtract(const Duration(days: 7));
      case '6m': return now.subtract(const Duration(days: 180));
      case '1yr': return now.subtract(const Duration(days: 365));
      case '30d':
      default: return now.subtract(const Duration(days: 30));
    }
  }
}