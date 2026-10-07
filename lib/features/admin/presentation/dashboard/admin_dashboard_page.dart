import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextcart/core/helper/csv_export_helper.dart';
import 'package:nextcart/core/helper/toast_helper.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/constants/app_spacing.dart';
import 'package:nextcart/core/widgets/admin/admin_bento_tiles.dart';
import 'package:nextcart/core/widgets/admin/real_time_bar_chart.dart';
import 'package:nextcart/core/widgets/admin/order_status_chart.dart';
import 'package:nextcart/core/widgets/admin/period_filter_tabs.dart';
import 'package:nextcart/core/widgets/admin/top_products_list.dart';
import 'package:nextcart/features/admin/presentation/dashboard/admin_sidebar.dart';
import 'package:nextcart/core/widgets/shimmer_box.dart';
import 'package:nextcart/data/models/analytic_model.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _period = '30d';
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() => context.read<AdminAnalyticsBloc>().add(
    FetchAdminAnalytics(period: _period),
  );

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
        ToastHelper.showToast(
          context,
          'Gagal mengekspor laporan: $e',
          ToastSeverity.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _confirmLogout() async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Keluar?', style: TextStyle(color: colors.textPrimary)),
        content: Text(
          'Anda akan keluar dari akun admin.',
          style: TextStyle(color: colors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _logout();
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final userEmail =
        Supabase.instance.client.auth.currentUser?.email ??
        'admin@nextcart.com';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.surface,
      drawer: AdminSidebar(
        email: userEmail,
        isExporting: _isExporting,
        onExport: () {
          final state = context.read<AdminAnalyticsBloc>().state;
          if (state is AdminAnalyticsLoaded) _export(state);
        },
        onLogout: _confirmLogout,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
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
                          Container(
                            decoration: BoxDecoration(
                              color: colors.card,
                              shape: BoxShape.circle,
                              border: Border.all(color: colors.border),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.menu_rounded,
                                color: colors.textPrimary,
                                size: 20,
                              ),
                              tooltip: 'Menu',
                              onPressed: () {
                                AdminSidebar.refreshTrigger.value++;
                                _scaffoldKey.currentState?.openDrawer();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Dashboard',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                                fontFamily: 'Geist',
                              ),
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
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                        child: Column(
                          children: const [
                            Row(
                              children: [
                                Expanded(
                                  child: ShimmerBox(height: 110, radius: 16),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: ShimmerBox(height: 110, radius: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ShimmerBox(height: 110, radius: 16),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: ShimmerBox(height: 110, radius: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            ShimmerBox(height: 220, radius: 16),
                            SizedBox(height: 16),
                            ShimmerBox(height: 180, radius: 16),
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
                              decoration: BoxDecoration(
                                color: colors.inputFill,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.wifi_off_rounded,
                                size: 32,
                                color: colors.textHint,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _fetch,
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Coba Lagi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
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
                        child: SizedBox(
                          height: 150,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: AdminRevenueTile(
                                  grossRevenue: state.grossRevenue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Center(
                                  child: AdminStatTile(
                                    icon: FontAwesomeIcons.clipboardCheck,
                                    color: AppColors.success,
                                    label: 'Pesanan Selesai',
                                    value: '${state.completedOrders}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: SizedBox(
                          height: 104,
                          child: Row(
                            children: [
                              Expanded(
                                child: AdminStatTile(
                                  icon: FontAwesomeIcons.boxOpen,
                                  color: AppColors.primary,
                                  label: 'Produk',
                                  value: formatCompactCount(
                                    state.totalProducts,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AdminStatTile(
                                  icon: FontAwesomeIcons.users,
                                  color: AppColors.info,
                                  label: 'Pengguna',
                                  value: formatCompactCount(state.totalUsers),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AdminStatTile(
                                  icon: FontAwesomeIcons.triangleExclamation,
                                  color: AppColors.error,
                                  label: 'Stok Menipis',
                                  value: '${state.lowStockProducts.length}',
                                  alert: state.lowStockProducts.isNotEmpty,
                                  onTap: state.lowStockProducts.isNotEmpty
                                      ? () => _showLowStockSheet(
                                          context,
                                          state.lowStockProducts,
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: AdminChartTile(
                          icon: Icons.insights_rounded,
                          iconColor: AppColors.primary,
                          title: 'Grafik Pendapatan',
                          child: SizedBox(
                            height: 160,
                            child: RealTimeBarChart(data: state.revenueChart),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: OrderStatusChart(
                          statusBreakdown: state.orderStatusBreakdown,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: TopProductsList(products: state.topProducts),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.bottomNavSpace),
                    ),
                  ] else
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2.4,
                        ),
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

void _showLowStockSheet(BuildContext context, List<LowStockProduct> products) {
  final colors = context.colors;
  showModalBottomSheet(
    context: context,
    backgroundColor: colors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Produk Stok Menipis',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Segera restock produk berikut (stok ≤ 5).',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              p.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${p.stock} stok',
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
