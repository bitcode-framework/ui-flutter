import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_affix.dart';

void main() {
  group('BcAffix', () {
    Widget buildScrollable({
      required double offsetTop,
      double? offsetBottom,
      BcChangeHandler<bool>? onAffixChange,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 400,
            width: 400,
            child: SingleChildScrollView(
              key: const Key('affix-scroll'),
              child: Column(
                children: [
                  const SizedBox(height: 200, child: Text('spacer')),
                  BcAffix(
                    offsetTop: offsetTop,
                    offsetBottom: offsetBottom,
                    onAffixChange: onAffixChange,
                    child: Container(
                      key: const Key('affixed-content'),
                      height: 80,
                      color: Colors.red,
                      child: const Text('Affixed'),
                    ),
                  ),
                  const SizedBox(height: 800, child: Text('tail')),
                ],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('pins content past scroll threshold (VAL-M3-021)',
        (tester) async {
      bool? lastPinned;
      await tester.pumpWidget(
        buildScrollable(
          offsetTop: 100,
          onAffixChange: (pinned, _) => lastPinned = pinned,
        ),
      );
      await tester.pumpAndSettle();

      expect(lastPinned, isNull);

      await tester.drag(
        find.byKey(const Key('affix-scroll')),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      expect(lastPinned, isTrue);

      await tester.drag(
        find.byKey(const Key('affix-scroll')),
        const Offset(0, 200),
      );
      await tester.pumpAndSettle();

      expect(lastPinned, isFalse);
    });

    testWidgets('respects bottom offset (VAL-M3-022)', (tester) async {
      final pinnedHistory = <bool>[];
      await tester.pumpWidget(
        buildScrollable(
          offsetTop: 50,
          offsetBottom: 200,
          onAffixChange: (pinned, _) => pinnedHistory.add(pinned),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const Key('affix-scroll')),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      expect(pinnedHistory.last, isTrue);

      await tester.drag(
        find.byKey(const Key('affix-scroll')),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();

      expect(pinnedHistory.last, isFalse);
    });

    testWidgets('emits state change with meta (VAL-M3-023)', (tester) async {
      bool? capturedPinned;
      BcChangeMeta? capturedMeta;
      int callCount = 0;

      await tester.pumpWidget(
        buildScrollable(
          offsetTop: 100,
          onAffixChange: (pinned, meta) {
            capturedPinned = pinned;
            capturedMeta = meta;
            callCount++;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const Key('affix-scroll')),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      expect(callCount, greaterThanOrEqualTo(1));
      expect(capturedPinned, isTrue);
      expect(capturedMeta, isNotNull);
    });

    testWidgets('no-op without scrollable ancestor (VAL-M3-024)',
        (tester) async {
      bool? capturedPinned;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BcAffix(
                offsetTop: 50,
                onAffixChange: (pinned, _) {
                  capturedPinned = pinned;
                },
                child: const SizedBox(
                  key: Key('affixed-content'),
                  height: 80,
                  child: Text('Affixed'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('affixed-content')), findsOneWidget);
      expect(find.text('Affixed'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));

      expect(capturedPinned, isNull);
    });
  });
}
