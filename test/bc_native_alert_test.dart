import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_native_alert.dart';

void main() {
  group('BcNativeAlert', () {
    Widget buildHarness({Widget? child}) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 800,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      );
    }

    testWidgets('show() returns true when confirm tapped (VAL-G-033)',
        (tester) async {
      bool? result;
      await tester.pumpWidget(buildHarness(
        child: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await BcNativeAlert.show(
                  context: context,
                  title: 'Confirm?',
                  message: 'Are you sure?',
                  confirmLabel: 'Yes',
                  cancelLabel: 'No',
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('show() returns false when cancel tapped (VAL-G-034)',
        (tester) async {
      bool? result;
      await tester.pumpWidget(buildHarness(
        child: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await BcNativeAlert.show(
                  context: context,
                  title: 'Confirm?',
                  confirmLabel: 'Yes',
                  cancelLabel: 'No',
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('renders title and message (VAL-G-035)', (tester) async {
      await tester.pumpWidget(buildHarness(
        child: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => BcNativeAlert.show(
                context: context,
                title: 'Delete?',
                message: 'This is irreversible.',
                confirmLabel: 'Delete',
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Delete?'), findsOneWidget);
      expect(find.text('This is irreversible.'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('without cancelLabel only confirm renders (VAL-G-036)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        child: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => BcNativeAlert.show(
                context: context,
                title: 'Info',
                confirmLabel: 'OK',
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('OK'), findsOneWidget);
      expect(find.byKey(const Key('bc-native-alert-cancel')),
          findsNothing);
    });

    testWidgets('showWithCallbacks fires onConfirm (VAL-G-037)',
        (tester) async {
      BcChangeMeta? meta;
      bool confirmed = false;
      await tester.pumpWidget(buildHarness(
        child: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => BcNativeAlert.showWithCallbacks(
                context: context,
                title: 'Save?',
                confirmLabel: 'Save',
                cancelLabel: 'Discard',
                onConfirm: (_, m) {
                  meta = m;
                  confirmed = true;
                },
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
      expect(meta, isNotNull);
      expect(meta!.reason, BcChangeReason.confirm);
    });

    testWidgets('showWithCallbacks fires onCancel (VAL-G-038)',
        (tester) async {
      BcChangeMeta? meta;
      bool cancelled = false;
      await tester.pumpWidget(buildHarness(
        child: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => BcNativeAlert.showWithCallbacks(
                context: context,
                title: 'Save?',
                confirmLabel: 'Save',
                cancelLabel: 'Discard',
                onCancel: (_, m) {
                  meta = m;
                  cancelled = true;
                },
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(cancelled, isTrue);
      expect(meta!.reason, BcChangeReason.cancel);
    });
  });
}
