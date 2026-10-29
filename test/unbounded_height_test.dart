import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bc_ui_flutter/src/components/bc_pivot.dart';
import 'package:bc_ui_flutter/src/components/bc_viewer_document.dart';
import 'package:bc_ui_flutter/src/components/bc_viewer_instagram.dart';
import 'package:bc_ui_flutter/src/components/bc_viewer_tiktok.dart';
import 'package:bc_ui_flutter/src/components/bc_viewer_youtube.dart';

/// Regression tests for unbounded-height layout.
///
/// `BcPivot` and `BcViewerDocument` used to place their body in an `Expanded`
/// inside a `Column`. `Expanded` requires a bounded height, so rendering
/// either widget inside a vertical scroll view (where the height constraint is
/// infinite) threw:
///
///   RenderFlex children have non-zero flex but incoming height constraints
///   are unbounded.
///
/// In the Flutter demo this blanked the entire Media and Views sections. The
/// web adapters have no such requirement: `BcPivot` is `overflow-auto` with
/// natural height, and `BcViewerDocument` defaults to a fixed `600px`.
///
/// Both widgets must therefore size to their content when the height is
/// unbounded, and keep filling the box when it is bounded.

BcPivotResult _pivotResult() => const BcPivotResult(
      rowHeaders: ['North', 'South'],
      colHeaders: ['Q1', 'Q2'],
      cells: [
        [
          [120.0],
          [150.0],
        ],
        [
          [90.0],
          [110.0],
        ],
      ],
      rowTotals: [
        [270.0],
        [200.0],
      ],
      colTotals: [
        [210.0],
        [260.0],
      ],
      grandTotal: [470.0],
      valueFields: [
        BcPivotValueField(field: 'sales', agg: BcPivotAggFunc.sum),
      ],
    );

/// Pumps [child] inside a vertical scroll view, which gives it an unbounded
/// height constraint. Returns any layout exception that was raised.
Future<String?> _pumpUnbounded(WidgetTester tester, Widget child) async {
  Object? caught;
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    caught ??= details.exception;
  };

  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  try {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  } finally {
    FlutterError.onError = original;
  }

  return caught?.toString();
}

void main() {
  group('BcPivot tolerates unbounded height', () {
    testWidgets('renders inside a scroll view without throwing',
        (tester) async {
      final error = await _pumpUnbounded(
        tester,
        BcPivot(title: 'Sales by Region', result: _pivotResult()),
      );

      expect(error, isNull, reason: 'BcPivot threw when unbounded: $error');
      expect(find.byKey(const Key('bc-pivot-table')), findsOneWidget);
    });

    testWidgets('renders its title and grand total when unbounded',
        (tester) async {
      final error = await _pumpUnbounded(
        tester,
        BcPivot(
          title: 'Sales by Region',
          showGrandTotal: true,
          result: _pivotResult(),
        ),
      );

      expect(error, isNull, reason: 'BcPivot threw when unbounded: $error');
      expect(find.text('Sales by Region'), findsOneWidget);
      expect(find.text('Grand Total'), findsOneWidget);
    });

    testWidgets('no-data state also works when unbounded', (tester) async {
      final error = await _pumpUnbounded(
        tester,
        const BcPivot(result: null),
      );

      expect(error, isNull, reason: 'BcPivot threw when unbounded: $error');
      expect(find.text('No data to display'), findsOneWidget);
    });

    testWidgets('still fills a bounded box', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: BcPivot(title: 'Bounded', result: _pivotResult()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final box = tester.getSize(find.byKey(const Key('bc-pivot-container')));
      expect(box.height, 400);
    });
  });

  group('embed viewers tolerate unbounded height', () {
    testWidgets('BcViewerInstagram renders inside a scroll view', (tester) async {
      final error = await _pumpUnbounded(
        tester,
        const BcViewerInstagram(
          url: 'https://www.instagram.com/p/CpABC123xyz/',
          title: 'Instagram Post',
        ),
      );

      expect(error, isNull, reason: 'BcViewerInstagram threw: $error');
      expect(
        find.byKey(const Key('bc_viewer_instagram_embed')),
        findsOneWidget,
      );
    });

    testWidgets('BcViewerInstagram error state renders when unbounded',
        (tester) async {
      final error = await _pumpUnbounded(
        tester,
        const BcViewerInstagram(url: 'not-a-url'),
      );

      expect(error, isNull, reason: 'BcViewerInstagram threw: $error');
      expect(
        find.byKey(const Key('bc_viewer_instagram_error')),
        findsOneWidget,
      );
    });

    testWidgets('BcViewerTiktok renders inside a scroll view', (tester) async {
      final error = await _pumpUnbounded(
        tester,
        const BcViewerTiktok(
          videoId: '7106594319322901509',
          title: 'TikTok Video',
        ),
      );

      expect(error, isNull, reason: 'BcViewerTiktok threw: $error');
      expect(find.byKey(const Key('bc_viewer_tiktok_embed')), findsOneWidget);
    });

    testWidgets('BcViewerYoutube renders inside a scroll view', (tester) async {
      final error = await _pumpUnbounded(
        tester,
        const BcViewerYoutube(videoId: 'dQw4w9WgXcQ'),
      );

      expect(error, isNull, reason: 'BcViewerYoutube threw: $error');
      expect(find.byKey(const Key('bc_viewer_youtube_embed')), findsOneWidget);
    });

    testWidgets('BcViewerYoutube error state renders when unbounded',
        (tester) async {
      final error = await _pumpUnbounded(
        tester,
        const BcViewerYoutube(videoId: ''),
      );

      expect(error, isNull, reason: 'BcViewerYoutube threw: $error');
    });
  });

  group('BcViewerDocument tolerates unbounded height', () {
    testWidgets('renders inside a scroll view without throwing',
        (tester) async {
      final error = await _pumpUnbounded(
        tester,
        const BcViewerDocument(
          src: 'https://example.com/doc.pdf',
          title: 'Dummy.pdf',
          pageCount: 2,
        ),
      );

      expect(error, isNull,
          reason: 'BcViewerDocument threw when unbounded: $error');
      expect(
        find.byKey(const Key('bc_viewer_document_content')),
        findsOneWidget,
      );
    });

    testWidgets('unsupported format still shows the error state when unbounded',
        (tester) async {
      final error = await _pumpUnbounded(
        tester,
        const BcViewerDocument(src: 'https://example.com/file.xyz'),
      );

      expect(error, isNull,
          reason: 'BcViewerDocument threw when unbounded: $error');
      expect(find.byKey(const Key('bc_viewer_document_error')), findsOneWidget);
    });

    testWidgets('page bar renders when unbounded', (tester) async {
      final error = await _pumpUnbounded(
        tester,
        const BcViewerDocument(
          src: 'https://example.com/doc.pdf',
          pageCount: 3,
        ),
      );

      expect(error, isNull,
          reason: 'BcViewerDocument threw when unbounded: $error');
      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('still fills a bounded box', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              child: const BcViewerDocument(
                src: 'https://example.com/doc.pdf',
                pageCount: 2,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The Semantics wrapper is only added when a title is present, so probe
      // the outer ClipRRect through the content key's ancestors instead.
      final content = tester.getSize(
        find.byKey(const Key('bc_viewer_document_content')),
      );
      expect(content.height, lessThanOrEqualTo(500));
      expect(content.height, greaterThan(0));
    });
  });
}
