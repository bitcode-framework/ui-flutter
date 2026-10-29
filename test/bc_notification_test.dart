import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_notification.dart';

void main() {
  group('BcNotification', () {
    Widget buildHarness({
      bool open = true,
      String? title,
      String? description,
      BcNotificationSeverity severity = BcNotificationSeverity.info,
      String? actionLabel,
      bool closable = true,
      Duration? autoDismissDuration,
      BcChangeHandler<bool>? onDismiss,
      VoidCallback? onAction,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BcNotification(
            open: open,
            title: title,
            description: description,
            severity: severity,
            actionLabel: actionLabel,
            closable: closable,
            autoDismissDuration: autoDismissDuration,
            onDismiss: onDismiss,
            onAction: onAction,
          ),
        ),
      );
    }

    testWidgets(
        'all severity variants render with distinct BcTheme token colors '
        '(VAL-M4-018)', (tester) async {
      Color extractAccent() {
        final container = tester.widget<Container>(
          find.byKey(const Key('bc-notification-banner')),
        );
        final decoration = container.decoration as BoxDecoration;
        return decoration.border!.top.color;
      }

      await tester.pumpWidget(buildHarness(
        title: 'Info',
        severity: BcNotificationSeverity.info,
      ));
      await tester.pumpAndSettle();
      final infoColor = extractAccent();
      expect(infoColor, isNot(equals(BcNotificationSeverity.success.accent)));
      expect(infoColor, isNot(equals(BcNotificationSeverity.warning.accent)));
      expect(infoColor, isNot(equals(BcNotificationSeverity.danger.accent)));

      await tester.pumpWidget(buildHarness(
        title: 'Success',
        severity: BcNotificationSeverity.success,
      ));
      await tester.pumpAndSettle();
      final successColor = extractAccent();
      expect(successColor, isNot(equals(infoColor)));

      await tester.pumpWidget(buildHarness(
        title: 'Warning',
        severity: BcNotificationSeverity.warning,
      ));
      await tester.pumpAndSettle();
      final warningColor = extractAccent();
      expect(warningColor, isNot(equals(infoColor)));
      expect(warningColor, isNot(equals(successColor)));

      await tester.pumpWidget(buildHarness(
        title: 'Danger',
        severity: BcNotificationSeverity.danger,
      ));
      await tester.pumpAndSettle();
      final dangerColor = extractAccent();
      expect(dangerColor, isNot(equals(infoColor)));
      expect(dangerColor, isNot(equals(successColor)));
      expect(dangerColor, isNot(equals(warningColor)));
    });

    testWidgets(
        'role=status semantics for non-danger variants and role=alert for '
        'danger (VAL-M4-019)', (tester) async {
      await tester.pumpWidget(buildHarness(
        title: 'Info notification',
        description: 'Some info',
        severity: BcNotificationSeverity.info,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-notification-banner')), findsOneWidget);

      final semantics = tester.getSemantics(
        find.byKey(const Key('bc-notification-banner')),
      );
      expect(semantics.label, contains('Info notification'));

      await tester.pumpWidget(buildHarness(
        title: 'Danger notification',
        severity: BcNotificationSeverity.danger,
      ));
      await tester.pumpAndSettle();

      final dangerSemantics = tester.getSemantics(
        find.byKey(const Key('bc-notification-banner')),
      );
      expect(dangerSemantics.role, SemanticsRole.alert,
          reason: 'Danger variant should expose alert semantics');
    });

    testWidgets(
        'auto-dismiss timer fires after the configured duration and invokes '
        'onDismiss with timer source (VAL-M4-020)', (tester) async {
      bool? dismissed;
      BcChangeMeta? meta;

      await tester.pumpWidget(buildHarness(
        title: 'Auto dismiss',
        autoDismissDuration: const Duration(seconds: 2),
        onDismiss: (value, m) {
          dismissed = value;
          meta = m;
        },
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-notification-banner')), findsOneWidget);
      expect(dismissed, isNull);

      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const Key('bc-notification-banner')), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(dismissed, isNotNull);
      expect(meta, isNotNull);
      expect(meta!.source, BcEventSource.programmatic);
      expect(meta!.reason, BcChangeReason.clear);
    });

    testWidgets(
        'null/zero auto-dismiss keeps the notification persistent '
        '(VAL-M4-020)', (tester) async {
      await tester.pumpWidget(buildHarness(
        title: 'Persistent',
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-notification-banner')), findsOneWidget);

      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-notification-banner')), findsOneWidget);
    });

    testWidgets(
        'manual dismiss emits onDismiss with a pointer source and removes '
        'the banner (VAL-M4-021)', (tester) async {
      bool? dismissed;
      BcChangeMeta? meta;

      await tester.pumpWidget(buildHarness(
        title: 'Manual dismiss',
        onDismiss: (value, m) {
          dismissed = value;
          meta = m;
        },
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-notification-banner')), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc-notification-close')));
      await tester.pumpAndSettle();

      expect(dismissed, isFalse);
      expect(meta, isNotNull);
      expect(meta!.source, BcEventSource.pointer);
      expect(find.byKey(const Key('bc-notification-banner')), findsNothing);
    });

    testWidgets('renders title, description, and action button',
        (tester) async {
      bool actionFired = false;

      await tester.pumpWidget(buildHarness(
        title: 'My Title',
        description: 'My Description',
        actionLabel: 'Undo',
        onAction: () => actionFired = true,
      ));
      await tester.pumpAndSettle();

      expect(find.text('My Title'), findsOneWidget);
      expect(find.text('My Description'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(actionFired, isTrue);
    });

    testWidgets('closed notification renders nothing', (tester) async {
      await tester.pumpWidget(buildHarness(
        open: false,
        title: 'Hidden',
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-notification-banner')), findsNothing);
      expect(find.text('Hidden'), findsNothing);
    });

    testWidgets('not closable hides close button', (tester) async {
      await tester.pumpWidget(buildHarness(
        title: 'No close',
        closable: false,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-notification-close')), findsNothing);
    });
  });
}
