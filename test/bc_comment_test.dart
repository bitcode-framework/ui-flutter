import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_comment.dart';

void main() {
  group('BcComment', () {
    Widget buildHarness({
      required String author,
      required String body,
      String? avatar,
      String? timestamp,
      bool replyable = false,
      String replyPlaceholder = 'Write a reply...',
      bool disabled = false,
      BcChangeHandler<String>? onReply,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BcComment(
            author: author,
            body: body,
            avatar: avatar,
            timestamp: timestamp,
            replyable: replyable,
            replyPlaceholder: replyPlaceholder,
            disabled: disabled,
            onReply: onReply,
          ),
        ),
      );
    }

    testWidgets('renders author + body (VAL-B3-001)', (tester) async {
      await tester.pumpWidget(buildHarness(author: 'Jane', body: 'Hello world'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-comment-root')), findsOneWidget);
      expect(find.text('Jane'), findsOneWidget);
      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('timestamp renders when provided (VAL-B3-002)', (tester) async {
      await tester.pumpWidget(buildHarness(
        author: 'Jane',
        body: 'Hi',
        timestamp: '2 hours ago',
      ));
      await tester.pumpAndSettle();
      expect(find.text('2 hours ago'), findsOneWidget);
    });

    testWidgets('replyable=false hides reply controls (VAL-B3-003)', (tester) async {
      await tester.pumpWidget(buildHarness(author: 'Jane', body: 'Hi'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-comment-reply-toggle')), findsNothing);
      expect(find.byKey(const Key('bc-comment-reply-input')), findsNothing);
    });

    testWidgets('replyable=true shows Reply toggle; tap expands form (VAL-B3-004)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        author: 'Jane',
        body: 'Thoughts?',
        replyable: true,
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-comment-reply-toggle')), findsOneWidget);
      await tester.tap(find.byKey(const Key('bc-comment-reply-toggle')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-comment-reply-input')), findsOneWidget);
      expect(find.byKey(const Key('bc-comment-reply-submit')), findsOneWidget);
    });

    testWidgets('submit emits onReply with trimmed text + clears + collapses (VAL-B3-005)',
        (tester) async {
      String? captured;
      await tester.pumpWidget(buildHarness(
        author: 'Jane',
        body: 'Thoughts?',
        replyable: true,
        onReply: (v, _) => captured = v,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-comment-reply-toggle')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('bc-comment-reply-input')),
        '  My reply  ',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-comment-reply-submit')));
      await tester.pumpAndSettle();
      expect(captured, 'My reply');
      // Form collapsed after submit.
      expect(find.byKey(const Key('bc-comment-reply-input')), findsNothing);
    });

    testWidgets('submit guards empty draft (VAL-B3-006)', (tester) async {
      String? captured;
      await tester.pumpWidget(buildHarness(
        author: 'Jane',
        body: 'Thoughts?',
        replyable: true,
        onReply: (v, _) => captured = v,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-comment-reply-toggle')));
      await tester.pumpAndSettle();
      // Submit button should be disabled when draft is empty.
      final btn = tester.widget<ElevatedButton>(
        find.byKey(const Key('bc-comment-reply-submit')),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('disabled blocks reply expansion (VAL-B3-007)', (tester) async {
      await tester.pumpWidget(buildHarness(
        author: 'Jane',
        body: 'Locked',
        replyable: true,
        disabled: true,
      ));
      await tester.pumpAndSettle();
      final toggle = tester.widget<TextButton>(
        find.byKey(const Key('bc-comment-reply-toggle')),
      );
      expect(toggle.onPressed, isNull);
    });

    testWidgets('avatar URL renders image (VAL-B3-008)', (tester) async {
      await tester.pumpWidget(buildHarness(
        author: 'Jane',
        body: 'Hi',
        avatar: 'https://i.pravatar.cc/64?img=1',
      ));
      await tester.pumpAndSettle();
      // Image.network attempts to load; widget tree contains an Image.
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('avatar initials fallback when no URL (VAL-B3-009)', (tester) async {
      await tester.pumpWidget(buildHarness(
        author: 'Jane Doe',
        body: 'Hi',
        avatar: 'JD',
      ));
      await tester.pumpAndSettle();
      expect(find.text('JD'), findsWidgets);
    });
  });
}
