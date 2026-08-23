import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/features/order/presentation/widgets/order_list.dart';

Map<String, dynamic> buildOrder(String id, {int itemCount = 1}) {
  return {
    'id': id,
    'status': 'completed',
    'total_amount': 100000,
    'created_at': '2026-08-01T10:00:00',
    'order_items': [
      for (var i = 0; i < itemCount; i++)
        {
          'id': '$id-item$i',
          'quantity': 1,
          'price_at_purchase': 100000,
          'products': {'id': 'p$i', 'name': 'Produk $i', 'images': []},
        },
    ],
    'payments': {'status': 'success', 'method': 'qris'},
  };
}

void main() {
  testWidgets('shows loading indicator when loading and empty', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: OrderList(
          orders: const [],
          emptyMessage: 'Belum ada',
          colors: AppColors.light,
          onRefresh: () async {},
          onLoadMore: () {},
          isLoading: true,
          isLoadingMore: false,
          hasMore: true,
        ),
      ),
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Belum ada'), findsNothing);
  });

  testWidgets('shows empty state message when no orders', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: OrderList(
          orders: const [],
          emptyMessage: 'Belum ada pesanan',
          colors: AppColors.light,
          onRefresh: () async {},
          onLoadMore: () {},
          isLoading: false,
          isLoadingMore: false,
          hasMore: true,
        ),
      ),
    ));

    await tester.pumpAndSettle();
    expect(find.text('Belum ada pesanan'), findsOneWidget);
  });

  testWidgets('shows product count header when orders exist', (tester) async {
    final orders = [
      buildOrder('o1', itemCount: 2),
      buildOrder('o2', itemCount: 3),
    ];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: OrderList(
          orders: orders,
          emptyMessage: 'Belum ada',
          colors: AppColors.light,
          onRefresh: () async {},
          onLoadMore: () {},
          isLoading: false,
          isLoadingMore: false,
          hasMore: true,
        ),
      ),
    ));

    expect(find.text('Jumlah Produk'), findsOneWidget);
    expect(find.text('(5)'), findsOneWidget);
    expect(find.byType(OrderList), findsOneWidget);
  });

  testWidgets('triggers onLoadMore when scrolled near bottom', (tester) async {
    final orders = [
      for (var i = 0; i < 15; i++) buildOrder('o$i'),
    ];
    var loadMoreCalls = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: OrderList(
          orders: orders,
          emptyMessage: 'Belum ada',
          colors: AppColors.light,
          onRefresh: () async {},
          onLoadMore: () => loadMoreCalls++,
          isLoading: false,
          isLoadingMore: false,
          hasMore: true,
        ),
      ),
    ));

    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pump();

    expect(loadMoreCalls, greaterThanOrEqualTo(1));
  });

  testWidgets('does not trigger onLoadMore when hasMore is false',
      (tester) async {
    final orders = [
      for (var i = 0; i < 15; i++) buildOrder('o$i'),
    ];
    var loadMoreCalls = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: OrderList(
          orders: orders,
          emptyMessage: 'Belum ada',
          colors: AppColors.light,
          onRefresh: () async {},
          onLoadMore: () => loadMoreCalls++,
          isLoading: false,
          isLoadingMore: false,
          hasMore: false,
        ),
      ),
    ));

    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pump();

    expect(loadMoreCalls, 0);
  });

  testWidgets('shows load-more spinner when isLoadingMore', (tester) async {
    final orders = [
      for (var i = 0; i < 15; i++) buildOrder('o$i'),
    ];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: OrderList(
          orders: orders,
          emptyMessage: 'Belum ada',
          colors: AppColors.light,
          onRefresh: () async {},
          onLoadMore: () {},
          isLoading: false,
          isLoadingMore: true,
          hasMore: true,
        ),
      ),
    ));

    // scroll to bottom to reveal the spinner
    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });
}