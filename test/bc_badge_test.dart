import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_badge.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/theme/bc_theme.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  testWidgets('BcBadge renders label text', (tester) async {
    await tester.pumpWidget(harness(const BcBadge(label: 'New')));
    await tester.pumpAndSettle();

    expect(find.text('New'), findsOneWidget);
  });

  testWidgets('BcBadge default variant uses primary token pair', (tester) async {
    await tester.pumpWidget(harness(const BcBadge(label: 'X')));
    await tester.pumpAndSettle();

    final container = tester.widget<Container>(find.byKey(const Key('bc-badge')));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, BcTheme.primary);

    final text = tester.widget<Text>(find.text('X'));
    expect(text.style?.color, BcTheme.primaryForeground);
  });

  testWidgets('BcBadge secondary variant uses secondary token', (tester) async {
    await tester.pumpWidget(harness(const BcBadge(
      label: 'X',
      variant: BcComponentVariant.secondary,
    )));
    await tester.pumpAndSettle();

    final container = tester.widget<Container>(find.byKey(const Key('bc-badge')));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, BcTheme.secondary);
    expect(decoration.border, isNull, reason: 'only outline has a border');
  });

  testWidgets('BcBadge destructive variant uses destructive token', (tester) async {
    await tester.pumpWidget(harness(const BcBadge(
      label: 'X',
      variant: BcComponentVariant.destructive,
    )));
    await tester.pumpAndSettle();

    final container = tester.widget<Container>(find.byKey(const Key('bc-badge')));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, BcTheme.destructive);
  });

  testWidgets('BcBadge outline variant renders transparent bg with border', (tester) async {
    await tester.pumpWidget(harness(const BcBadge(
      label: 'X',
      variant: BcComponentVariant.outline,
    )));
    await tester.pumpAndSettle();

    final container = tester.widget<Container>(find.byKey(const Key('bc-badge')));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, Colors.transparent);
    expect(decoration.border, isNotNull, reason: 'outline should have a border');

    final text = tester.widget<Text>(find.text('X'));
    expect(text.style?.color, BcTheme.foreground);
  });

  testWidgets('BcBadge primary variant resolves to primary token', (tester) async {
    await tester.pumpWidget(harness(const BcBadge(
      label: 'X',
      variant: BcComponentVariant.primary,
    )));
    await tester.pumpAndSettle();

    final container = tester.widget<Container>(find.byKey(const Key('bc-badge')));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, BcTheme.primary);
  });

  testWidgets('BcBadge exposes semantics label', (tester) async {
    await tester.pumpWidget(harness(const BcBadge(label: 'Active')));
    await tester.pumpAndSettle();

    final semantics = tester.getSemantics(find.byType(BcBadge));
    expect(semantics.label, 'Active');
  });

  testWidgets('BcBadge renders empty label without assertion', (tester) async {
    await tester.pumpWidget(harness(const BcBadge(label: '')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('bc-badge')), findsOneWidget);
  });
}