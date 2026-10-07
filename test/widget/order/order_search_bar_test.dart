import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/features/order/presentation/widgets/order_search_bar.dart';

void main() {
  Widget wrap({
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: OrderSearchBar(
          controller: controller ?? TextEditingController(),
          onChanged: onChanged ?? (_) {},
          colors: AppColors.light,
        ),
      ),
    );
  }

  testWidgets('renders hint text and search icon', (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.text('Cari pesanan berdasarkan produk...'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('forwards text changes', (tester) async {
    String? received;
    await tester.pumpWidget(wrap(onChanged: (v) => received = v));

    await tester.enterText(find.byType(TextField), 'iphone');

    expect(received, 'iphone');
  });

  testWidgets('shows clear button when text present', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pump();

    expect(find.byIcon(Icons.clear), findsOneWidget);
  });

  testWidgets('clear button clears text and fires onChanged with empty',
      (tester) async {
    String? received = 'initial';
    await tester.pumpWidget(wrap(onChanged: (v) => received = v));

    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(received, '');
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty);
    expect(find.byIcon(Icons.clear), findsNothing);
  });

  testWidgets('no clear button when empty', (tester) async {
    await tester.pumpWidget(wrap());
    expect(find.byIcon(Icons.clear), findsNothing);
  });
}