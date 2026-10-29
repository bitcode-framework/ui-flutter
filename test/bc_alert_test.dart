import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_alert.dart';

void main() {
  group('BcAlert', () {
    Widget buildHarness({
      BcAlertSeverity severity = BcAlertSeverity.info,
      String? title,
      String? description,
      bool dismissible = false,
      bool hideIcon = false,
      BcChangeHandler<bool>? onDismiss,
      Widget? child,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BcAlert(
            severity: severity,
            title: title,
            description: description,
            dismissible: dismissible,
            hideIcon: hideIcon,
            onDismiss: onDismiss,
            child: child,
          ),
        ),
      );
    }

    testWidgets('renders banner with title + description (VAL-E1-001)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        title: 'Heads up',
        description: 'Customize your profile.',
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-alert-banner')), findsOneWidget);
      expect(find.text('Heads up'), findsOneWidget);
      expect(find.text('Customize your profile.'), findsOneWidget);
    });

    testWidgets('4 severity variants render distinct token accent colors '
        '(VAL-E1-002)', (tester) async {
      Color extractAccent() {
        final container = tester.widget<Container>(
          find.byKey(const Key('bc-alert-banner')),
        );
        final decoration = container.decoration as BoxDecoration;
        return decoration.border!.top.color;
      }

      final colors = <BcAlertSeverity, Color>{};
      for (final sev in [
        BcAlertSeverity.info,
        BcAlertSeverity.success,
        BcAlertSeverity.warning,
        BcAlertSeverity.error,
      ]) {
        await tester.pumpWidget(buildHarness(severity: sev, title: 'x'));
        await tester.pumpAndSettle();
        colors[sev] = extractAccent();
      }
      // All four distinct
      final distinct = colors.values.toSet();
      expect(distinct.length, 4, reason: 'each severity must use a distinct accent');
    });

    testWidgets('error exposes role=alert; others role=status (VAL-E1-003)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        severity: BcAlertSeverity.error,
        title: 'Err',
      ));
      await tester.pumpAndSettle();
      final s = tester.getSemantics(find.byKey(const Key('bc-alert-banner')));
      expect(s.role, SemanticsRole.alert);

      await tester.pumpWidget(buildHarness(
        severity: BcAlertSeverity.info,
        title: 'Info',
      ));
      await tester.pumpAndSettle();
      final s2 = tester.getSemantics(find.byKey(const Key('bc-alert-banner')));
      expect(s2.role, SemanticsRole.status);
    });

    testWidgets('dismissible=false (default) hides the close button '
        '(VAL-E1-004)', (tester) async {
      await tester.pumpWidget(buildHarness(
        title: 'Persistent',
        description: 'No close',
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-alert-close')), findsNothing);
    });

    testWidgets('dismissible=true shows close button + tap hides + emits '
        'onDismiss (VAL-E1-005)', (tester) async {
      bool? dismissed;
      BcChangeMeta? meta;
      await tester.pumpWidget(buildHarness(
        title: 'Dismissible',
        dismissible: true,
        onDismiss: (v, m) {
          dismissed = v;
          meta = m;
        },
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-alert-close')), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc-alert-close')));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
      expect(meta, isNotNull);
      expect(meta!.source, BcEventSource.pointer);
      expect(find.byKey(const Key('bc-alert-banner')), findsNothing);
    });

    testWidgets('hideIcon=true omits the leading severity icon '
        '(VAL-E1-006)', (tester) async {
      await tester.pumpWidget(buildHarness(
        severity: BcAlertSeverity.info,
        title: 'No icon',
        hideIcon: true,
      ));
      await tester.pumpAndSettle();
      // info_outline is the icon for info severity; with hideIcon it should
      // not be present.
      expect(find.byIcon(Icons.info_outline), findsNothing);
    });

    testWidgets('contract scope: no auto-dismiss timer / no action button '
        '(VAL-E1-007, distinct from BcNotification)', (tester) async {
      await tester.pumpWidget(buildHarness(
        title: 'Persistent',
        description: 'Should remain after 10s',
      ));
      await tester.pumpAndSettle();
      // Pump well beyond any plausible auto-dismiss window; banner must persist.
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-alert-banner')), findsOneWidget);
    });

    testWidgets('child slot renders below the description (VAL-E1-008)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        title: 'With child',
        description: 'Body',
        child: const Text('Extra content'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Extra content'), findsOneWidget);
    });

    testWidgets('description-only (no title) renders (VAL-E1-009)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        description: 'Just a message',
      ));
      await tester.pumpAndSettle();
      expect(find.text('Just a message'), findsOneWidget);
    });
  });
}
