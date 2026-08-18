import 'package:flutter/material.dart';
import 'package:nextcart/core/constants/app_spacing.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/features/order/presentation/widgets/order_card.dart';
import 'package:nextcart/features/order/presentation/widgets/order_empty_state.dart';

class OrderList extends StatefulWidget {
  final List<Map<String, dynamic>> orders;
  final String emptyMessage;
  final AppColorScheme colors;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;

  const OrderList({
    super.key,
    required this.orders,
    required this.emptyMessage,
    required this.colors,
    required this.onRefresh,
    required this.onLoadMore,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
  });

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      if (widget.hasMore && !widget.isLoadingMore) {
        widget.onLoadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = widget.orders;

    if (widget.isLoading && orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (orders.isEmpty && !widget.isLoadingMore) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: widget.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: OrderEmptyState(
                message: widget.emptyMessage,
                colors: widget.colors,
              ),
            ),
          ],
        ),
      );
    }

    final totalItems = orders.fold<int>(
      0,
      (sum, o) => sum + ((o['order_items'] as List?)?.length ?? 0),
    );

    final showLoader = widget.isLoadingMore ||
        (widget.hasMore && orders.isNotEmpty);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          AppSpacing.bottomNavSpace,
        ),
        itemCount: orders.length + (showLoader ? 2 : 1),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jumlah Produk',
                    style: TextStyle(
                      color: widget.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '($totalItems)',
                    style: TextStyle(
                      color: widget.colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }
          if (index <= orders.length) {
            return OrderCard(order: orders[index - 1], colors: widget.colors);
          }
          if (widget.isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            );
          }
          if (widget.hasMore) {
            return const SizedBox(height: 20);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}