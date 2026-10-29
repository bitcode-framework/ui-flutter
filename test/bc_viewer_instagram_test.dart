import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_viewer_instagram.dart';

void main() {
  Widget harness({required BcViewerInstagram child}) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('valid post URL renders embed content (VAL-M6-013)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerInstagram(
        url: 'https://www.instagram.com/p/ABC123/',
      ),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_viewer_instagram_embed')), findsOneWidget);
  });

  testWidgets('valid reel URL renders embed content (VAL-M6-013)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerInstagram(
        url: 'https://www.instagram.com/reel/ABC123/',
      ),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_viewer_instagram_embed')), findsOneWidget);
  });

  testWidgets('empty url renders errorFallback without throwing (VAL-M6-014)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerInstagram(
        url: '',
      ),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_viewer_instagram_error')), findsOneWidget);
  });

  testWidgets('null url renders errorFallback without throwing (VAL-M6-014)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerInstagram(
        url: null,
      ),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_viewer_instagram_error')), findsOneWidget);
  });

  testWidgets('invalid url renders errorFallback without throwing (VAL-M6-014)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerInstagram(
        url: 'not-a-url',
      ),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_viewer_instagram_error')), findsOneWidget);
  });

  testWidgets('custom errorFallback renders on invalid url (VAL-M6-014)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerInstagram(
        url: '',
        errorFallback: Text('Cannot embed this post'),
      ),
    ));
    await tester.pump();

    expect(find.text('Cannot embed this post'), findsOneWidget);
  });

  testWidgets('title renders for accessibility (VAL-M6-013)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerInstagram(
        url: 'https://www.instagram.com/p/ABC123/',
        title: 'My Instagram Post',
      ),
    ));
    await tester.pump();

    expect(find.text('My Instagram Post'), findsOneWidget);
  });
}
