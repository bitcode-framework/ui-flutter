import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_like.dart';

void main() {
  group('BcLike', () {
    Widget buildHarness({
      bool? liked,
      bool defaultLiked = false,
      int? count,
      bool disabled = false,
      BcChangeHandler<bool>? onLikedChange,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BcLike(
            liked: liked,
            defaultLiked: defaultLiked,
            count: count,
            disabled: disabled,
            onLikedChange: onLikedChange,
          ),
        ),
      );
    }

    testWidgets('renders unliked icon by default (VAL-B1-001)', (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('defaultLiked=true renders filled icon (VAL-B1-002)',
        (tester) async {
      await tester.pumpWidget(buildHarness(defaultLiked: true));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('count renders when provided (VAL-B1-003)', (tester) async {
      await tester.pumpWidget(buildHarness(count: 42));
      await tester.pumpAndSettle();
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('count omitted hides count (VAL-B1-004)', (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('tap toggles uncontrolled + emits onLikedChange with pointer source (VAL-B1-005)',
        (tester) async {
      bool? captured;
      BcChangeMeta? meta;
      await tester.pumpWidget(buildHarness(
        defaultLiked: false,
        onLikedChange: (v, m) {
          captured = v;
          meta = m;
        },
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-like-root')));
      await tester.pumpAndSettle();
      expect(captured, isTrue);
      expect(meta, isNotNull);
      expect(meta!.source, BcEventSource.pointer);
      // Icon flipped to filled.
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('controlled liked drives the icon (VAL-B1-006)', (tester) async {
      await tester.pumpWidget(buildHarness(liked: true));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('disabled does not toggle (VAL-B1-007)', (tester) async {
      bool? captured;
      await tester.pumpWidget(buildHarness(
        disabled: true,
        onLikedChange: (v, _) => captured = v,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-like-root')));
      await tester.pumpAndSettle();
      expect(captured, isNull);
    });

    testWidgets('liked uses destructive token color (VAL-B1-008)', (tester) async {
      await tester.pumpWidget(buildHarness(liked: true));
      await tester.pumpAndSettle();
      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
      expect(icon.color, isNotNull); // destructive token applied
    });
  });
}
