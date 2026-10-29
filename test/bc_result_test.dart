import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_result.dart';
import 'package:bc_ui_flutter/src/theme/bc_theme.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 400,
          child: SingleChildScrollView(child: child),
        ),
      ),
    );
  }

  testWidgets(
      'BcResult renders success status with icon, title, subtitle, and '
      'actions (VAL-M1-042)', (tester) async {
    int actionACount = 0;
    int actionBCount = 0;

    await tester.pumpWidget(harness(
      BcResult(
        status: BcResultStatus.success,
        title: 'Payment Successful',
        subtitle: 'Your order has been confirmed',
        actions: [
          GestureDetector(
            onTap: () => actionACount++,
            child: const Text('View Order'),
          ),
          GestureDetector(
            onTap: () => actionBCount++,
            child: const Text('Go Home'),
          ),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Payment Successful'), findsOneWidget,
        reason: 'title should render');
    expect(find.text('Your order has been confirmed'), findsOneWidget,
        reason: 'subtitle should render');
    expect(find.text('View Order'), findsOneWidget,
        reason: 'action A should render');
    expect(find.text('Go Home'), findsOneWidget,
        reason: 'action B should render');

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.color, BcTheme.success,
        reason: 'icon color should resolve from success token');

    await tester.tap(find.text('View Order'));
    await tester.pumpAndSettle();
    expect(actionACount, 1);
  });

  testWidgets(
      'BcResult status change swaps icon and color (VAL-M1-043)',
      (tester) async {
        await tester.pumpWidget(harness(
          const BcResult(
            status: BcResultStatus.success,
            title: 'Done',
          ),
        ));
        await tester.pumpAndSettle();

        var icon = tester.widget<Icon>(find.byType(Icon));
        expect(icon.color, BcTheme.success,
            reason: 'success status should use success token color');

        await tester.pumpWidget(harness(
          const BcResult(
            status: BcResultStatus.error,
            title: 'Failed',
          ),
        ));
        await tester.pumpAndSettle();

        icon = tester.widget<Icon>(find.byType(Icon));
        expect(icon.color, BcTheme.destructive,
            reason: 'error status should use destructive token color');

        await tester.pumpWidget(harness(
          const BcResult(
            status: BcResultStatus.warning,
            title: 'Warning',
          ),
        ));
        await tester.pumpAndSettle();

        icon = tester.widget<Icon>(find.byType(Icon));
        expect(icon.color, BcTheme.warning,
            reason: 'warning status should use warning token color');

        await tester.pumpWidget(harness(
          const BcResult(
            status: BcResultStatus.info,
            title: 'Info',
          ),
        ));
        await tester.pumpAndSettle();

        icon = tester.widget<Icon>(find.byType(Icon));
        expect(icon.color, BcTheme.info,
            reason: 'info status should use info token color');
      });

  testWidgets(
      'BcResult action tap fires the corresponding callback '
      '(VAL-M1-044)', (tester) async {
    int aCount = 0;
    int bCount = 0;

    await tester.pumpWidget(harness(
      BcResult(
        status: BcResultStatus.info,
        title: 'Choose',
        actions: [
          GestureDetector(
            onTap: () => aCount++,
            child: const Text('Action A'),
          ),
          GestureDetector(
            onTap: () => bCount++,
            child: const Text('Action B'),
          ),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Action A'));
    await tester.pumpAndSettle();
    expect(aCount, 1, reason: 'action A callback should fire');
    expect(bCount, 0, reason: 'action B callback should NOT fire');

    await tester.tap(find.text('Action B'));
    await tester.pumpAndSettle();
    expect(aCount, 1, reason: 'action A callback should still be 1');
    expect(bCount, 1, reason: 'action B callback should fire');
  });

  testWidgets(
      'BcResult renders with title only (subtitle/actions optional) '
      '(VAL-M1-045)', (tester) async {
    await tester.pumpWidget(harness(
      const BcResult(
        status: BcResultStatus.info,
        title: 'Just a title',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Just a title'), findsOneWidget,
        reason: 'title should render');
    expect(find.byType(Icon), findsOneWidget,
        reason: 'icon should still render');
  });
}
