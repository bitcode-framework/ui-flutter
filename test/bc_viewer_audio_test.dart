import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_viewer_audio.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness({required BcViewerAudio child}) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('play/pause toggles and waveform renders for valid src (VAL-M6-009)',
      (tester) async {
    bool? emittedPlaying;
    BcChangeMeta? emittedMeta;

    await tester.pumpWidget(harness(
      child: BcViewerAudio(
        src: 'https://example.com/audio.mp3',
        onPlayingChange: (playing, m) {
          emittedPlaying = playing;
          emittedMeta = m;
        },
      ),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_viewer_audio_waveform')), findsOneWidget);

    await tester.tap(find.byKey(const Key('bc_viewer_audio_play')));
    await tester.pumpAndSettle();

    expect(emittedPlaying, true);
    expect(emittedMeta, isNotNull);
    expect(emittedMeta!.source, BcEventSource.pointer);
    expect(find.byIcon(Icons.pause), findsOneWidget);

    await tester.tap(find.byKey(const Key('bc_viewer_audio_play')));
    await tester.pumpAndSettle();

    expect(emittedPlaying, false);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('null or empty src renders error state (VAL-M6-009)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerAudio(
        src: '',
      ),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_viewer_audio_error')), findsOneWidget);
  });

  testWidgets('title renders when provided (VAL-M6-009)', (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerAudio(
        src: 'https://example.com/audio.mp3',
        title: 'My Podcast',
      ),
    ));
    await tester.pump();

    expect(find.text('My Podcast'), findsOneWidget);
  });

  testWidgets('seek emits onSeekChange with position and meta (VAL-M6-010)',
      (tester) async {
    double? emittedPosition;
    BcChangeMeta? emittedMeta;

    await tester.pumpWidget(harness(
      child: BcViewerAudio(
        src: 'https://example.com/audio.mp3',
        duration: const Duration(seconds: 60),
        onSeekChange: (pos, m) {
          emittedPosition = pos;
          emittedMeta = m;
        },
      ),
    ));
    await tester.pump();

    await tester.timedDrag(
      find.byKey(const Key('bc_viewer_audio_seek')),
      const Offset(50, 0),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();

    expect(emittedPosition, isNotNull);
    expect(emittedPosition! >= 0, isTrue);
    expect(emittedMeta, isNotNull);
    expect(emittedMeta!.source, BcEventSource.pointer);
  });

  testWidgets('seek clamps to duration (VAL-M6-010)', (tester) async {
    double? emittedPosition;

    final key = GlobalKey<BcViewerAudioState>();

    await tester.pumpWidget(harness(
      child: BcViewerAudio(
        key: key,
        src: 'https://example.com/audio.mp3',
        duration: const Duration(seconds: 60),
        onSeekChange: (pos, m) {
          emittedPosition = pos;
        },
      ),
    ));
    await tester.pump();

    key.currentState!.seekTo(999999.0);
    await tester.pumpAndSettle();

    expect(emittedPosition, 60000.0);
  });

  testWidgets('disabled ignores play/pause (VAL-M6-009)', (tester) async {
    bool? emittedPlaying;

    await tester.pumpWidget(harness(
      child: BcViewerAudio(
        src: 'https://example.com/audio.mp3',
        disabled: true,
        onPlayingChange: (playing, m) {
          emittedPlaying = playing;
        },
      ),
    ));
    await tester.pump();

    final btn = tester.widget<IconButton>(
      find.byKey(const Key('bc_viewer_audio_play')),
    );
    expect(btn.onPressed, isNull);

    await tester.tap(find.byKey(const Key('bc_viewer_audio_play')),
        warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(emittedPlaying, isNull);
  });
}
