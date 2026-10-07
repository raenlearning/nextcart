import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextcart/core/widgets/pressable_scale.dart';

void main() {
  Widget wrap({VoidCallback? onTap}) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: PressableScale(
              onTap: onTap,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

  testWidgets('renders child', (tester) async {
    await tester.pumpWidget(wrap());
    expect(find.byType(PressableScale), findsOneWidget);
    expect(find.byType(Container), findsOneWidget);
  });

  testWidgets('fires onTap when pressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(onTap: () => tapped = true));

    await tester.tap(find.byType(PressableScale));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('animates scale down while pressed', (tester) async {
    await tester.pumpWidget(wrap());

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PressableScale)),
    );
    await tester.pump(const Duration(milliseconds: 200));

    final scale = tester
        .widget<AnimatedScale>(find.byType(AnimatedScale))
        .scale;
    expect(scale, lessThan(1.0));

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 200));

    final finalScale = tester
        .widget<AnimatedScale>(find.byType(AnimatedScale))
        .scale;
    expect(finalScale, 1.0);
  });

  testWidgets('does not throw when onTap is null', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.byType(PressableScale), warnIfMissed: false);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}