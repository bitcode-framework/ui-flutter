import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_viewer_pdf.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness({required BcViewerPdf child}) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('renders requested page and reflects index (VAL-M6-001)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerPdf(
        src: 'https://example.com/doc.pdf',
        page: 2,
        pageCount: 5,
      ),
    ));

    expect(find.textContaining('2'), findsWidgets);
    expect(find.textContaining('5'), findsWidgets);
    expect(find.byKey(const Key('bc_viewer_pdf_page_label')), findsOneWidget);
  });

  testWidgets('controlled page advances when prop updates (VAL-M6-001)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerPdf(
        src: 'https://example.com/doc.pdf',
        page: 1,
        pageCount: 5,
      ),
    ));

    expect(find.textContaining('1'), findsWidgets);

    await tester.pumpWidget(harness(
      child: const BcViewerPdf(
        src: 'https://example.com/doc.pdf',
        page: 3,
        pageCount: 5,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('3'), findsWidgets);
  });

  testWidgets('page beyond last clamps to last page (VAL-M6-001)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerPdf(
        src: 'https://example.com/doc.pdf',
        page: 99,
        pageCount: 5,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('5'), findsWidgets);
  });

  testWidgets('page below 1 clamps to 1 (VAL-M6-001)', (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerPdf(
        src: 'https://example.com/doc.pdf',
        page: -3,
        pageCount: 5,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('1'), findsWidgets);
  });

  testWidgets('next/prev page navigation emits onPageChange with meta (VAL-M6-002)',
      (tester) async {
    int? emittedPage;
    BcChangeMeta? emittedMeta;

    await tester.pumpWidget(harness(
      child: BcViewerPdf(
        src: 'https://example.com/doc.pdf',
        page: 2,
        pageCount: 5,
        onPageChange: (p, m) {
          emittedPage = p;
          emittedMeta = m;
        },
      ),
    ));

    await tester.tap(find.byKey(const Key('bc_viewer_pdf_next')));
    await tester.pumpAndSettle();

    expect(emittedPage, 3);
    expect(emittedMeta, isNotNull);
    expect(emittedMeta!.source, BcEventSource.pointer);

    await tester.tap(find.byKey(const Key('bc_viewer_pdf_prev')));
    await tester.pumpAndSettle();

    expect(emittedPage, 1);
  });

  testWidgets('zoom in/out emit onZoomChange with meta (VAL-M6-002)',
      (tester) async {
    double? emittedZoom;
    BcChangeMeta? emittedMeta;

    await tester.pumpWidget(harness(
      child: BcViewerPdf(
        src: 'https://example.com/doc.pdf',
        zoom: 1.0,
        pageCount: 5,
        onZoomChange: (z, m) {
          emittedZoom = z;
          emittedMeta = m;
        },
      ),
    ));

    await tester.tap(find.byKey(const Key('bc_viewer_pdf_zoom_in')));
    await tester.pumpAndSettle();

    expect(emittedZoom, 1.25);
    expect(emittedMeta, isNotNull);
    expect(emittedMeta!.source, BcEventSource.pointer);

    await tester.tap(find.byKey(const Key('bc_viewer_pdf_zoom_out')));
    await tester.pumpAndSettle();

    expect(emittedZoom, lessThanOrEqualTo(1.0));
  });

  testWidgets('zoom clamps to maxZoom (VAL-M6-002)', (tester) async {
    double? emittedZoom;

    await tester.pumpWidget(harness(
      child: BcViewerPdf(
        src: 'https://example.com/doc.pdf',
        zoom: 3.0,
        minZoom: 0.5,
        maxZoom: 3.0,
        pageCount: 5,
        onZoomChange: (z, m) {
          emittedZoom = z;
        },
      ),
    ));

    await tester.tap(find.byKey(const Key('bc_viewer_pdf_zoom_in')));
    await tester.pumpAndSettle();

    expect(emittedZoom, 3.0);
  });

  testWidgets('zoom clamps to minZoom (VAL-M6-002)', (tester) async {
    double? emittedZoom;

    await tester.pumpWidget(harness(
      child: BcViewerPdf(
        src: 'https://example.com/doc.pdf',
        zoom: 0.5,
        minZoom: 0.5,
        maxZoom: 3.0,
        pageCount: 5,
        onZoomChange: (z, m) {
          emittedZoom = z;
        },
      ),
    ));

    await tester.tap(find.byKey(const Key('bc_viewer_pdf_zoom_out')));
    await tester.pumpAndSettle();

    expect(emittedZoom, 0.5);
  });

  testWidgets('programmatic setZoom emits with programmatic source (VAL-M6-002)',
      (tester) async {
    double? emittedZoom;
    BcChangeMeta? emittedMeta;

    final key = GlobalKey<BcViewerPdfState>();

    await tester.pumpWidget(harness(
      child: BcViewerPdf(
        key: key,
        src: 'https://example.com/doc.pdf',
        zoom: 1.0,
        pageCount: 5,
        onZoomChange: (z, m) {
          emittedZoom = z;
          emittedMeta = m;
        },
      ),
    ));

    key.currentState!.setZoom(2.0);
    await tester.pumpAndSettle();

    expect(emittedZoom, 2.0);
    expect(emittedMeta!.source, BcEventSource.programmatic);
  });

  testWidgets('page nav is no-op at document bounds (VAL-M6-002)',
      (tester) async {
    int? emittedPage;

    await tester.pumpWidget(harness(
      child: BcViewerPdf(
        src: 'https://example.com/doc.pdf',
        page: 1,
        pageCount: 5,
        onPageChange: (p, m) {
          emittedPage = p;
        },
      ),
    ));

    await tester.tap(find.byKey(const Key('bc_viewer_pdf_prev')));
    await tester.pumpAndSettle();

    expect(emittedPage, isNull);
  });
}
