import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bc_ui_flutter/src/components/bc_map.dart';
import 'package:bc_ui_flutter/src/components/bc_viewer_audio.dart';
import 'package:bc_ui_flutter/src/components/bc_viewer_document.dart';
import 'package:bc_ui_flutter/src/components/bc_viewer_instagram.dart';
import 'package:bc_ui_flutter/src/components/bc_viewer_pdf.dart';
import 'package:bc_ui_flutter/src/components/bc_viewer_tiktok.dart';
import 'package:bc_ui_flutter/src/components/bc_viewer_video.dart';
import 'package:bc_ui_flutter/src/components/bc_viewer_youtube.dart';
import 'package:bc_ui_flutter/src/components/bc_web_embed.dart';

/// Regression tests for the media embed contract.
///
/// Every media viewer in the web adapter (`BcViewerYoutube`,
/// `BcViewerInstagram`, `BcViewerTiktok`, `BcViewerPdf`, `BcViewerDocument`,
/// `BcViewerVideo`, `BcViewerAudio`, `BcViewMap`) renders a real browser
/// element — `<iframe>` or `<video>`/`<audio>` — so the media actually loads.
///
/// The Flutter port originally rendered a static icon placeholder and computed
/// `embedUrl` without ever using it, so every embed was blank in the demo even
/// though the URL was correct. `BcChart` had already solved this with
/// `HtmlElementView`; these tests pin the same seam for the media viewers.
///
/// `bcWebEmbedSupported` is `false` off-web, so the tests below assert the
/// branch that actually runs under `flutter test` (the native fallback) plus
/// the URL construction that feeds the web branch.

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(
        body: SizedBox(height: 400, width: 400, child: child),
      ),
    );

