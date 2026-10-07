import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextcart/core/widgets/shimmer_box.dart';

void main() {
  Widget wrap() => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ShimmerBox(width: 100, height: 40, radius: 8),
          ),
        ),
      );

  testWidgets('renders a box with given dimensions', (tester) async {
    await tester.pumpWidget(wrap());

    final container = tester.widget<Container>(find.byType(Container).first);
    expect(container.constraints?.maxWidth, 100);
    expect(container.constraints?.maxHeight, 40);
  });

  testWidgets('renders gradient decoration', (tester) async {
    await tester.pumpWidget(wrap());

    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.gradient, isA<LinearGradient>());
  });

  testWidgets('animates over time without errors', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull);
  });

  testWidgets('ShimmerProductGrid renders itemCount cards', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ShimmerProductGrid(itemCount: 4),
      ),
    ));
    expect(find.byType(ShimmerBox), findsNWidgets(16)); // 4 per card
  });
}