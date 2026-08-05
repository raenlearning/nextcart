import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextcart/core/constants/app_assets.dart';
import 'package:nextcart/core/helper/csv_export_helper.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/widgets/admin/dashboard_widget.dart';
import '../../bloc/analytics/admin_analytic_bloc.dart';
import '../../bloc/analytics/admin_analytic_event.dart';
import '../../bloc/analytics/admin_analytic_state.dart';

class AdminAnalyticsDashboardPage extends StatefulWidget {
  const AdminAnalyticsDashboardPage({super.key});

  @override
  State<AdminAnalyticsDashboardPage> createState() =>
      _AdminAnalyticsDashboardPageState();
}

class _AdminAnalyticsDashboardPageState
    extends State<AdminAnalyticsDashboardPage> {
  String _period = '30d';
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() =>
      context.read<AdminAnalyticsBloc>().add(FetchAdminAnalytics(period: _period));

  void _onPeriodChanged(String p) {
    setState(() => _period = p);
    context.read<AdminAnalyticsBloc>().add(FetchAdminAnalytics(period: p));
  }

  Future<void> _export(AdminAnalyticsLoaded state) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      await CsvExportHelper.exportAndShare(
        grossRevenue: state.grossRevenue,
        completedOrders: state.completedOrders,
        totalProducts: state.totalProducts,
        totalUsers: state.totalUsers,
        revenueChart: state.revenueChart,
        topProducts: state.topProducts,
        orderStatusBreakdown: state.orderStatusBreakdown,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengekspor laporan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) context.go('/auth');
  }

  String _initials(String email) {
    final name = email.split('@').first;
    if (name.isEmpty) return 'A';
    final parts = name.split(RegExp(r'[._-]')).where((e) => e.isNotEmpty).toList();
    if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors    = context.colors;
    final userEmail = Supabase.instance.client.auth.currentUser?.email ??
        'admin@nextcart.com';

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.black,
          onRefresh: () async => _fetch(),
          child: BlocBuilder<AdminAnalyticsBloc, AdminAnalyticsState>(
            builder: (context, state) {
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'Dasbor',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onLongPress: _logout,
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFFF3C6D2), Color(0xFFE8A0B4)],
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _initials(userEmail),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: colors.card,
                              shape: BoxShape.circle,
                              border: Border.all(color: colors.border),
                            ),
                            child: IconButton(
                              icon: _isExporting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.download_rounded,
                                      color: AppColors.primary, size: 18),
                              tooltip: 'Ekspor Laporan',
                              onPressed: state is AdminAnalyticsLoaded
                                  ? () => _export(state)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: colors.card,
                              shape: BoxShape.circle,
                              border: Border.all(color: colors.border),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                              tooltip: 'Keluar',
                              onPressed: _logout,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: PeriodFilterTabs(
                        selected: _period,
                        onChanged: _onPeriodChanged,
                      ),
                    ),
                  ),

                  if (state is AdminAnalyticsLoading)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Lottie.asset(
                              AppAssets.loadingChart,
                              width: 80,
                              height: 80,
                              repeat: true,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Memuat data...',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (state is AdminAnalyticsError)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(color: colors.inputFill, shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: Icon(Icons.wifi_off_rounded, size: 32, color: colors.textHint),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colors.textSecondary, fontSize: 13.5, height: 1.4),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _fetch,
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Coba Lagi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (state is AdminAnalyticsLoaded) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                        child: DashboardHeroBanner(
                          grossRevenue    : state.grossRevenue,
                          completedOrders : state.completedOrders,
                          totalProducts   : state.totalProducts,
                          totalUsers      : state.totalUsers,
                          revenueChart    : state.revenueChart,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: OrderStatusChart(statusBreakdown: state.orderStatusBreakdown),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: TopProductsList(products: state.topProducts),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ]
                  else
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.4),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}