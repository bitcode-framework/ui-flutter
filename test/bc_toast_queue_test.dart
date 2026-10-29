import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_toast_queue.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness({required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 600,
          child: Stack(
            children: [const Text('content'), child],
          ),
        ),
      ),
    );
  }

  group('VAL-M1-062: show adds a toast to the queue and renders it', () {
    testWidgets('controller show renders a single toast message',
        (tester) async {
      final controller = BcToastQueueController();

      await tester.pumpWidget(harness(child: BcToastQueue(controller: controller)));
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsNothing);

      controller.show(const BcToastEntry(id: 't1', message: 'Hello'));
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsOneWidget,
          reason: 'toast message should render after show()');
    });

    testWidgets('multiple show calls render toasts in queue order',
        (tester) async {
      final controller = BcToastQueueController();

      await tester.pumpWidget(harness(child: BcToastQueue(controller: controller)));
      await tester.pumpAndSettle();

      controller.show(const BcToastEntry(id: 't1', message: 'First'));
      controller.show(const BcToastEntry(id: 't2', message: 'Second'));
      controller.show(const BcToastEntry(id: 't3', message: 'Third'));
      await tester.pumpAndSettle();

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);

      final firstCenter = tester.getCenter(find.text('First'));
      final thirdCenter = tester.getCenter(find.text('Third'));
      expect(firstCenter.dy, lessThan(thirdCenter.dy),
          reason: 'first toast should appear above the third (queue order)');
    });
  });

  group('VAL-M1-063: auto-dismiss after duration fires onDismiss with meta', () {
    testWidgets('toast auto-dismisses after duration and fires onDismiss',
        (tester) async {
      final controller = BcToastQueueController();
      BcChangeMeta? capturedMeta;
      String? dismissedId;

      await tester.pumpWidget(harness(
        child: BcToastQueue(
          controller: controller,
          onDismiss: (id, meta) {
            dismissedId = id;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      controller.show(const BcToastEntry(
        id: 't1',
        message: 'Auto',
        duration: Duration(seconds: 2),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Auto'), findsOneWidget,
          reason: 'toast should be visible before duration elapses');

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Auto'), findsOneWidget,
          reason: 'toast should still be visible halfway through duration');

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Auto'), findsNothing,
          reason: 'toast should be removed after duration elapses');
      expect(dismissedId, 't1',
          reason: 'onDismiss should carry the toast id');
      expect(capturedMeta, isNotNull,
          reason: 'onDismiss should carry BcChangeMeta');
      expect(capturedMeta!.reason, BcChangeReason.clear,
          reason: 'auto-dismiss reason should indicate timeout/clear');
    });

    testWidgets('sticky toast (duration null) does not auto-dismiss',
        (tester) async {
      final controller = BcToastQueueController();
      int dismissCount = 0;

      await tester.pumpWidget(harness(
        child: BcToastQueue(
          controller: controller,
          onDismiss: (_, __) => dismissCount++,
        ),
      ));
      await tester.pumpAndSettle();

      controller.show(const BcToastEntry(
        id: 'sticky',
        message: 'Persistent',
        duration: null,
      ));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();

      expect(find.text('Persistent'), findsOneWidget,
          reason: 'sticky toast should remain visible');
      expect(dismissCount, 0,
          reason: 'sticky toast should not auto-dismiss');
    });
  });

  group('VAL-M1-064: manual dismiss removes the toast immediately', () {
    testWidgets('tapping close removes toast and fires onDismiss with pointer source',
        (tester) async {
      final controller = BcToastQueueController();
      BcChangeMeta? capturedMeta;
      String? dismissedId;

      await tester.pumpWidget(harness(
        child: BcToastQueue(
          controller: controller,
          onDismiss: (id, meta) {
            dismissedId = id;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      controller.show(const BcToastEntry(
        id: 't1',
        message: 'Dismiss me',
        duration: null,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Dismiss me'), findsOneWidget);

      final closeFinder = find.byKey(const Key('bc-toast-dismiss-t1'));
      expect(closeFinder, findsOneWidget,
          reason: 'toast should have a close/dismiss control');

      await tester.tap(closeFinder);
      await tester.pumpAndSettle();

      expect(find.text('Dismiss me'), findsNothing,
          reason: 'toast should be removed immediately after close tap');
      expect(dismissedId, 't1');
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.source, BcEventSource.pointer,
          reason: 'manual dismiss source should indicate pointer');
    });

    testWidgets('dismissing one toast leaves others unaffected', (tester) async {
      final controller = BcToastQueueController();

      await tester.pumpWidget(harness(child: BcToastQueue(controller: controller)));
      await tester.pumpAndSettle();

      controller.show(const BcToastEntry(id: 't1', message: 'First', duration: null));
      controller.show(const BcToastEntry(id: 't2', message: 'Second', duration: null));
      await tester.pumpAndSettle();

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc-toast-dismiss-t1')));
      await tester.pumpAndSettle();

      expect(find.text('First'), findsNothing,
          reason: 'dismissed toast should be gone');
      expect(find.text('Second'), findsOneWidget,
          reason: 'other toasts should remain');
    });
  });

  group('VAL-M1-065: respects max count by evicting oldest', () {
    testWidgets('exceeding max evicts oldest and fires onDismiss with eviction reason',
        (tester) async {
      final controller = BcToastQueueController(max: 2);
      final Map<String, BcChangeMeta> dismissed = {};

      await tester.pumpWidget(harness(
        child: BcToastQueue(
          controller: controller,
          onDismiss: (id, meta) => dismissed[id] = meta,
        ),
      ));
      await tester.pumpAndSettle();

      controller.show(const BcToastEntry(id: 't1', message: 'One', duration: null));
      controller.show(const BcToastEntry(id: 't2', message: 'Two', duration: null));
      await tester.pumpAndSettle();

      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);

      controller.show(const BcToastEntry(id: 't3', message: 'Three', duration: null));
      await tester.pumpAndSettle();

      expect(find.text('One'), findsNothing,
          reason: 'oldest toast should be evicted to make room');
      expect(find.text('Two'), findsOneWidget);
      expect(find.text('Three'), findsOneWidget,
          reason: 'new toast should be appended');

      expect(dismissed.containsKey('t1'), isTrue,
          reason: 'evicted toast onDismiss should fire');
      expect(dismissed['t1']!.reason, BcChangeReason.clear,
          reason: 'eviction reason should indicate max-count eviction');
    });

    testWidgets('controller maxRetained drops oldest beyond cap', (tester) async {
      final controller = BcToastQueueController(max: 3);

      await tester.pumpWidget(harness(child: BcToastQueue(controller: controller)));
      await tester.pumpAndSettle();

      controller.show(const BcToastEntry(id: '1', message: 'msg1', duration: null));
      controller.show(const BcToastEntry(id: '2', message: 'msg2', duration: null));
      controller.show(const BcToastEntry(id: '3', message: 'msg3', duration: null));
      controller.show(const BcToastEntry(id: '4', message: 'msg4', duration: null));
      await tester.pumpAndSettle();

      expect(controller.toasts.length, 3);
      expect(find.text('msg1'), findsNothing,
          reason: 'oldest "msg1" evicted');
      expect(find.text('msg2'), findsOneWidget);
      expect(find.text('msg3'), findsOneWidget);
      expect(find.text('msg4'), findsOneWidget);
    });
  });

  group('Controller behavior parity', () {
    testWidgets('show with explicit id replaces existing (dedupe)', (tester) async {
      final controller = BcToastQueueController();

      await tester.pumpWidget(harness(child: BcToastQueue(controller: controller)));
      await tester.pumpAndSettle();

      controller.show(const BcToastEntry(id: 'fixed', message: 'first'));
      controller.show(const BcToastEntry(id: 'fixed', message: 'second'));
      await tester.pumpAndSettle();

      expect(controller.toasts.length, 1);
      expect(find.text('first'), findsNothing);
      expect(find.text('second'), findsOneWidget);
    });

    testWidgets('dismiss programmatically removes toast', (tester) async {
      final controller = BcToastQueueController();

      await tester.pumpWidget(harness(child: BcToastQueue(controller: controller)));
      await tester.pumpAndSettle();

      controller.show(const BcToastEntry(id: 't1', message: 'Prog', duration: null));
      await tester.pumpAndSettle();

      controller.dismiss('t1');
      await tester.pumpAndSettle();

      expect(find.text('Prog'), findsNothing);
      expect(controller.toasts, isEmpty);
    });

    testWidgets('clear removes all toasts', (tester) async {
      final controller = BcToastQueueController();

      await tester.pumpWidget(harness(child: BcToastQueue(controller: controller)));
      await tester.pumpAndSettle();

      controller.show(const BcToastEntry(id: 't1', message: 'A', duration: null));
      controller.show(const BcToastEntry(id: 't2', message: 'B', duration: null));
      await tester.pumpAndSettle();

      controller.clear();
      await tester.pumpAndSettle();

      expect(find.text('A'), findsNothing);
      expect(find.text('B'), findsNothing);
      expect(controller.toasts, isEmpty);
    });

    testWidgets('severity sugar helpers set level', (tester) async {
      final controller = BcToastQueueController();

      await tester.pumpWidget(harness(child: BcToastQueue(controller: controller)));
      await tester.pumpAndSettle();

      controller.info('i');
      controller.success('s');
      controller.warning('w');
      controller.error('e');
      await tester.pumpAndSettle();

      final levels = controller.toasts.map((t) => t.level).toList();
      expect(levels, [
        BcToastLevel.info,
        BcToastLevel.success,
        BcToastLevel.warning,
        BcToastLevel.error,
      ]);
    });
  });

  group('Rendering and a11y', () {
    testWidgets('renders description when provided', (tester) async {
      final controller = BcToastQueueController();

      await tester.pumpWidget(harness(child: BcToastQueue(controller: controller)));
      await tester.pumpAndSettle();

      controller.show(const BcToastEntry(
        id: 't1',
        message: 'Main message',
        description: 'Secondary detail',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Main message'), findsOneWidget);
      expect(find.text('Secondary detail'), findsOneWidget);
    });

    testWidgets('empty queue renders no toast messages', (tester) async {
      final controller = BcToastQueueController();

      await tester.pumpWidget(harness(child: BcToastQueue(controller: controller)));
      await tester.pumpAndSettle();

      expect(find.byType(BcToast), findsNothing);
    });

    testWidgets('controlled toasts prop reflects external list', (tester) async {
      await tester.pumpWidget(harness(
        child: const BcToastQueue(
          toasts: [
            BcToastEntry(id: 'c1', message: 'Controlled toast'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Controlled toast'), findsOneWidget);
    });
  });
}
