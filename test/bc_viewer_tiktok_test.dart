import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_viewer_tiktok.dart';

void main() {
  Widget harness({required BcViewerTiktok child}) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('valid video URL renders embed content (VAL-M6-015)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerTiktok(
        videoId: 'https://www.tiktok.com/@user/video/1234567890',
      ),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_viewer_tiktok_embed')), findsOneWidget);
  });

  testWidgets('numeric videoId renders embed content (VAL-M6-015)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerTiktok(
        videoId: '1234567890',
      ),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_viewer_tiktok_embed')), findsOneWidget);
  });

  testWidgets('empty videoId renders errorFallback without throwing (VAL-M6-016)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerTiktok(
        videoId: '',
      ),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_viewer_tiktok_error')), findsOneWidget);
  });

  testWidgets('null videoId renders errorFallback without throwing (VAL-M6-016)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerTiktok(
        videoId: null,
      ),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_viewer_tiktok_error')), findsOneWidget);
  });

  testWidgets('custom errorFallback renders on invalid videoId (VAL-M6-016)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerTiktok(
        videoId: '',
        errorFallback: Text('Cannot embed this video'),
      ),
    ));
    await tester.pump();

    expect(find.text('Cannot embed this video'), findsOneWidget);
  });

  testWidgets('title renders for accessibility (VAL-M6-015)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerTiktok(
        videoId: '1234567890',
        title: 'My TikTok Video',
      ),
    ));
    await tester.pump();

    expect(find.text('My TikTok Video'), findsOneWidget);
  });
}
