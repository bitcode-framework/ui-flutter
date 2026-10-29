import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_toggle_group.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness({required BcToggleGroup child}) {
    return MaterialApp(home: Scaffold(body: Center(child: child)));
  }

  final options = <BcToggleGroupOption>[
    const BcToggleGroupOption(label: 'A', value: 'a'),
    const BcToggleGroupOption(label: 'B', value: 'b'),
    const BcToggleGroupOption(label: 'C', value: 'c'),
  ];

  group('BcToggleGroup — VAL-M2-032 (single mode)', () {
    testWidgets('Selecting an inactive toggle emits the value', (tester) async {
      dynamic emitted;
      BcChangeMeta? meta;

      await tester.pumpWidget(harness(
        child: BcToggleGroup(
          multiple: false,
          options: options,
          onChange: (v, m) {
            emitted = v;
            meta = m;
          },
        ),
      ));

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();

      expect(emitted, 'b');
      expect(meta!.reason, BcChangeReason.select);
    });

    testWidgets('Re-clicking the active toggle clears to empty', (tester) async {
      dynamic emitted;
      BcChangeMeta? meta;

      await tester.pumpWidget(harness(
        child: BcToggleGroup(
          multiple: false,
          defaultValue: 'b',
          options: options,
          onChange: (v, m) {
            emitted = v;
            meta = m;
          },
        ),
      ));

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();

      expect(emitted, '');
      expect(meta!.reason, BcChangeReason.deselect);
    });
  });

  group('BcToggleGroup — VAL-M2-033 (multi mode)', () {
    testWidgets('Clicking a toggle adds its value to the list', (tester) async {
      dynamic emitted;
      BcChangeMeta? meta;

      await tester.pumpWidget(harness(
        child: BcToggleGroup(
          multiple: true,
          defaultValue: const ['a'],
          options: options,
          onChange: (v, m) {
            emitted = v;
            meta = m;
          },
        ),
      ));

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();

      expect(emitted, isA<List<String>>());
      expect(emitted as List<String>, containsAll(['a', 'b']));
      expect(meta!.reason, BcChangeReason.select);
    });

    testWidgets('Clicking an active toggle removes it from the list', (tester) async {
      dynamic emitted;
      BcChangeMeta? meta;

      await tester.pumpWidget(harness(
        child: BcToggleGroup(
          multiple: true,
          defaultValue: const ['a', 'b'],
          options: options,
          onChange: (v, m) {
            emitted = v;
            meta = m;
          },
        ),
      ));

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      expect(emitted as List<String>, ['b']);
      expect(meta!.reason, BcChangeReason.deselect);
    });
  });

  group('BcToggleGroup — VAL-M2-034 (disabled)', () {
    testWidgets('Group-disabled blocks all interaction', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        child: BcToggleGroup(
          multiple: false,
          disabled: true,
          options: options,
          onChange: (_, __) => callCount++,
        ),
      ));

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });

    testWidgets('Per-option disabled blocks that option but not siblings', (tester) async {
      int callCount = 0;
      final optsWithDisabled = <BcToggleGroupOption>[
        const BcToggleGroupOption(label: 'A', value: 'a', disabled: true),
        const BcToggleGroupOption(label: 'B', value: 'b'),
      ];

      await tester.pumpWidget(harness(
        child: BcToggleGroup(
          multiple: false,
          options: optsWithDisabled,
          onChange: (_, __) => callCount++,
        ),
      ));

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      expect(callCount, 0);

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(callCount, 1);
    });
  });
}
