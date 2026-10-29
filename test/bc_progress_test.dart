import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_progress.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/theme/bc_theme.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 200,
          child: child,
        ),
      ),
    );
  }

  testWidgets('BcProgress renders default with zero fill', (tester) async {
    await tester.pumpWidget(harness(const BcProgress()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc-progress')), findsOneWidget);
    expect(find.byKey(const Key('bc-progress-track')), findsOneWidget);

    final fillW = tester.getSize(find.byKey(const Key('bc-progress-fill'))).width;
    expect(fillW, closeTo(0, 1.0), reason: 'default value 0 => 0% fill');
  });

  testWidgets('BcProgress fill width maps value onto max', (tester) async {
    await tester.pumpWidget(harness(const BcProgress(value: 50, max: 100)));
    await tester.pumpAndSettle();

    final fillW = tester.getSize(find.byKey(const Key('bc-progress-fill'))).width;
    expect(fillW, closeTo(400 * 0.5, 2.0), reason: '50/100 => 50% of 400px');
  });

  testWidgets('BcProgress complete progress is 100% fill', (tester) async {
    await tester.pumpWidget(harness(const BcProgress(value: 100, max: 100)));
    await tester.pumpAndSettle();

    final fillW = tester.getSize(find.byKey(const Key('bc-progress-fill'))).width;
    expect(fillW, closeTo(400, 2.0), reason: '100/100 => 100% fill');
  });

  testWidgets('BcProgress clamps over-max value to 100%', (tester) async {
    await tester.pumpWidget(harness(const BcProgress(value: 150, max: 100)));
    await tester.pumpAndSettle();

    final fillW = tester.getSize(find.byKey(const Key('bc-progress-fill'))).width;
    expect(fillW, closeTo(400, 2.0), reason: '150 clamps to 100%');
  });

  testWidgets('BcProgress clamps negative value to 0%', (tester) async {
    await tester.pumpWidget(harness(const BcProgress(value: -10, max: 100)));
    await tester.pumpAndSettle();

    final fillW = tester.getSize(find.byKey(const Key('bc-progress-fill'))).width;
    expect(fillW, closeTo(0, 1.0), reason: '-10 clamps to 0%');
  });

  testWidgets('BcProgress showLabel renders rounded percentage', (tester) async {
    await tester.pumpWidget(harness(const BcProgress(
      value: 33.6,
      max: 100,
      showLabel: true,
    )));
    await tester.pumpAndSettle();

    expect(find.text('34%'), findsOneWidget,
        reason: '33.6 rounds to 34');
  });

  testWidgets('BcProgress label renders on left when provided', (tester) async {
    await tester.pumpWidget(harness(const BcProgress(
      value: 50,
      max: 100,
      label: 'Uploading',
      showLabel: true,
    )));
    await tester.pumpAndSettle();

    expect(find.text('Uploading'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
  });

  testWidgets('BcProgress variant maps to correct token color', (tester) async {
    Future<void> checkVariant(BcProgressVariant v, Color expected) async {
      await tester.pumpWidget(harness(BcProgress(
        value: 50,
        max: 100,
        variant: v,
      )));
      await tester.pumpAndSettle();

      final decorated = find.descendant(
        of: find.byKey(const Key('bc-progress-fill')),
        matching: find.byType(DecoratedBox),
      );
      final box = tester.widget<DecoratedBox>(decorated);
      expect((box.decoration as BoxDecoration).color, expected);
    }

    await checkVariant(BcProgressVariant.defaultVariant, BcTheme.primary);
    await checkVariant(BcProgressVariant.success, BcTheme.success);
    await checkVariant(BcProgressVariant.warning, BcTheme.warning);
    await checkVariant(BcProgressVariant.destructive, BcTheme.destructive);
  });

  testWidgets('BcProgress size maps to track height', (tester) async {
    double heightOf(BcComponentSize s) {
      return tester.getSize(find.byKey(const Key('bc-progress'))).height;
    }

    await tester.pumpWidget(harness(const BcProgress(size: BcComponentSize.sm)));
    await tester.pumpAndSettle();
    expect(heightOf(BcComponentSize.sm), 6.0);

    await tester.pumpWidget(harness(const BcProgress(size: BcComponentSize.md)));
    await tester.pumpAndSettle();
    expect(heightOf(BcComponentSize.md), 10.0);

    await tester.pumpWidget(harness(const BcProgress(size: BcComponentSize.lg)));
    await tester.pumpAndSettle();
    expect(heightOf(BcComponentSize.lg), 16.0);
  });

  testWidgets('BcProgress custom max scales correctly', (tester) async {
    await tester.pumpWidget(harness(const BcProgress(value: 1, max: 4)));
    await tester.pumpAndSettle();

    final fillW = tester.getSize(find.byKey(const Key('bc-progress-fill'))).width;
    expect(fillW, closeTo(400 * 0.25, 2.0), reason: '1/4 => 25% fill');
  });

  testWidgets('BcProgress renders without assertion when label null and showLabel false', (tester) async {
    await tester.pumpWidget(harness(const BcProgress()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('0%'), findsNothing,
        reason: 'no label row when showLabel false and label null');
  });
}