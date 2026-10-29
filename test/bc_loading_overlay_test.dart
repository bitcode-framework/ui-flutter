import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_loading_overlay.dart';

void main() {
  Widget harness({required Widget child, Size size = const Size(400, 400)}) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            children: [
              const Text('content beneath'),
              child,
            ],
          ),
        ),
      ),
    );
  }

  testWidgets(
      'BcLoadingOverlay shows spinner when loading is true and hides when '
      'false (VAL-M1-024)', (tester) async {
    await tester.pumpWidget(harness(
      child: const BcLoadingOverlay(loading: true),
    ));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget,
        reason: 'Material spinner should render when loading=true');

    await tester.pumpWidget(harness(
      child: const BcLoadingOverlay(loading: false),
    ));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing,
        reason: 'no spinner should render when loading=false');

    final overlay = tester.widget<BcLoadingOverlay>(find.byType(BcLoadingOverlay));
    expect(overlay.loading, isFalse,
        reason: 'overlay should reflect loading=false state');
  });

  testWidgets(
      'BcLoadingOverlay blocks interaction with content beneath while '
      'loading (VAL-M1-025)', (tester) async {
    int tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => tapCount++,
                  child: const Text('tappable content'),
                ),
                const BcLoadingOverlay(loading: true),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('tappable content'), warnIfMissed: false);
    await tester.pump();

    expect(tapCount, 0,
        reason: 'tap should be absorbed by overlay while loading');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => tapCount++,
                  child: const Text('tappable content'),
                ),
                const BcLoadingOverlay(loading: false),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('tappable content'));
    await tester.pumpAndSettle();

    expect(tapCount, 1,
        reason: 'tap should pass through when loading is false');
  });

  testWidgets(
      'BcLoadingOverlay renders custom message text when provided '
      '(VAL-M1-026)', (tester) async {
    await tester.pumpWidget(harness(
      child: const BcLoadingOverlay(
        loading: true,
        message: 'Loading data...',
      ),
    ));
    await tester.pump();

    expect(find.text('Loading data...'), findsOneWidget,
        reason: 'message text should render alongside spinner');
    expect(find.byType(CircularProgressIndicator), findsOneWidget,
        reason: 'spinner should also be present');

    await tester.pumpWidget(harness(
      child: const BcLoadingOverlay(loading: true),
    ));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
      'BcLoadingOverlay platform selection picks Cupertino on iOS '
      '(VAL-M1-027)', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    try {
      await tester.pumpWidget(harness(
        child: const BcLoadingOverlay(loading: true),
      ));
      await tester.pump();

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget,
          reason: 'iOS should render CupertinoActivityIndicator');
      expect(find.byType(CircularProgressIndicator), findsNothing,
          reason: 'iOS should NOT render Material CircularProgressIndicator');
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }

    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    try {
      await tester.pumpWidget(harness(
        child: const BcLoadingOverlay(loading: true),
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget,
          reason: 'Android should render Material CircularProgressIndicator');
      expect(find.byType(CupertinoActivityIndicator), findsNothing,
          reason: 'Android should NOT render CupertinoActivityIndicator');
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
