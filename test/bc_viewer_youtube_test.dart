import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_viewer_youtube.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness({required BcViewerYoutube child}) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('valid videoId renders embed content (VAL-M6-011)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerYoutube(
        videoId: 'dQw4w9WgXcQ',
      ),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_viewer_youtube_embed')), findsOneWidget);
  });

  testWidgets('full YouTube URL extracts videoId and renders embed (VAL-M6-011)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerYoutube(
        videoId: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      ),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_viewer_youtube_embed')), findsOneWidget);
  });

  testWidgets('youtu.be URL extracts videoId and renders embed (VAL-M6-011)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerYoutube(
        videoId: 'https://youtu.be/dQw4w9WgXcQ',
      ),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_viewer_youtube_embed')), findsOneWidget);
  });

  testWidgets('empty or null videoId renders error state (VAL-M6-011)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerYoutube(
        videoId: '',
      ),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_viewer_youtube_error')), findsOneWidget);
  });

  testWidgets('play/pause control emits onPlayingChange with meta (VAL-M6-012)',
      (tester) async {
    bool? emittedPlaying;
    BcChangeMeta? emittedMeta;

    await tester.pumpWidget(harness(
      child: BcViewerYoutube(
        videoId: 'dQw4w9WgXcQ',
        onPlayingChange: (playing, m) {
          emittedPlaying = playing;
          emittedMeta = m;
        },
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('bc_viewer_youtube_play')));
    await tester.pumpAndSettle();

    expect(emittedPlaying, true);
    expect(emittedMeta, isNotNull);
    expect(emittedMeta!.source, BcEventSource.pointer);

    await tester.tap(find.byKey(const Key('bc_viewer_youtube_play')));
    await tester.pumpAndSettle();

    expect(emittedPlaying, false);
  });

  testWidgets('disabled ignores play/pause (VAL-M6-012)', (tester) async {
    bool? emittedPlaying;

    await tester.pumpWidget(harness(
      child: BcViewerYoutube(
        videoId: 'dQw4w9WgXcQ',
        disabled: true,
        onPlayingChange: (playing, m) {
          emittedPlaying = playing;
        },
      ),
    ));
    await tester.pump();

    final btn = tester.widget<IconButton>(
      find.byKey(const Key('bc_viewer_youtube_play')),
    );
    expect(btn.onPressed, isNull);

    await tester.tap(find.byKey(const Key('bc_viewer_youtube_play')),
        warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(emittedPlaying, isNull);
  });

  testWidgets('title renders for accessibility (VAL-M6-011)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerYoutube(
        videoId: 'dQw4w9WgXcQ',
        title: 'My YouTube Video',
      ),
    ));
    await tester.pump();

    expect(find.text('My YouTube Video'), findsOneWidget);
  });
}
