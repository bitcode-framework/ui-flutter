import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_kbd.dart';

void main() {
  Widget harness(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  group('VAL-M7-005 — BcKbd renders keyboard key styling', () {
    testWidgets('renders single key with label', (tester) async {
      await tester.pumpWidget(harness(
        const BcKbd(keys: ['Ctrl']),
      ));

      expect(find.byKey(const Key('bc_kbd_key_Ctrl')), findsOneWidget);
      expect(find.text('Ctrl'), findsOneWidget);
    });

    testWidgets('renders multiple keys with separator', (tester) async {
      await tester.pumpWidget(harness(
        const BcKbd(keys: ['Ctrl', 'K']),
      ));

      expect(find.byKey(const Key('bc_kbd')), findsOneWidget);
      expect(find.byKey(const Key('bc_kbd_key_Ctrl')), findsOneWidget);
      expect(find.byKey(const Key('bc_kbd_key_K')), findsOneWidget);
      expect(find.text('+'), findsOneWidget);
    });

    testWidgets('renders label prop as key', (tester) async {
      await tester.pumpWidget(harness(
        const BcKbd(label: 'Enter'),
      ));

      expect(find.byKey(const Key('bc_kbd_key_Enter')), findsOneWidget);
      expect(find.text('Enter'), findsOneWidget);
    });

    testWidgets('renders child with key styling when child provided', (tester) async {
      await tester.pumpWidget(harness(
        const BcKbd(child: Text('custom')),
      ));

      expect(find.byKey(const Key('bc_kbd')), findsOneWidget);
      expect(find.text('custom'), findsOneWidget);
    });
  });

  group('VAL-M7-006 — BcKbd empty child renders nothing without error', () {
    testWidgets('empty keys list renders nothing', (tester) async {
      await tester.pumpWidget(harness(
        const BcKbd(keys: []),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('bc_kbd_empty')), findsOneWidget);
      expect(find.byKey(const Key('bc_kbd')), findsNothing);
    });

    testWidgets('null keys and null label renders nothing', (tester) async {
      await tester.pumpWidget(harness(
        const BcKbd(),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('bc_kbd_empty')), findsOneWidget);
      expect(find.byKey(const Key('bc_kbd')), findsNothing);
    });

    testWidgets('renders without throwing assertion error', (tester) async {
      await tester.pumpWidget(harness(
        const BcKbd(keys: ['Shift']),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
