import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_webcam.dart';

void main() {
  group('BcWebcam', () {
    Widget buildHarness({
      BcWebcamFacingMode facingMode = BcWebcamFacingMode.user,
      String captureLabel = 'Capture',
      Widget Function(BuildContext context)? cameraBuilder,
      void Function(Object error)? onError,
      void Function(String dataURL, BcChangeMeta meta)? onCapture,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BcWebcam(
            facingMode: facingMode,
            captureLabel: captureLabel,
            cameraBuilder: cameraBuilder,
            onError: onError,
            onCapture: onCapture,
          ),
        ),
      );
    }

    testWidgets('renders root + title + facing meta (VAL-C-015)',
        (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-webcam-root')), findsOneWidget);
      expect(find.byKey(const Key('bc-webcam-title')), findsOneWidget);
      expect(find.byKey(const Key('bc-webcam-facing')), findsOneWidget);
      expect(find.textContaining('facing: user'), findsOneWidget);
    });

    testWidgets('environment facing renders correct label (VAL-C-016)',
        (tester) async {
      await tester.pumpWidget(
          buildHarness(facingMode: BcWebcamFacingMode.environment));
      await tester.pumpAndSettle();
      expect(find.textContaining('facing: environment'), findsOneWidget);
    });

    testWidgets('capture button label customizable (VAL-C-017)',
        (tester) async {
      await tester.pumpWidget(buildHarness(captureLabel: 'Snap'));
      await tester.pumpAndSettle();
      expect(find.text('Snap'), findsOneWidget);
    });

    testWidgets('capture tap fires onCapture + pointer (VAL-C-018)',
        (tester) async {
      String? captured;
      BcChangeMeta? meta;
      await tester.pumpWidget(buildHarness(
        onCapture: (v, m) {
          captured = v;
          meta = m;
        },
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-webcam-capture')));
      await tester.pumpAndSettle();
      expect(captured, '');
      expect(meta, isNotNull);
      expect(meta!.source, BcEventSource.pointer);
    });

    testWidgets('renders camera capture semantics label (VAL-C-019)',
        (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();
      final semantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'camera capture',
      );
      expect(semantics, findsOneWidget);
    });

    testWidgets('cameraBuilder is rendered when provided (VAL-C-020)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        cameraBuilder: (_) => const Text(
          'native-cam',
          key: Key('custom-cam'),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('custom-cam')), findsOneWidget);
    });
  });
}
