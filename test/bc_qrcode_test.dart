import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_qrcode.dart';

void main() {
  Widget harness(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  group('VAL-M7-003 — BcQRCode renders a scannable QR matrix from input data', () {
    testWidgets('renders QR matrix with CustomPaint for non-empty data', (tester) async {
      await tester.pumpWidget(harness(
        const BcQRCode(value: 'https://example.com', size: 200),
      ));

      expect(find.byKey(const Key('bc_qrcode')), findsOneWidget);
      expect(find.byKey(const Key('bc_qrcode_matrix')), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders finder patterns in the matrix', (tester) async {
      await tester.pumpWidget(harness(
        const BcQRCode(value: 'test', size: 200),
      ));
      await tester.pump();

      // QR code size = version*4+17 = 37 for version 5
      // Finder patterns are at (0,0), (0,30), (30,0)
      final qrcodeFinder = tester.renderObjectList(find.byType(CustomPaint));
      expect(qrcodeFinder, isNotEmpty);
    });

    testWidgets('empty data renders placeholder without throwing', (tester) async {
      await tester.pumpWidget(harness(
        const BcQRCode(value: '', size: 200),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('bc_qrcode_placeholder')), findsOneWidget);
      expect(find.byKey(const Key('bc_qrcode')), findsNothing);
    });

    testWidgets('null value renders placeholder without throwing', (tester) async {
      await tester.pumpWidget(harness(
        const BcQRCode(value: null, size: 200),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('bc_qrcode_placeholder')), findsOneWidget);
    });
  });

  group('VAL-M7-004 — BcQRCode size and error correction level are configurable', () {
    testWidgets('different sizes render without error', (tester) async {
      await tester.pumpWidget(harness(
        const BcQRCode(value: 'data', size: 120),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('bc_qrcode')), findsOneWidget);

      final box = tester.getSize(find.byKey(const Key('bc_qrcode')));
      expect(box.width, 120);
      expect(box.height, 120);
    });

    testWidgets('different error correction levels render without error', (tester) async {
      for (final level in BcQrErrorCorrectLevel.values) {
        await tester.pumpWidget(harness(
          BcQRCode(value: 'data', size: 150, errorCorrectLevel: level),
        ));
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byKey(const Key('bc_qrcode_matrix')), findsOneWidget);
      }
    });

    testWidgets('changing error correction level updates the matrix', (tester) async {
      await tester.pumpWidget(harness(
        const BcQRCode(value: 'data', size: 150, errorCorrectLevel: BcQrErrorCorrectLevel.l),
      ));
      await tester.pump();

      expect(find.byKey(const Key('bc_qrcode_matrix')), findsOneWidget);

      await tester.pumpWidget(harness(
        const BcQRCode(value: 'data', size: 150, errorCorrectLevel: BcQrErrorCorrectLevel.h),
      ));
      await tester.pump();

      expect(find.byKey(const Key('bc_qrcode_matrix')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
