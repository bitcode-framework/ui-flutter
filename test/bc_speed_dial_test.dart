import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_speed_dial.dart';

void main() {
  group('BcSpeedDial', () {
    const testActions = [
      BcSpeedDialAction(key: 'edit', label: 'Edit'),
      BcSpeedDialAction(key: 'share', label: 'Share'),
      BcSpeedDialAction(key: 'archive', label: 'Archive', disabled: true),
    ];

    Widget buildHarness({
      bool? expanded,
      bool defaultExpanded = false,
      List<BcSpeedDialAction> actions = const [],
      BcChangeHandler<bool>? onExpandedChange,
      void Function(BcSpeedDialAction, BcChangeMeta)? onSelect,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 800,
            width: 400,
            child: BcSpeedDial(
              expanded: expanded,
              defaultExpanded: defaultExpanded,
              actions: actions.isNotEmpty ? actions : testActions,
              onExpandedChange: onExpandedChange,
              onSelect: onSelect,
            ),
          ),
        ),
      );
    }

    testWidgets(
        'FAB renders collapsed and expands to reveal sub-actions on tap '
        '(VAL-M4-015)', (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-speed-dial-fab')), findsOneWidget);
      expect(find.byKey(const Key('bc-speed-dial-actions')), findsNothing);
      expect(find.text('Edit'), findsNothing);

      await tester.tap(find.byKey(const Key('bc-speed-dial-trigger')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-speed-dial-actions')), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc-speed-dial-trigger')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-speed-dial-actions')), findsNothing);
      expect(find.text('Edit'), findsNothing);
    });

    testWidgets(
        'selecting a sub-action emits the action value and BcChangeMeta and '
        'collapses the dial (VAL-M4-016)', (tester) async {
      BcSpeedDialAction? capturedAction;
      BcChangeMeta? capturedMeta;
      int selectCount = 0;

      await tester.pumpWidget(buildHarness(
        defaultExpanded: true,
        onSelect: (action, meta) {
          capturedAction = action;
          capturedMeta = meta;
          selectCount++;
        },
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-speed-dial-actions')), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc-speed-dial-action-edit')));
      await tester.pumpAndSettle();

      expect(selectCount, 1);
      expect(capturedAction, isNotNull);
      expect(capturedAction!.key, 'edit');
      expect(capturedAction!.label, 'Edit');
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, BcChangeReason.select);
      expect(capturedMeta!.source, BcEventSource.pointer);

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-speed-dial-actions')), findsNothing);
    });

    testWidgets(
        'expanded state is controlled and does not mutate internal state '
        'until parent updates (VAL-M4-017)', (tester) async {
      bool? capturedExpanded;
      BcChangeMeta? capturedMeta;
      int callCount = 0;

      late void Function(void Function()) setStateProxy;
      bool externalExpanded = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            setStateProxy = setState;
            return MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 800,
                  width: 400,
                  child: BcSpeedDial(
                    expanded: externalExpanded,
                    actions: testActions,
                    onExpandedChange: (value, meta) {
                      capturedExpanded = value;
                      capturedMeta = meta;
                      callCount++;
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-speed-dial-fab')), findsOneWidget);
      expect(find.byKey(const Key('bc-speed-dial-actions')), findsNothing);

      await tester.tap(find.byKey(const Key('bc-speed-dial-trigger')));
      await tester.pumpAndSettle();

      expect(callCount, greaterThanOrEqualTo(1));
      expect(capturedExpanded, isTrue);
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, BcChangeReason.toggle);

      expect(find.byKey(const Key('bc-speed-dial-actions')), findsNothing);

      setStateProxy(() {
        externalExpanded = true;
      });
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-speed-dial-actions')), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc-speed-dial-trigger')));
      await tester.pumpAndSettle();

      expect(callCount, greaterThanOrEqualTo(2));
      expect(capturedExpanded, isFalse);

      expect(find.byKey(const Key('bc-speed-dial-actions')), findsOneWidget);

      setStateProxy(() {
        externalExpanded = false;
      });
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-speed-dial-actions')), findsNothing);
    });
  });
}
