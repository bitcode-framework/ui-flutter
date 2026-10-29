import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_meter_group.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/theme/bc_theme.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 400,
          child: child,
        ),
      ),
    );
  }

  testWidgets(
      'BcMeterGroup each meter exposes role=meter via Semantics (VAL-M4-026)',
      (tester) async {
    await tester.pumpWidget(harness(
      const BcMeterGroup(
        ariaLabel: 'Disk usage',
        segments: [
          BcMeterSegment(label: 'Used', value: 60),
          BcMeterSegment(label: 'Free', value: 30),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    // Each segment renders an independent meter gauge.
    expect(find.byType(BcMeterGroup), findsOneWidget);
    // Two gauges (one per segment).
    final gauges = find.descendant(
      of: find.byType(BcMeterGroup),
      matching: find.byKey(const Key('bc-meter-track')),
    );
    expect(gauges, findsNWidgets(2),
        reason: 'each segment should render its own meter gauge');

    // The semantics tree should carry the meter label + value for each
    // segment. We assert via the semantics node label content.
    final semantics = tester.getSemantics(find.byType(BcMeterGroup));
    // Walk the semantics tree and collect all non-empty labels.
    final labels = <String>[];
    void collect(SemanticsNode node) {
      if (node.label.isNotEmpty) labels.add(node.label);
      node.visitChildren((child) {
        collect(child);
        return true;
      });
    }

    collect(semantics);

    expect(labels.any((l) => l.contains('Used')), isTrue,
        reason: 'meter label should include the segment label "Used"');
    expect(labels.any((l) => l.contains('60')), isTrue,
        reason: 'meter label should include the segment value "60"');
    expect(labels.any((l) => l.contains('Free')), isTrue,
        reason: 'meter label should include the segment label "Free"');
  });

  testWidgets(
      'BcMeterGroup filled width maps value onto max and clamps at the bounds (VAL-M4-027)',
      (tester) async {
    await tester.pumpWidget(harness(
      const BcMeterGroup(
        max: 100,
        segments: [
          BcMeterSegment(label: 'half', value: 50), // 50%
          BcMeterSegment(label: 'full', value: 100), // 100%
          BcMeterSegment(label: 'over', value: 150), // clamped to 100%
          BcMeterSegment(label: 'zero', value: 0), // 0%
        ],
      ),
    ));
    await tester.pumpAndSettle();

    double fillWidthOf(String label) {
      final finder = find.byKey(Key('bc-meter-fill-$label'));
      expect(finder, findsOneWidget, reason: 'fill for "$label" should exist');
      return tester.getSize(finder).width;
    }

    final halfW = fillWidthOf('half');
    final fullW = fillWidthOf('full');
    final overW = fillWidthOf('over');
    final zeroW = fillWidthOf('zero');

    // The track (container) width is the full 400px available.
    const trackWidth = 400.0;

    expect(halfW, closeTo(trackWidth * 0.50, 2.0),
        reason: 'value 50 / max 100 => 50% fill');
    expect(fullW, closeTo(trackWidth * 1.00, 2.0),
        reason: 'value 100 / max 100 => 100% fill');
    expect(overW, closeTo(trackWidth * 1.00, 2.0),
        reason: 'value 150 should clamp to 100% fill');
    expect(zeroW, closeTo(0, 1.0),
        reason: 'value 0 => 0% fill');
  });

  testWidgets(
      'BcMeterGroup variants resolve to distinct BcTheme tokens and meters are independent (VAL-M4-028)',
      (tester) async {
    await tester.pumpWidget(harness(
      const BcMeterGroup(
        max: 100,
        segments: [
          BcMeterSegment(label: 'def', value: 40, variant: BcMeterVariant.defaultVariant),
          BcMeterSegment(label: 'ok', value: 40, variant: BcMeterVariant.success),
          BcMeterSegment(label: 'warn', value: 40, variant: BcMeterVariant.warning),
          BcMeterSegment(label: 'err', value: 40, variant: BcMeterVariant.destructive),
          BcMeterSegment(label: 'inf', value: 40, variant: BcMeterVariant.info),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    Color fillColorOf(String label) {
      final finder = find.byKey(Key('bc-meter-fill-$label'));
      final decorated = find.descendant(
        of: finder,
        matching: find.byType(DecoratedBox),
      );
      final box = tester.widget<DecoratedBox>(decorated);
      return (box.decoration as BoxDecoration).color!;
    }

    expect(fillColorOf('def'), BcTheme.primary,
        reason: 'default variant => primary token');
    expect(fillColorOf('ok'), BcTheme.success,
        reason: 'success variant => success token');
    expect(fillColorOf('warn'), BcTheme.warning,
        reason: 'warning variant => warning token');
    expect(fillColorOf('err'), BcTheme.destructive,
        reason: 'destructive variant => destructive token');
    expect(fillColorOf('inf'), BcTheme.info,
        reason: 'info variant => info token');

    // Independence: changing one segment's value must not change another's
    // width. Re-render with only the 'ok' segment's value changed.
    await tester.pumpWidget(harness(
      const BcMeterGroup(
        max: 100,
        segments: [
          BcMeterSegment(label: 'def', value: 40, variant: BcMeterVariant.defaultVariant),
          BcMeterSegment(label: 'ok', value: 90, variant: BcMeterVariant.success),
          BcMeterSegment(label: 'warn', value: 40, variant: BcMeterVariant.warning),
          BcMeterSegment(label: 'err', value: 40, variant: BcMeterVariant.destructive),
          BcMeterSegment(label: 'inf', value: 40, variant: BcMeterVariant.info),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    // The unchanged segments keep their original widths.
    expect(tester.getSize(find.byKey(const Key('bc-meter-fill-def'))).width,
        closeTo(400 * 0.40, 2.0),
        reason: 'unchanged segment width must be unaffected by sibling change');
    expect(tester.getSize(find.byKey(const Key('bc-meter-fill-warn'))).width,
        closeTo(400 * 0.40, 2.0),
        reason: 'unchanged segment width must be unaffected by sibling change');
    // The changed segment's width reflects the new value.
    expect(tester.getSize(find.byKey(const Key('bc-meter-fill-ok'))).width,
        closeTo(400 * 0.90, 2.0),
        reason: 'changed segment width should reflect the new value');
  });

  testWidgets(
      'BcMeterGroup value updates propagate to width and aria-valuenow without stale artifacts (VAL-M4-029)',
      (tester) async {
    double? emittedTotal;
    BcChangeMeta? emittedMeta;

    await tester.pumpWidget(harness(
      BcMeterGroup(
        max: 100,
        ariaLabel: 'Budget',
        segments: const [
          BcMeterSegment(label: 'spent', value: 30),
          BcMeterSegment(label: 'planned', value: 20),
        ],
        onChange: (value, meta) {
          emittedTotal = value;
          emittedMeta = meta;
        },
      ),
    ));
    await tester.pumpAndSettle();

    // Initial state: total = 50, no change emitted yet (first build seeds
    // the baseline, does not emit).
    expect(emittedTotal, isNull,
        reason: 'initial build should not emit a change');

    final initialSpentWidth =
        tester.getSize(find.byKey(const Key('bc-meter-fill-spent'))).width;
    expect(initialSpentWidth, closeTo(400 * 0.30, 2.0));

    // Update the segments: spent 30 -> 70, planned 20 -> 10. New total = 80.
    await tester.pumpWidget(harness(
      BcMeterGroup(
        max: 100,
        ariaLabel: 'Budget',
        segments: const [
          BcMeterSegment(label: 'spent', value: 70),
          BcMeterSegment(label: 'planned', value: 10),
        ],
        onChange: (value, meta) {
          emittedTotal = value;
          emittedMeta = meta;
        },
      ),
    ));
    await tester.pumpAndSettle();

    // The change should propagate immediately to widths — no stale widths.
    expect(
        tester.getSize(find.byKey(const Key('bc-meter-fill-spent'))).width,
        closeTo(400 * 0.70, 2.0),
        reason: 'width should reflect the new value immediately');
    expect(
        tester.getSize(find.byKey(const Key('bc-meter-fill-planned'))).width,
        closeTo(400 * 0.10, 2.0),
        reason: 'width should reflect the new value immediately');

    // The onChange callback should fire with the new total and a
    // BcChangeMeta whose reason is valueChange.
    expect(emittedTotal, 80,
        reason: 'onChange should emit the new aggregate value');
    expect(emittedMeta, isNotNull);
    expect(emittedMeta!.reason, BcChangeReason.valueChange,
        reason: 'change meta reason should be valueChange');

    // The aggregate aria-valuenow (group semantics value) should reflect
    // the new total — no stale value.
    final semantics = tester.getSemantics(find.byType(BcMeterGroup));
    expect(semantics.label, contains('Budget'),
        reason: 'group semantics label should carry the ariaLabel');
    expect(semantics.value, contains('80'),
        reason: 'group aria-valuenow should reflect the new total (80)');
  });

  testWidgets('BcMeterGroup renders empty group without assertion', (tester) async {
    await tester.pumpWidget(harness(
      const BcMeterGroup(segments: []),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(BcMeterGroup), findsOneWidget);
  });
}
