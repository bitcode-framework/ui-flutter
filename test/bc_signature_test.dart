import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_signature.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) =>
      MaterialApp(home: Scaffold(body: child));

  group('VAL-M2-024 — stroke capture emits image data with meta on end-stroke', () {
    testWidgets('pointer drag on canvas captures stroke and fires onChange with input meta',
        (tester) async {
      String? capturedData;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcSignature(
          width: 300,
          height: 200,
          onChange: (dataUrl, meta) {
            capturedData = dataUrl;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_signature_canvas')), findsOneWidget);

      await tester.timedDrag(
        find.byKey(const Key('bc_signature_canvas')),
        const Offset(50, 30),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      expect(capturedData, isNotNull);
      expect(capturedData!.isNotEmpty, isTrue);
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, BcChangeReason.input);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets('canvas dimensions honor width and height props', (tester) async {
      await tester.pumpWidget(harness(
        const BcSignature(
          width: 350,
          height: 150,
        ),
      ));
      await tester.pumpAndSettle();

      final finder = find.byKey(const Key('bc_signature_canvas'));
      expect(finder, findsOneWidget);

      final size = tester.getSize(finder);
      expect(size.width, 350);
      expect(size.height, 150);
    });
  });

  group('VAL-M2-025 — clear control resets canvas and emits empty/null', () {
    testWidgets('clearing wipes strokes and fires onChange with empty value and clear reason',
        (tester) async {
      String? capturedData;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcSignature(
          onChange: (dataUrl, meta) {
            capturedData = dataUrl;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.timedDrag(
        find.byKey(const Key('bc_signature_canvas')),
        const Offset(50, 30),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      expect(capturedData, isNotNull);
      expect(capturedData!.isNotEmpty, isTrue);

      await tester.tap(find.byKey(const Key('bc_signature_clear')));
      await tester.pumpAndSettle();

      expect(capturedData, '');
      expect(capturedMeta!.reason, BcChangeReason.clear);
    });
  });

  group('VAL-M2-026 — disabled ignores strokes and renders no capture', () {
    testWidgets('disabled signature pad ignores pointer drags and does not fire onChange',
        (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        BcSignature(
          disabled: true,
          onChange: (dataUrl, meta) {
            callCount++;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.timedDrag(
        find.byKey(const Key('bc_signature_canvas')),
        const Offset(50, 30),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });

    testWidgets('disabled signature renders in disabled visual state', (tester) async {
      await tester.pumpWidget(harness(
        const BcSignature(
          disabled: true,
        ),
      ));
      await tester.pumpAndSettle();

      final opacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.byKey(const Key('bc_signature_canvas')),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, lessThan(1.0));
    });
  });
}
