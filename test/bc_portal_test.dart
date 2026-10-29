import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_portal.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

/// Widget tests for [BcPortal] (ADR-011 Phase 5b.2).
///
/// Covers the 12 VAL-PORTAL assertions from the validation contract:
/// controlled open prop mounts/unmounts an Overlay, Escape fires
/// onRequestClose with [BcChangeReason.escape], hardware back fires with
/// [BcChangeReason.back], `name` exposes a Key for tests, multiple
/// instances stack independently, the portal survives parent rebuilds,
/// and `animation`/`className` props are accepted without error.
void main() {
  Widget harness(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('BcPortal closed does not render children (VAL-PORTAL-001)',
      (tester) async {
    await tester.pumpWidget(harness(
      const BcPortal(open: false, child: Text('In overlay')),
    ));
    expect(find.text('In overlay'), findsNothing);
  });

  testWidgets('BcPortal open renders children in overlay (VAL-PORTAL-002)',
      (tester) async {
    await tester.pumpWidget(harness(
      const BcPortal(open: true, child: Text('In overlay')),
    ));
    await tester.pump();
    expect(find.text('In overlay'), findsOneWidget);
  });

  testWidgets('BcPortal open true mounts overlay (VAL-PORTAL-003)',
      (tester) async {
    bool open = false;
    await tester.pumpWidget(harness(
      StatefulBuilder(
        builder: (context, _) {
          return BcPortal(open: open, child: const Text('In overlay'));
        },
      ),
    ));
    await tester.pump();
    expect(find.text('In overlay'), findsNothing);

    open = true;
    await tester.pumpWidget(harness(
      StatefulBuilder(
        builder: (context, _) {
          return BcPortal(open: open, child: const Text('In overlay'));
        },
      ),
    ));
    await tester.pump();

    expect(find.text('In overlay'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('BcPortal open false unmounts overlay (VAL-PORTAL-004)',
      (tester) async {
    bool open = true;
    await tester.pumpWidget(harness(
      StatefulBuilder(
        builder: (context, _) {
          return BcPortal(open: open, child: const Text('In overlay'));
        },
      ),
    ));
    await tester.pump();
    expect(find.text('In overlay'), findsOneWidget);

    open = false;
    await tester.pumpWidget(harness(
      StatefulBuilder(
        builder: (context, _) {
          return BcPortal(open: open, child: const Text('In overlay'));
        },
      ),
    ));
    await tester.pump();

    expect(find.text('In overlay'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('BcPortal name prop exposes key (VAL-PORTAL-005)',
      (tester) async {
    await tester.pumpWidget(harness(
      const BcPortal(open: true, name: 'my-portal', child: Text('x')),
    ));
    await tester.pump();
    expect(find.byKey(const ValueKey<String>('bc-portal-my-portal')),
        findsOneWidget);
  });

  testWidgets('BcPortal escape fires onRequestClose (VAL-PORTAL-006)',
      (tester) async {
    BcChangeReason? captured;
    await tester.pumpWidget(harness(
      BcPortal(
        open: true,
        child: const Focus(child: SizedBox()),
        onRequestClose: (meta) {
          captured = meta?.reason;
        },
      ),
    ));
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    expect(captured, BcChangeReason.escape);
  });

  testWidgets('BcPortal back fires onRequestClose (VAL-PORTAL-007)',
      (tester) async {
    BcChangeReason? captured;
    await tester.pumpWidget(harness(
      BcPortal(
        open: true,
        child: const Focus(child: SizedBox()),
        onRequestClose: (meta) {
          captured = meta?.reason;
        },
      ),
    ));
    await tester.pump();

    // Simulate the system back button via the navigation channel (the same
    // path PopScope / Navigator receive the gesture on hardware back).
    await _simulateSystemBack(tester);
    await tester.pump();

    expect(captured, BcChangeReason.back);
  });

  testWidgets('BcPortal survives parent rebuild (VAL-PORTAL-008)',
      (tester) async {
    int rebuildCount = 0;
    await tester.pumpWidget(harness(
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: <Widget>[
              Text('count-$rebuildCount'),
              TextButton(
                onPressed: () =>
                    setState(() => rebuildCount++),
                child: const Text('rebuild'),
              ),
              const BcPortal(open: true, child: Text('Persist')),
            ],
          );
        },
      ),
    ));
    await tester.pump();
    expect(find.text('Persist'), findsOneWidget);

    await tester.tap(find.text('rebuild'));
    await tester.pump();

    expect(find.text('count-1'), findsOneWidget);
    expect(find.text('Persist'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('BcPortal multiple instances independent (VAL-PORTAL-009)',
      (tester) async {
    bool firstOpen = true;
    bool secondOpen = true;
    await tester.pumpWidget(harness(
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: <Widget>[
              BcPortal(open: firstOpen, child: const Text('First')),
              BcPortal(open: secondOpen, child: const Text('Second')),
              TextButton(
                onPressed: () => setState(() => firstOpen = false),
                child: const Text('close-first'),
              ),
            ],
          );
        },
      ),
    ));
    await tester.pump();
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);

    await tester.tap(find.text('close-first'));
    await tester.pump();
    await tester.pump();

    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);
  });

  testWidgets('BcPortal animation prop accepted (VAL-PORTAL-010)',
      (tester) async {
    await tester.pumpWidget(harness(
      const BcPortal(
        open: true,
        animation: BcPortalAnimation.fade,
        child: Text('x'),
      ),
    ));
    await tester.pump();
    expect(find.text('x'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('BcPortal close restores focus (VAL-PORTAL-011)',
      (tester) async {
    final FocusNode triggerNode = FocusNode();
    bool open = false;
    await tester.pumpWidget(harness(
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: <Widget>[
              Focus(
                focusNode: triggerNode,
                child: const Text('Trigger'),
              ),
              BcPortal(open: open, child: const Text('Portal content')),
              TextButton(
                onPressed: () => setState(() => open = true),
                child: const Text('open'),
              ),
              TextButton(
                onPressed: () => setState(() => open = false),
                child: const Text('close'),
              ),
            ],
          );
        },
      ),
    ));

    triggerNode.requestFocus();
    await tester.pump();
    expect(FocusManager.instance.primaryFocus, triggerNode);

    await tester.tap(find.text('open'));
    await tester.pump();

    await tester.tap(find.text('close'));
    await tester.pump();
    await tester.pump();

    expect(FocusManager.instance.primaryFocus, triggerNode);
    triggerNode.dispose();
  });

  testWidgets('BcPortal className prop accepted (VAL-PORTAL-012)',
      (tester) async {
    await tester.pumpWidget(harness(
      const BcPortal(open: true, className: 'custom', child: Text('x')),
    ));
    await tester.pump();
    expect(find.text('x'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

/// Simulate a hardware back button press by invoking the navigation
/// channel's `popRoute` method, which is the same path Flutter's
/// `Navigator` and `PopScope` receive system back gestures through.
/// The navigation channel uses [JSONMethodCodec], so we must use the
/// matching codec from [SystemChannels.navigation].
Future<void> _simulateSystemBack(WidgetTester tester) async {
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec
        .encodeMethodCall(const MethodCall('popRoute')),
    (ByteData? data) {},
  );
}
