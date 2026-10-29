import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_native_toast.dart';

void main() {
  group('BcNativeToast', () {
    Widget buildHarness({
      bool? open,
      bool defaultOpen = false,
      required String message,
      String? actionLabel,
      Duration duration = const Duration(seconds: 3),
      bool dismissible = true,
      BcChangeHandler<void>? onAction,
      BcChangeHandler<void>? onClose,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 800,
            child: BcNativeToast(
              open: open,
              defaultOpen: defaultOpen,
              message: message,
              actionLabel: actionLabel,
              duration: duration,
              dismissible: dismissible,
              onAction: onAction,
              onClose: onClose,
            ),
          ),
        ),
      );
    }

    testWidgets('defaultOpen renders the toast (VAL-G-052)', (tester) async {
      await tester.pumpWidget(buildHarness(
        defaultOpen: true,
        message: 'Saved!',
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-native-toast')), findsOneWidget);
      expect(find.text('Saved!'), findsOneWidget);
    });

    testWidgets('controlled open=true shows the toast (VAL-G-053)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        open: true,
        message: 'Hello',
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-native-toast')), findsOneWidget);
    });

    testWidgets('open=false hides the toast (VAL-G-054)', (tester) async {
      await tester.pumpWidget(buildHarness(
        open: false,
        message: 'Hidden',
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-native-toast')), findsNothing);
    });

    testWidgets('auto-close fires onClose after duration (VAL-G-055)',
        (tester) async {
      BcChangeMeta? meta;
      await tester.pumpWidget(buildHarness(
        open: true,
        message: 'Auto',
        duration: const Duration(milliseconds: 200),
        onClose: (_, m) => meta = m,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-native-toast')), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(meta, isNotNull);
      expect(meta!.source, BcEventSource.programmatic);
      expect(find.byKey(const Key('bc-native-toast')), findsNothing);
    });

    testWidgets('duration=0 disables auto-close (VAL-G-056)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        open: true,
        message: 'Persistent',
        duration: Duration.zero,
      ));
      await tester.pumpAndSettle();

      // Pump well beyond any plausible auto-close; toast persists.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-native-toast')), findsOneWidget);
    });

    testWidgets('action button renders when actionLabel set (VAL-G-057)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        open: true,
        message: 'Deleted',
        actionLabel: 'Undo',
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-native-toast-action')), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
    });

    testWidgets('action tap fires onAction + dismisses (VAL-G-058)',
        (tester) async {
      BcChangeMeta? meta;
      await tester.pumpWidget(buildHarness(
        open: true,
        message: 'Deleted',
        actionLabel: 'Undo',
        duration: const Duration(seconds: 30),
        onAction: (_, m) => meta = m,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-native-toast-action')));
      await tester.pumpAndSettle();

      expect(meta, isNotNull);
      expect(meta!.reason, BcChangeReason.submit);
    });

    testWidgets('manual close button fires onClose (VAL-G-059)',
        (tester) async {
      BcChangeMeta? meta;
      await tester.pumpWidget(buildHarness(
        open: true,
        message: 'Closeable',
        dismissible: true,
        duration: Duration.zero,
        onClose: (_, m) => meta = m,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-native-toast-close')));
      await tester.pumpAndSettle();

      expect(meta, isNotNull);
      expect(meta!.source, BcEventSource.pointer);
      expect(find.byKey(const Key('bc-native-toast')), findsNothing);
    });
  });
}
