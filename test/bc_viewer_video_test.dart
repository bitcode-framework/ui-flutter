import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_viewer_video.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness({required BcViewerVideo child}) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('play/pause toggles state and reflects in controls and semantics (VAL-M6-007)',
      (tester) async {
    bool? emittedPlaying;
    BcChangeMeta? emittedMeta;

    await tester.pumpWidget(harness(
      child: BcViewerVideo(
        src: 'https://example.com/video.mp4',
        onPlayingChange: (playing, m) {
          emittedPlaying = playing;
          emittedMeta = m;
        },
      ),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_viewer_video_play_overlay')), findsOneWidget);

    await tester.tap(find.byKey(const Key('bc_viewer_video_play')));
    await tester.pumpAndSettle();

    expect(emittedPlaying, true);
    expect(emittedMeta, isNotNull);
    expect(emittedMeta!.source, BcEventSource.pointer);
    expect(find.byIcon(Icons.pause), findsOneWidget);

    await tester.tap(find.byKey(const Key('bc_viewer_video_play')));
    await tester.pumpAndSettle();

    expect(emittedPlaying, false);
    expect(find.byKey(const Key('bc_viewer_video_play_overlay')), findsOneWidget);
  });

  testWidgets('disabled ignores play/pause (VAL-M6-007)', (tester) async {
    bool? emittedPlaying;

    await tester.pumpWidget(harness(
      child: BcViewerVideo(
        src: 'https://example.com/video.mp4',
        disabled: true,
        onPlayingChange: (playing, m) {
          emittedPlaying = playing;
        },
      ),
    ));
    await tester.pump();

    final btn = tester.widget<IconButton>(
      find.byKey(const Key('bc_viewer_video_play')),
    );
    expect(btn.onPressed, isNull);

    await tester.tap(find.byKey(const Key('bc_viewer_video_play')),
        warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(emittedPlaying, isNull);
  });

  testWidgets('seek emits onSeekChange with position and meta (VAL-M6-008)',
      (tester) async {
    double? emittedPosition;
    BcChangeMeta? emittedMeta;

    await tester.pumpWidget(harness(
      child: BcViewerVideo(
        src: 'https://example.com/video.mp4',
        duration: const Duration(seconds: 100),
        onSeekChange: (pos, m) {
          emittedPosition = pos;
          emittedMeta = m;
        },
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('bc_viewer_video_play')));
    await tester.pumpAndSettle();

    await tester.timedDrag(
      find.byKey(const Key('bc_viewer_video_seek')),
      const Offset(50, 0),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();

    expect(emittedPosition, isNotNull);
    expect(emittedPosition! >= 0, isTrue);
    expect(emittedMeta, isNotNull);
    expect(emittedMeta!.source, BcEventSource.pointer);
  });

  testWidgets('volume change emits onVolumeChange with meta (VAL-M6-008)',
      (tester) async {
    double? emittedVolume;
    BcChangeMeta? emittedMeta;

    await tester.pumpWidget(harness(
      child: BcViewerVideo(
        src: 'https://example.com/video.mp4',
        onVolumeChange: (vol, m) {
          emittedVolume = vol;
          emittedMeta = m;
        },
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('bc_viewer_video_mute')));
    await tester.pumpAndSettle();

    expect(emittedVolume, isNotNull);
    expect(emittedMeta, isNotNull);
    expect(emittedMeta!.source, BcEventSource.pointer);
  });

  testWidgets('fullscreen toggle emits onFullscreenChange with meta (VAL-M6-008)',
      (tester) async {
    bool? emittedFullscreen;
    BcChangeMeta? emittedMeta;

    await tester.pumpWidget(harness(
      child: BcViewerVideo(
        src: 'https://example.com/video.mp4',
        onFullscreenChange: (fs, m) {
          emittedFullscreen = fs;
          emittedMeta = m;
        },
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('bc_viewer_video_fullscreen')));
    await tester.pumpAndSettle();

    expect(emittedFullscreen, true);
    expect(emittedMeta, isNotNull);
    expect(emittedMeta!.source, BcEventSource.pointer);
  });

  testWidgets('poster renders when not playing (VAL-M6-007)', (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerVideo(
        src: 'https://example.com/video.mp4',
        poster: 'https://example.com/poster.jpg',
      ),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_viewer_video_poster')), findsOneWidget);
  });

  testWidgets('null or empty src renders error state (VAL-M6-007)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerVideo(
        src: '',
      ),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_viewer_video_error')), findsOneWidget);
  });
}
