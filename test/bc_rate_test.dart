import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_rate.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/theme/bc_theme.dart';

void main() {
  Widget harness(Widget child) =>
      MaterialApp(home: Scaffold(body: child));

  group('VAL-M2-004 — tapping Nth star emits rating N', () {
    testWidgets('tapping 4th star emits 4 and renders 4 filled stars', (tester) async {
      int? capturedValue;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcRate(
          defaultValue: 0,
          count: 5,
          onChange: (v, meta) {
            capturedValue = v;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      final stars = find.byKey(const Key('bc_rate_star_4'));
      await tester.tap(stars);
      await tester.pumpAndSettle();

      expect(capturedValue, 4);
      expect(capturedMeta!.reason, BcChangeReason.select);
      expect(capturedMeta!.source, BcEventSource.pointer);

      for (var i = 1; i <= 5; i++) {
        final icon = tester.widget<Icon>(
          find.descendant(
            of: find.byKey(Key('bc_rate_star_$i')),
            matching: find.byType(Icon),
          ),
        );
        if (i <= 4) {
          expect(icon.color, BcTheme.warning,
              reason: 'Star $i should be filled');
        } else {
          expect(icon.color != BcTheme.warning, true,
              reason: 'Star $i should be unfilled');
        }
      }
    });
  });

  group('VAL-M2-005 — re-clicking active star clears to 0', () {
    testWidgets('clicking same star clears value to 0 with deselect reason', (tester) async {
      int? capturedValue;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcRate(
          defaultValue: 3,
          count: 5,
          onChange: (v, meta) {
            capturedValue = v;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_rate_star_3')));
      await tester.pumpAndSettle();

      expect(capturedValue, 0);
      expect(capturedMeta!.reason, BcChangeReason.deselect);
    });
  });

  group('VAL-M2-006 — disabled and readonly', () {
    testWidgets('disabled blocks interaction and dims stars', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        BcRate(
          value: 3,
          count: 5,
          disabled: true,
          onChange: (_, __) => callCount++,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_rate_star_2')));
      await tester.pumpAndSettle();

      expect(callCount, 0);

      final opacityFinder = find.descendant(
        of: find.byType(BcRate),
        matching: find.byType(Opacity),
      );
      expect(opacityFinder, findsWidgets);
      final opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, lessThan(1.0));
    });

    testWidgets('readonly blocks interaction but stays bright', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        BcRate(
          value: 3,
          count: 5,
          readonly: true,
          onChange: (_, __) => callCount++,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_rate_star_2')));
      await tester.pumpAndSettle();

      expect(callCount, 0);

      final opacityFinder = find.descendant(
        of: find.byType(BcRate),
        matching: find.byType(Opacity),
      );
      expect(opacityFinder, findsNothing);
    });
  });
}
