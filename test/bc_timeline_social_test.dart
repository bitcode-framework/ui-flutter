import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_timeline_social.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness({required BcTimelineSocial child}) {
    return MaterialApp(home: Scaffold(body: Center(child: child)));
  }

  final posts = <BcSocialPost>[
    const BcSocialPost(
      id: 'p1',
      author: 'Alice',
      handle: '@alice',
      content: 'Hello world!',
      timestamp: '2026-01-01',
      likes: 5,
      comments: 2,
      shares: 1,
      commentList: [
        BcSocialComment(
            id: 'c1',
            author: 'Bob',
            content: 'Nice post!',
            timestamp: '2026-01-02'),
      ],
    ),
    const BcSocialPost(
      id: 'p2',
      author: 'Carol',
      content: 'Second post',
      timestamp: '2026-01-03',
      likes: 3,
      comments: 0,
      shares: 0,
    ),
  ];

  testWidgets(
      'renders N posts with author, content and action buttons (VAL-M6-021)',
      (tester) async {
    await tester.pumpWidget(harness(child: BcTimelineSocial(posts: posts)));
    await tester.pump();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Carol'), findsOneWidget);
    expect(find.text('Hello world!'), findsOneWidget);
    expect(find.text('Second post'), findsOneWidget);

    expect(find.byIcon(Icons.favorite_border), findsNWidgets(2));
    expect(find.byIcon(Icons.mode_comment_outlined), findsNWidgets(2));
    expect(find.byIcon(Icons.share_outlined), findsNWidgets(2));
  });

  testWidgets(
      'renders posts in provided order (VAL-M6-021)',
      (tester) async {
    await tester.pumpWidget(harness(child: BcTimelineSocial(posts: posts)));
    await tester.pump();

    final aliceY = tester.getTopLeft(find.text('Alice')).dy;
    final carolY = tester.getTopLeft(find.text('Carol')).dy;
    expect(aliceY, lessThan(carolY));
  });

  testWidgets(
      'empty posts renders emptyState, not blank (VAL-M6-021)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcTimelineSocial(posts: [], emptyText: 'Nothing to show'),
    ));
    await tester.pump();

    expect(find.text('Nothing to show'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('bc_social_empty')), findsOneWidget);
  });

  testWidgets(
      'custom emptyState widget renders when posts empty (VAL-M6-021)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcTimelineSocial(posts: [], emptyState: Text('Custom')),
    ));
    await tester.pump();

    expect(find.text('Custom'), findsOneWidget);
  });

  testWidgets(
      'like action tap emits onPostAction with like and meta (VAL-M6-022)',
      (tester) async {
    String? capturedAction;
    String? capturedPostId;
    BcChangeMeta? capturedMeta;

    await tester.pumpWidget(harness(
      child: BcTimelineSocial(
        posts: posts,
        onPostAction: (payload, meta) {
          capturedAction = payload.action;
          capturedPostId = payload.postId;
          capturedMeta = meta;
        },
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('bc_social_action_p1_like')));
    await tester.pumpAndSettle();

    expect(capturedAction, 'like');
    expect(capturedPostId, 'p1');
    expect(capturedMeta, isNotNull);
    expect(capturedMeta!.source, BcEventSource.pointer);
  });

  testWidgets(
      'comment action tap expands comment input and comments (VAL-M6-022)',
      (tester) async {
    await tester.pumpWidget(harness(child: BcTimelineSocial(posts: posts)));
    await tester.pump();

    expect(find.byKey(const Key('bc_social_comment_input_p1')), findsNothing);

    await tester.tap(find.byKey(const Key('bc_social_action_p1_comment')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc_social_comment_input_p1')), findsOneWidget);
    expect(find.text('Nice post!'), findsOneWidget);
  });

  testWidgets(
      'comment submit emits onCommentSubmit with text and meta (VAL-M6-022)',
      (tester) async {
    String? capturedPostId;
    String? capturedText;
    BcChangeMeta? capturedMeta;

    await tester.pumpWidget(harness(
      child: BcTimelineSocial(
        posts: posts,
        onCommentSubmit: (payload, meta) {
          capturedPostId = payload.postId;
          capturedText = payload.text;
          capturedMeta = meta;
        },
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('bc_social_action_p1_comment')));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('bc_social_comment_field_p1')), 'Great!');
    await tester.tap(find.byKey(const Key('bc_social_comment_send_p1')));
    await tester.pumpAndSettle();

    expect(capturedPostId, 'p1');
    expect(capturedText, 'Great!');
    expect(capturedMeta, isNotNull);
    expect(capturedMeta!.source, BcEventSource.pointer);
  });

  testWidgets(
      'share action tap emits onPostAction with share and meta (VAL-M6-022)',
      (tester) async {
    String? capturedAction;

    await tester.pumpWidget(harness(
      child: BcTimelineSocial(
        posts: posts,
        onPostAction: (payload, _) => capturedAction = payload.action,
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('bc_social_action_p1_share')));
    await tester.pumpAndSettle();

    expect(capturedAction, 'share');
  });

  testWidgets(
      'disabled blocks all post actions and comment submit (VAL-M6-022)',
      (tester) async {
    int actionCount = 0;
    int commentCount = 0;

    await tester.pumpWidget(harness(
      child: BcTimelineSocial(
        posts: posts,
        disabled: true,
        onPostAction: (_, __) => actionCount++,
        onCommentSubmit: (_, __) => commentCount++,
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('bc_social_action_p1_like')));
    await tester.pumpAndSettle();

    expect(actionCount, 0);
    expect(commentCount, 0);
  });

  testWidgets(
      'avatar initials render when no avatar URL (VAL-M6-021)',
      (tester) async {
    await tester.pumpWidget(harness(child: BcTimelineSocial(posts: posts)));
    await tester.pump();

    expect(find.text('A'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets(
      'like count and comment count display in action footer (VAL-M6-021)',
      (tester) async {
    await tester.pumpWidget(harness(child: BcTimelineSocial(posts: posts)));
    await tester.pump();

    expect(find.text('Like (5)'), findsOneWidget);
    expect(find.text('Comment (2)'), findsOneWidget);
    expect(find.text('Share (1)'), findsOneWidget);
  });
}
