import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_viewer_document.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness({required BcViewerDocument child}) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('renders loading indicator then content for supported format (VAL-M6-005)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerDocument(
        src: 'https://example.com/doc.docx',
        engine: BcViewerDocumentEngine.office,
      ),
    ));

    expect(find.byKey(const Key('bc_viewer_document_loading')), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc_viewer_document_content')), findsOneWidget);
  });

  testWidgets('renders with google engine for supported format (VAL-M6-005)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerDocument(
        src: 'https://example.com/doc.pdf',
        engine: BcViewerDocumentEngine.google,
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc_viewer_document_content')), findsOneWidget);
  });

  testWidgets('renders with native engine for supported format (VAL-M6-005)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerDocument(
        src: 'https://example.com/doc.pdf',
        engine: BcViewerDocumentEngine.native,
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc_viewer_document_content')), findsOneWidget);
  });

  testWidgets('unsupported format renders error state without throwing (VAL-M6-006)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerDocument(
        src: 'https://example.com/doc.xyz',
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc_viewer_document_error')), findsOneWidget);
  });

  testWidgets('null or empty src renders error state (VAL-M6-006)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerDocument(
        src: '',
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc_viewer_document_error')), findsOneWidget);
  });

  testWidgets('page navigation emits onPageChange with meta (VAL-M6-006)',
      (tester) async {
    int? emittedPage;
    BcChangeMeta? emittedMeta;

    await tester.pumpWidget(harness(
      child: BcViewerDocument(
        src: 'https://example.com/doc.docx',
        pageCount: 5,
        onPageChange: (p, m) {
          emittedPage = p;
          emittedMeta = m;
        },
      ),
    ));

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bc_viewer_document_next')));
    await tester.pumpAndSettle();

    expect(emittedPage, 2);
    expect(emittedMeta, isNotNull);
    expect(emittedMeta!.source, BcEventSource.pointer);
  });

  testWidgets('page navigation prev emits with meta and clamps at first page (VAL-M6-006)',
      (tester) async {
    int? emittedPage;
    BcChangeMeta? emittedMeta;

    await tester.pumpWidget(harness(
      child: BcViewerDocument(
        src: 'https://example.com/doc.docx',
        page: 3,
        pageCount: 5,
        onPageChange: (p, m) {
          emittedPage = p;
          emittedMeta = m;
        },
      ),
    ));

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bc_viewer_document_prev')));
    await tester.pumpAndSettle();

    expect(emittedPage, 2);
    expect(emittedMeta, isNotNull);
  });

  testWidgets('page nav is no-op at first page (VAL-M6-006)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerDocument(
        src: 'https://example.com/doc.docx',
        pageCount: 5,
      ),
    ));

    await tester.pumpAndSettle();

    final prevBtn = tester.widget<IconButton>(
      find.byKey(const Key('bc_viewer_document_prev')),
    );
    expect(prevBtn.onPressed, isNull);
  });

  testWidgets('custom errorFallback renders on unsupported format (VAL-M6-006)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcViewerDocument(
        src: 'https://example.com/doc.xyz',
        errorFallback: Text('Format not supported'),
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Format not supported'), findsOneWidget);
  });
}