void main() {
  group('web embed capability flag', () {
    test('is false off-web so dart:ui_web is never compiled', () {
      // Under `flutter test` the conditional import resolves to the stub.
      expect(bcWebEmbedSupported, isFalse);
    });

    test('stub widget builds without touching dart:ui_web', () {
      const stub = BcWebEmbed(
        url: 'https://example.com',
        keyPrefix: 'test',
        title: 'test',
        allow: 'encrypted-media',
        sandbox: 'allow-scripts',
      );
      expect(stub.url, 'https://example.com');
      expect(stub.keyPrefix, 'test');
      expect(stub.allow, 'encrypted-media');
      expect(stub.sandbox, 'allow-scripts');
    });
  });

  group('BcViewerYoutube', () {
    testWidgets('valid id renders the embed box, not the error fallback',
        (tester) async {
      await tester.pumpWidget(_host(
        const BcViewerYoutube(videoId: 'dQw4w9WgXcQ'),
      ));

      expect(find.byKey(const Key('bc_viewer_youtube_embed')), findsOneWidget);
      expect(find.byKey(const Key('bc_viewer_youtube_error')), findsNothing);
    });

    testWidgets('empty id renders the error fallback', (tester) async {
      await tester.pumpWidget(_host(
        const BcViewerYoutube(videoId: ''),
      ));

      expect(find.byKey(const Key('bc_viewer_youtube_error')), findsOneWidget);
      expect(find.byKey(const Key('bc_viewer_youtube_embed')), findsNothing);
    });

    testWidgets('embedUrl targets the nocookie domain with the extracted id',
        (tester) async {
      await tester.pumpWidget(_host(
        const BcViewerYoutube(videoId: 'dQw4w9WgXcQ'),
      ));

      final state = tester.state<BcViewerYoutubeState>(
        find.byType(BcViewerYoutube),
      );

      expect(state.embedUrl,
          'https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ');
    });

    testWidgets('embedUrl extracts the id from a full watch url', (tester) async {
      await tester.pumpWidget(_host(
        const BcViewerYoutube(
          videoId: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        ),
      ));

      final state = tester.state<BcViewerYoutubeState>(
        find.byType(BcViewerYoutube),
      );

      expect(state.embedUrl,
          'https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ');
    });
  });

  group('BcViewerInstagram', () {
    testWidgets('valid instagram url renders the embed box', (tester) async {
      await tester.pumpWidget(_host(
        const BcViewerInstagram(url: 'https://www.instagram.com/p/CqBqYQ8J8Zz/'),
      ));

      expect(
          find.byKey(const Key('bc_viewer_instagram_embed')), findsOneWidget);
      expect(find.byKey(const Key('bc_viewer_instagram_error')), findsNothing);
    });

    testWidgets('non-instagram url renders the error fallback', (tester) async {
      await tester.pumpWidget(_host(
        const BcViewerInstagram(url: 'https://example.com/post/1'),
      ));

      expect(find.byKey(const Key('bc_viewer_instagram_error')), findsOneWidget);
    });
  });

  group('BcViewerTiktok', () {
    testWidgets('numeric id renders the embed box', (tester) async {
      await tester.pumpWidget(_host(
        const BcViewerTiktok(videoId: '7106594319322901509'),
      ));

      expect(find.byKey(const Key('bc_viewer_tiktok_embed')), findsOneWidget);
      expect(find.byKey(const Key('bc_viewer_tiktok_error')), findsNothing);
    });

    testWidgets('empty id renders the error fallback', (tester) async {
      await tester.pumpWidget(_host(
        const BcViewerTiktok(videoId: ''),
      ));

      expect(find.byKey(const Key('bc_viewer_tiktok_error')), findsOneWidget);
    });
  });

  group('BcViewerPdf', () {
    testWidgets('renders a page surface for the current page', (tester) async {
      await tester.pumpWidget(_host(
        const BcViewerPdf(src: 'https://example.com/doc.pdf'),
      ));

      expect(
        find.byKey(const Key('bc_viewer_pdf_page_1_zoom_1.00')),
        findsOneWidget,
      );
    });

    testWidgets('keeps the page key stable across zoom changes',
        (tester) async {
      await tester.pumpWidget(_host(
        const BcViewerPdf(src: 'https://example.com/doc.pdf'),
      ));

      expect(
        find.byKey(const Key('bc_viewer_pdf_page_1_zoom_1.00')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('bc_viewer_pdf_zoom_in')));
      await tester.pump();

      expect(
        find.byKey(const Key('bc_viewer_pdf_page_1_zoom_1.25')),
        findsOneWidget,
      );
    });
  });

  group('BcViewerDocument', () {
    testWidgets('supported extension renders content, not the error',
        (tester) async {
      await tester.pumpWidget(_host(
        const BcViewerDocument(src: 'https://example.com/report.pdf'),
      ));
      await tester.pump();

      expect(
          find.byKey(const Key('bc_viewer_document_content')), findsOneWidget);
      expect(find.byKey(const Key('bc_viewer_document_error')), findsNothing);
    });

    testWidgets('unsupported extension renders the error fallback',
        (tester) async {
      await tester.pumpWidget(_host(
        const BcViewerDocument(src: 'https://example.com/file.xyz'),
      ));
      await tester.pump();

      expect(find.byKey(const Key('bc_viewer_document_error')), findsOneWidget);
    });
  });

  group('BcViewerVideo', () {
    testWidgets('non-empty src does not render the error fallback',
        (tester) async {
      await tester.pumpWidget(_host(
        const BcViewerVideo(src: 'https://example.com/clip.mp4'),
      ));

      expect(find.text('Unable to load video'), findsNothing);
    });

    testWidgets('empty src renders the error fallback', (tester) async {
      await tester.pumpWidget(_host(
        const BcViewerVideo(src: ''),
      ));

      expect(find.text('Unable to load video'), findsOneWidget);
    });
  });

  group('BcViewerAudio', () {
    testWidgets('non-empty src does not render the error fallback',
        (tester) async {
      await tester.pumpWidget(_host(
        const BcViewerAudio(src: 'https://example.com/clip.mp3'),
      ));

      expect(find.text('Unable to load audio'), findsNothing);
    });

    testWidgets('empty src renders the error fallback', (tester) async {
      await tester.pumpWidget(_host(
        const BcViewerAudio(src: ''),
      ));

      expect(find.text('Unable to load audio'), findsOneWidget);
    });
  });

  group('BcMap', () {
    testWidgets('falls back to the metadata placeholder without mapBuilder',
        (tester) async {
      await tester.pumpWidget(_host(
        const BcMap(center: BcMapLatLng(lat: -6.2088, lng: 106.8456)),
      ));

      expect(find.byKey(const Key('bc-map-placeholder')), findsOneWidget);
    });

    test('resolvedEmbedUrl substitutes the default OpenStreetMap template', () {
      const map = BcMap(center: BcMapLatLng(lat: 1.5, lng: 2.5), zoom: 10);

      final url = map.resolvedEmbedUrl;

      expect(url, contains('openstreetmap.org/export/embed.html'));
      expect(url, contains('marker=1.5%2C2.5'));
      expect(url, isNot(contains('{lat}')));
      expect(url, isNot(contains('{lng}')));
      expect(url, isNot(contains('{zoom}')));
    });

    test('resolvedEmbedUrl honours a custom provider template', () {
      const map = BcMap(
        center: BcMapLatLng(lat: 10, lng: 20),
        zoom: 7,
        embedUrl: 'https://tiles.test/{lat}/{lng}?z={zoom}',
      );

      expect(map.resolvedEmbedUrl, 'https://tiles.test/10.0/20.0?z=7');
    });
  });
}
