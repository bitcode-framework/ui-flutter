import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_native_button.dart';

void main() {
  group('BcNativeButton', () {
    Widget buildHarness({
      BcNativeButtonVariant variant = BcNativeButtonVariant.primary,
      bool disabled = false,
      bool loading = false,
      bool block = false,
      String? label,
      Widget? child,
      BcChangeHandler<void>? onPress,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: BcNativeButton(
              variant: variant,
              disabled: disabled,
              loading: loading,
              block: block,
              label: label,
              child: child,
              onPress: onPress,
            ),
          ),
        ),
      );
    }

    testWidgets('renders a button with a text label (VAL-G-001)',
        (tester) async {
      await tester.pumpWidget(buildHarness(label: 'Click me'));
      await tester.pumpAndSettle();
      expect(find.text('Click me'), findsOneWidget);
      expect(find.byKey(const Key('bc-native-button')), findsOneWidget);
    });

    testWidgets('renders a button with child widget (VAL-G-002)',
        (tester) async {
      await tester.pumpWidget(
        buildHarness(child: const Icon(Icons.add)),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('onPress fires with meta when tapped (VAL-G-003)',
        (tester) async {
      BcChangeMeta? meta;
      int callCount = 0;
      await tester.pumpWidget(buildHarness(
        label: 'Press',
        onPress: (_, m) {
          meta = m;
          callCount++;
        },
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Press'));
      await tester.pumpAndSettle();

      expect(callCount, 1);
      expect(meta, isNotNull);
      expect(meta!.source, BcEventSource.pointer);
    });

    testWidgets('disabled button does not fire onPress (VAL-G-004)',
        (tester) async {
      int callCount = 0;
      await tester.pumpWidget(buildHarness(
        label: 'Disabled',
        disabled: true,
        onPress: (_, __) => callCount++,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Disabled'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });

    testWidgets('loading button does not fire onPress (VAL-G-005)',
        (tester) async {
      int callCount = 0;
      await tester.pumpWidget(buildHarness(
        label: 'Loading',
        loading: true,
        onPress: (_, __) => callCount++,
      ));
      // Use pump (not pumpAndSettle) because the CircularProgressIndicator
      // animates indefinitely.
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.text('Loading'), warnIfMissed: false);
      await tester.pump();

      expect(callCount, 0);
    });

    testWidgets('all 5 variants render without error (VAL-G-006)',
        (tester) async {
      for (final v in BcNativeButtonVariant.values) {
        await tester.pumpWidget(buildHarness(variant: v, label: 'V'));
        await tester.pumpAndSettle();
        expect(find.text('V'), findsOneWidget,
            reason: 'variant $v should render');
      }
    });

    testWidgets('block stretches to full width (VAL-G-007)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        label: 'Full',
        block: true,
      ));
      await tester.pumpAndSettle();

      // The block flag wraps the button in a SizedBox(width: double.infinity).
      final sizedBoxes = find
          .byType(SizedBox)
          .evaluate()
          .map((el) => (el.widget as SizedBox).width);
      expect(sizedBoxes, contains(double.infinity));
    });

    testWidgets('variant foreground color is distinct for primary vs outline '
        '(VAL-G-008)', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: BcNativeButton(
              variant: BcNativeButtonVariant.primary,
              label: 'P',
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      final ctx = tester.element(find.text('P'));
      // primary uses primaryForeground (white), outline uses primary (blue).
      final primaryFg =
          BcNativeButtonVariant.primary.foreground(ctx);
      final outlineFg =
          BcNativeButtonVariant.outline.foreground(ctx);
      expect(primaryFg, isNot(equals(outlineFg)));
    });
  });
}
