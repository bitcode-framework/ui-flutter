import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_viewer_image.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness({required BcViewerImage child}) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('renders custom errorFallback on load failure (VAL-M6-003)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerImage(
        src: 'https://example.com/broken.png',
        placeholder: Text('Loading...'),
        errorFallback: Text('Failed'),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Failed'), findsOneWidget);
  });

  testWidgets('renders default errorFallback when none provided (VAL-M6-003)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerImage(
        src: 'https://nonexistent.invalid/img.png',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc_viewer_image_error')), findsOneWidget);
  });

  testWidgets('renders default placeholder widget (VAL-M6-003)',
      (tester) async {
    imageCache.clear();
    imageCache.clearLiveImages();
    await tester.pumpWidget(harness(
      child: const BcViewerImage(
        src: 'https://example.com/image.png',
      ),
    ));

    // After first frame, placeholder should be visible (before image resolves)
    expect(find.byKey(const Key('bc_viewer_image_placeholder')), findsOneWidget);
  });

  testWidgets('renders custom placeholder widget when provided (VAL-M6-003)',
      (tester) async {
    imageCache.clear();
    imageCache.clearLiveImages();
    await tester.pumpWidget(harness(
      child: const BcViewerImage(
        src: 'https://example.com/image.png',
        placeholder: Text('My Loading'),
      ),
    ));

    // Custom placeholder rendered during initial loading frame
    expect(find.text('My Loading'), findsOneWidget);
  });

  testWidgets('empty src renders error fallback (VAL-M6-003)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerImage(
        src: '',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc_viewer_image_error')), findsOneWidget);
  });

  testWidgets('null src renders error fallback (VAL-M6-003)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerImage(
        src: null,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc_viewer_image_error')), findsOneWidget);
  });

  testWidgets('zoom button emits onZoomChange with meta (VAL-M6-004)',
      (tester) async {
    double? emittedZoom;
    BcChangeMeta? emittedMeta;

    await tester.pumpWidget(harness(
      child: BcViewerImage(
        src: 'https://example.com/image.png',
        zoomable: true,
        onZoomChange: (z, m) {
          emittedZoom = z;
          emittedMeta = m;
        },
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('bc_viewer_image_zoom_in')));
    await tester.pumpAndSettle();

    expect(emittedZoom, isNotNull);
    expect(emittedMeta, isNotNull);
    expect(emittedMeta!.source, BcEventSource.pointer);
  });

  testWidgets('fullscreen toggle emits onFullscreenChange with meta (VAL-M6-004)',
      (tester) async {
    bool? emittedFullscreen;
    BcChangeMeta? emittedMeta;

    await tester.pumpWidget(harness(
      child: BcViewerImage(
        src: 'https://example.com/image.png',
        onFullscreenChange: (fs, m) {
          emittedFullscreen = fs;
          emittedMeta = m;
        },
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('bc_viewer_image_fullscreen')));
    await tester.pumpAndSettle();

    expect(emittedFullscreen, true);
    expect(emittedMeta, isNotNull);
    expect(emittedMeta!.source, BcEventSource.pointer);
  });

  testWidgets('disabled ignores zoom and fullscreen (VAL-M6-004)',
      (tester) async {
    double? emittedZoom;
    bool? emittedFullscreen;

    await tester.pumpWidget(harness(
      child: BcViewerImage(
        src: 'https://example.com/image.png',
        zoomable: true,
        disabled: true,
        onZoomChange: (z, m) {
          emittedZoom = z;
        },
        onFullscreenChange: (fs, m) {
          emittedFullscreen = fs;
        },
      ),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_viewer_image_zoom_in')), findsNothing);
    expect(find.byKey(const Key('bc_viewer_image_zoom_out')), findsNothing);

    final fsButton = tester.widget<IconButton>(
      find.byKey(const Key('bc_viewer_image_fullscreen')),
    );
    expect(fsButton.onPressed, isNull);

    await tester.tap(find.byKey(const Key('bc_viewer_image_fullscreen')),
        warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(emittedZoom, isNull);
    expect(emittedFullscreen, isNull);
  });

  testWidgets('programmatic setZoom clamps to min/max (VAL-M6-004)',
      (tester) async {
    double? emittedZoom;

    final key = GlobalKey<BcViewerImageState>();

    await tester.pumpWidget(harness(
      child: BcViewerImage(
        key: key,
        src: 'https://example.com/image.png',
        zoomable: true,
        minZoom: 0.5,
        maxZoom: 3.0,
        onZoomChange: (z, m) {
          emittedZoom = z;
        },
      ),
    ));
    await tester.pump();

    key.currentState!.setZoom(10.0);
    await tester.pumpAndSettle();
    expect(emittedZoom, 3.0);

    key.currentState!.setZoom(0.1);
    await tester.pumpAndSettle();
    expect(emittedZoom, 0.5);
  });

  testWidgets('pan emits onPanChange with meta (VAL-M6-004)',
      (tester) async {
    Offset? emittedPan;
    BcChangeMeta? emittedMeta;

    await tester.pumpWidget(harness(
      child: BcViewerImage(
        src: 'https://example.com/image.png',
        zoomable: true,
        zoom: 2.0,
        onPanChange: (o, m) {
          emittedPan = o;
          emittedMeta = m;
        },
      ),
    ));
    await tester.pump();

    await tester.drag(
      find.byKey(const Key('bc_viewer_image_content')),
      const Offset(20, 10),
    );
    await tester.pumpAndSettle();

    expect(emittedPan, isNotNull);
    expect(emittedMeta, isNotNull);
    expect(emittedMeta!.source, BcEventSource.pointer);
  });
}
