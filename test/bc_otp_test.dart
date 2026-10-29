import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_otp.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  testWidgets(
      'BcOtp renders N digit boxes per length (VAL-M1-046)', (tester) async {
    await tester.pumpWidget(harness(
      const BcOtp(name: 'code', length: 6),
    ));
    await tester.pumpAndSettle();

    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(6),
        reason: 'Should render exactly 6 input cells for length: 6');

    for (var i = 0; i < 6; i++) {
      expect(find.byKey(ValueKey('otp_cell_$i')), findsOneWidget,
          reason: 'Cell $i should have a stable key');
    }
  });

  testWidgets(
      'BcOtp emits complete code with BcChangeMeta when all cells filled '
      '(VAL-M1-047)', (tester) async {
    String? changedValue;
    BcChangeMeta? changedMeta;
    String? completedValue;

    await tester.pumpWidget(harness(
      BcOtp(
        name: 'code',
        length: 6,
        onValueChange: (value, meta) {
          changedValue = value;
          changedMeta = meta;
        },
        onComplete: (value) {
          completedValue = value;
        },
      ),
    ));
    await tester.pumpAndSettle();

    final cells = find.byType(TextField);
    for (var i = 0; i < 6; i++) {
      await tester.enterText(cells.at(i), '${i + 1}');
      await tester.pump();
    }

    expect(changedValue, '123456',
        reason: 'onValueChange should fire with the full code string');
    expect(changedMeta, isNotNull,
        reason: 'BcChangeMeta should be provided');
    expect(completedValue, '123456',
        reason: 'onComplete should fire with full code when all cells filled');
  });

  testWidgets(
      'BcOtp partial entry does not fire onComplete (VAL-M1-047)',
      (tester) async {
    String? completedValue;

    await tester.pumpWidget(harness(
      BcOtp(
        name: 'code',
        length: 6,
        onComplete: (value) {
          completedValue = value;
        },
      ),
    ));
    await tester.pumpAndSettle();

    final cells = find.byType(TextField);
    await tester.enterText(cells.at(0), '1');
    await tester.pump();
    await tester.enterText(cells.at(1), '2');
    await tester.pump();

    expect(completedValue, isNull,
        reason: 'onComplete should NOT fire until all cells are filled');
  });

  testWidgets(
      'BcOtp controlled value syncs cells and ignores partial external '
      'values (VAL-M1-048)', (tester) async {
    await tester.pumpWidget(harness(
      const BcOtp(
        name: 'code',
        length: 6,
        value: '12',
      ),
    ));
    await tester.pumpAndSettle();

    final cells = find.byType(TextField);
    expect(
        (tester.widget<TextField>(cells.at(0))).controller!.text, '1',
        reason: 'First cell should show "1" from partial controlled value');
    expect(
        (tester.widget<TextField>(cells.at(1))).controller!.text, '2',
        reason: 'Second cell should show "2" from partial controlled value');
    expect(
        (tester.widget<TextField>(cells.at(2))).controller!.text, '',
        reason: 'Remaining cells should be empty for partial value');
  });

  testWidgets(
      'BcOtp controlled value fills all cells when full (VAL-M1-048)',
      (tester) async {
    await tester.pumpWidget(harness(
      const BcOtp(
        name: 'code',
        length: 6,
        value: '123456',
      ),
    ));
    await tester.pumpAndSettle();

    final cells = find.byType(TextField);
    for (var i = 0; i < 6; i++) {
      expect(
          (tester.widget<TextField>(cells.at(i))).controller!.text,
          '${i + 1}',
          reason: 'Cell $i should show "${i + 1}"');
    }
  });

  testWidgets(
      'BcOtp external value longer than length is clamped (VAL-M1-048)',
      (tester) async {
    await tester.pumpWidget(harness(
      const BcOtp(
        name: 'code',
        length: 4,
        value: '123456789',
      ),
    ));
    await tester.pumpAndSettle();

    final cells = find.byType(TextField);
    expect(cells, findsNWidgets(4),
        reason: 'Should only render length=4 cells');
    expect(
        (tester.widget<TextField>(cells.at(0))).controller!.text, '1');
    expect(
        (tester.widget<TextField>(cells.at(3))).controller!.text, '4');
  });

  testWidgets(
      'BcOtp disabled blocks input (VAL-M1-049)', (tester) async {
    String? changedValue;

    await tester.pumpWidget(harness(
      BcOtp(
        name: 'code',
        length: 6,
        disabled: true,
        onValueChange: (value, meta) {
          changedValue = value;
        },
      ),
    ));
    await tester.pumpAndSettle();

    final cells = find.byType(TextField);
    await tester.enterText(cells.at(0), '1');
    await tester.pump();

    expect(changedValue, isNull,
        reason: 'onValueChange should NOT fire when disabled');
    expect((tester.widget<TextField>(cells.at(0))).enabled, isFalse,
        reason: 'Cells should render disabled state');
  });

  testWidgets(
      'BcOtp readOnly blocks input (VAL-M1-049)', (tester) async {
    String? changedValue;

    await tester.pumpWidget(harness(
      BcOtp(
        name: 'code',
        length: 6,
        readOnly: true,
        onValueChange: (value, meta) {
          changedValue = value;
        },
      ),
    ));
    await tester.pumpAndSettle();

    final cells = find.byType(TextField);
    await tester.enterText(cells.at(0), '1');
    await tester.pump();

    expect(changedValue, isNull,
        reason: 'onValueChange should NOT fire when readOnly');
    expect((tester.widget<TextField>(cells.at(0))).readOnly, isTrue,
        reason: 'Cells should render readOnly state');
  });

  testWidgets(
      'BcOtp renders label when provided', (tester) async {
    await tester.pumpWidget(harness(
      const BcOtp(name: 'code', length: 6, label: 'Verification Code'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Verification Code'), findsOneWidget,
        reason: 'Label should render above the cells');
  });
}
