import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_follow.dart';

void main() {
  group('BcFollow', () {
    Widget buildHarness({
      bool? following,
      bool defaultFollowing = false,
      int? count,
      bool disabled = false,
      String followLabel = 'Follow',
      String followingLabel = 'Following',
      BcChangeHandler<bool>? onFollowingChange,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BcFollow(
            following: following,
            defaultFollowing: defaultFollowing,
            count: count,
            disabled: disabled,
            followLabel: followLabel,
            followingLabel: followingLabel,
            onFollowingChange: onFollowingChange,
          ),
        ),
      );
    }

    testWidgets('renders Follow label by default (VAL-B2-001)', (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();
      expect(find.text('Follow'), findsOneWidget);
    });

    testWidgets('defaultFollowing=true renders Following label (VAL-B2-002)',
        (tester) async {
      await tester.pumpWidget(buildHarness(defaultFollowing: true));
      await tester.pumpAndSettle();
      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('count renders when provided (VAL-B2-003)', (tester) async {
      await tester.pumpWidget(buildHarness(count: 1234));
      await tester.pumpAndSettle();
      expect(find.text('1234'), findsOneWidget);
    });

    testWidgets('tap toggles uncontrolled + emits onFollowingChange with pointer source (VAL-B2-004)',
        (tester) async {
      bool? captured;
      BcChangeMeta? meta;
      await tester.pumpWidget(buildHarness(
        defaultFollowing: false,
        onFollowingChange: (v, m) {
          captured = v;
          meta = m;
        },
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-follow-root')));
      await tester.pumpAndSettle();
      expect(captured, isTrue);
      expect(meta, isNotNull);
      expect(meta!.source, BcEventSource.pointer);
      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('controlled following drives label (VAL-B2-005)', (tester) async {
      await tester.pumpWidget(buildHarness(following: true));
      await tester.pumpAndSettle();
      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('disabled does not toggle (VAL-B2-006)', (tester) async {
      bool? captured;
      await tester.pumpWidget(buildHarness(
        disabled: true,
        onFollowingChange: (v, _) => captured = v,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-follow-root')));
      await tester.pumpAndSettle();
      expect(captured, isNull);
    });

    testWidgets('custom labels render (VAL-B2-007)', (tester) async {
      await tester.pumpWidget(buildHarness(
        followLabel: 'Subscribe',
        followingLabel: 'Subscribed',
        defaultFollowing: true,
      ));
      await tester.pumpAndSettle();
      expect(find.text('Subscribed'), findsOneWidget);
    });
  });
}
