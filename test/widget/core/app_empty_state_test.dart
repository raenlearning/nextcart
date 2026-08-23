import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextcart/core/widgets/app_empty_state.dart';

void main() {
  Widget wrap(AppEmptyState state) => MaterialApp(home: Scaffold(body: state));

  testWidgets('renders title and description', (tester) async {
    await tester.pumpWidget(wrap(
      const AppEmptyState(
        title: 'Kosong',
        description: 'Belum ada data.',
      ),
    ));

    expect(find.text('Kosong'), findsOneWidget);
    expect(find.text('Belum ada data.'), findsOneWidget);
  });

  testWidgets('shows action button and fires callback', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(
      AppEmptyState(
        title: 'Kosong',
        actionLabel: 'Mulai',
        onAction: () => tapped = true,
      ),
    ));

    expect(find.text('Mulai'), findsOneWidget);
    await tester.tap(find.text('Mulai'));
    expect(tapped, isTrue);
  });

  testWidgets('hides action button when onAction is null', (tester) async {
    await tester.pumpWidget(wrap(
      const AppEmptyState(title: 'Kosong', actionLabel: 'Mulai'),
    ));
    expect(find.text('Mulai'), findsNothing);
  });

  testWidgets('hides action when actionLabel is null', (tester) async {
    await tester.pumpWidget(wrap(
      AppEmptyState(title: 'Kosong', onAction: () {}),
    ));
    expect(find.byType(ElevatedButton), findsNothing);
  });
}