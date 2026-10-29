import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_print_area.dart';

void main() {
  group('BcPrintArea', () {
    testWidgets('renders child inside a semantic region (VAL-E3-001)',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: BcPrintArea(
            ariaLabel: 'Invoice',
            child: Text('Invoice content'),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-print-area-root')), findsOneWidget);
      expect(find.text('Invoice content'), findsOneWidget);
    });

    testWidgets('onReady fires once after first frame (VAL-E3-002)',
        (tester) async {
      int readyCount = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcPrintArea(
            onReady: () => readyCount++,
            child: const SizedBox.shrink(),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(readyCount, 1);

      // Rebuilding with the same widget should not fire again.
      await tester.pumpAndSettle();
      expect(readyCount, 1);
    });

    testWidgets('auto prop accepted (no-op on Flutter, contract parity) (VAL-E3-003)',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: BcPrintArea(
            auto: false,
            child: Text('Marker only'),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Marker only'), findsOneWidget);
    });

    testWidgets('null ariaLabel falls back to default printable region text (VAL-E3-004)',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: BcPrintArea(child: Text('Content')),
        ),
      ));
      await tester.pumpAndSettle();
      final semantics = tester.getSemantics(find.byKey(const Key('bc-print-area-root')));
      expect(semantics.label, contains('Printable region'));
    });
  });
}
