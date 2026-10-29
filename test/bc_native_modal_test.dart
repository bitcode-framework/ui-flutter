import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_native_modal.dart';

void main() {
  group('BcNativeModal', () {
    Widget buildHarness({
      bool? open,
      bool defaultOpen = false,
      String? title,
      bool closable = true,
      bool closeOnOverlay = true,
      BcNativeModalPresentationStyle style =
          BcNativeModalPresentationStyle.formSheet,
      Widget? child,
      void Function(BcChangeMeta meta)? onClose,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 800,
            child: BcNativeModal(
              open: open,
              defaultOpen: defaultOpen,
              title: title,
              closable: closable,
              closeOnOverlay: closeOnOverlay,
              presentationStyle: style,
              onClose: onClose,
              child: child,
            ),
          ),
        ),
      );
    }

    testWidgets('defaultOpen renders the panel (VAL-G-045)', (tester) async {
      await tester.pumpWidget(buildHarness(
        defaultOpen: true,
        title: 'My Modal',
        child: const Text('Modal body'),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-native-modal-panel')), findsOneWidget);
      expect(find.text('My Modal'), findsOneWidget);
      expect(find.text('Modal body'), findsOneWidget);
    });

    testWidgets('controlled open=true shows the panel (VAL-G-046)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        open: true,
        title: 'Controlled',
        child: const Text('Content'),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-native-modal-panel')), findsOneWidget);
      expect(find.text('Controlled'), findsOneWidget);
    });

    testWidgets('open=false hides the panel (VAL-G-047)', (tester) async {
      await tester.pumpWidget(buildHarness(
        open: false,
        title: 'Hidden',
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-native-modal-panel')), findsNothing);
    });

    testWidgets('close button dismisses the modal + fires onClose '
        '(VAL-G-048)', (tester) async {
      BcChangeMeta? meta;
      await tester.pumpWidget(buildHarness(
        open: true,
        title: 'Closable',
        onClose: (m) => meta = m,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-native-modal-close')), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc-native-modal-close')));
      await tester.pumpAndSettle();

      expect(meta, isNotNull);
      expect(meta!.source, BcEventSource.pointer);
    });

    testWidgets('closable=false hides the close button (VAL-G-049)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        open: true,
        closable: false,
        title: 'No close',
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-native-modal-close')), findsNothing);
    });

    testWidgets('fullscreen style renders panel covering viewport '
        '(VAL-G-050)', (tester) async {
      await tester.pumpWidget(buildHarness(
        open: true,
        style: BcNativeModalPresentationStyle.fullscreen,
        title: 'Full',
        child: const Text('Full content'),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-native-modal-panel')), findsOneWidget);
      expect(find.text('Full'), findsOneWidget);
    });

    testWidgets('renders child slot content (VAL-G-051)', (tester) async {
      await tester.pumpWidget(buildHarness(
        open: true,
        child: Column(
          children: const [
            Text('First'),
            Text('Second'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
    });
  });
}
