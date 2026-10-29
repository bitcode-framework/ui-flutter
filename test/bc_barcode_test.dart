import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_barcode.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) =>
      MaterialApp(home: Scaffold(body: child));

  group('VAL-M2-027 — controlled value renders generated barcode for format', () {
    testWidgets('controlled value renders barcode display area with the value', (tester) async {
      await tester.pumpWidget(harness(
        const BcBarcode(
          value: '123456789012',
          format: 'CODE128',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_barcode_display')), findsOneWidget);
      expect(find.byKey(const Key('bc_barcode_value_text')), findsOneWidget);
      expect(
        (tester.widget(find.byKey(const Key('bc_barcode_value_text'))) as Text).data,
        '123456789012',
      );
    });

    testWidgets('changing controlled value re-renders barcode to match new payload',
        (tester) async {
      String currentValue = 'AAA';

      await tester.pumpWidget(harness(
        BcBarcode(value: currentValue),
      ));
      await tester.pumpAndSettle();

      expect(
        (tester.widget(find.byKey(const Key('bc_barcode_value_text'))) as Text).data,
        'AAA',
      );

      currentValue = 'BBB';
      await tester.pumpWidget(harness(
        BcBarcode(value: currentValue),
      ));
      await tester.pumpAndSettle();

      expect(
        (tester.widget(find.byKey(const Key('bc_barcode_value_text'))) as Text).data,
        'BBB',
      );
    });
  });

  group('VAL-M2-028 — scan/decode emits code with select reason; disabled blocks', () {
    testWidgets('manual entry + confirm emits code string with select reason and pointer source',
        (tester) async {
      String? capturedValue;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcBarcode(
          onChange: (value, meta) {
            capturedValue = value;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('bc_barcode_input')),
        '12345',
      );
      await tester.pumpAndSettle();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(capturedValue, '12345');
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, BcChangeReason.select);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets('disabled barcode blocks text entry and onChange never fires', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        BcBarcode(
          disabled: true,
          onChange: (value, meta) {
            callCount++;
          },
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_barcode_input')), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc_barcode_input')));
      await tester.pumpAndSettle();

      // disabled TextField should not accept text entry, so callCount stays 0
      expect(callCount, 0);
    });
  });

  group('VAL-M2-029 — empty/null value renders placeholder, no malformed barcode', () {
    testWidgets('null value renders placeholder, no barcode display', (tester) async {
      await tester.pumpWidget(harness(
        const BcBarcode(
          value: null,
          placeholder: 'Scan or type barcode...',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_barcode_display')), findsNothing);
      expect(find.byKey(const Key('bc_barcode_value_text')), findsNothing);
    });

    testWidgets('empty string value renders placeholder, no barcode display', (tester) async {
      await tester.pumpWidget(harness(
        const BcBarcode(
          value: '',
          placeholder: 'Scan barcode',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_barcode_display')), findsNothing);
      expect(find.byKey(const Key('bc_barcode_value_text')), findsNothing);
    });

    testWidgets('non-null value immediately renders a valid barcode', (tester) async {
      await tester.pumpWidget(harness(
        const BcBarcode(
          value: '4006381333931',
          placeholder: 'Scan barcode',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_barcode_display')), findsOneWidget);
      expect(
        (tester.widget(find.byKey(const Key('bc_barcode_value_text'))) as Text).data,
        '4006381333931',
      );
    });
  });
}
