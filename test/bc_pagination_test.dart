import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_pagination.dart';

void main() {
  group('BcPagination', () {
    testWidgets('renders current page and total pages (VAL-M3-005)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcPagination(
              currentPage: 3,
              totalPages: 10,
            ),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);

      final prevBtn = tester.widget<FilledButton>(
        find.byKey(const Key('bc-pagination-prev')),
      );
      expect(prevBtn.onPressed, isNotNull);

      final nextBtn = tester.widget<FilledButton>(
        find.byKey(const Key('bc-pagination-next')),
      );
      expect(nextBtn.onPressed, isNotNull);
    });

    testWidgets('next emits incremented page with meta (VAL-M3-006)',
        (tester) async {
      int? capturedPage;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcPagination(
              currentPage: 3,
              totalPages: 10,
              onPageChange: (page, meta) {
                capturedPage = page;
                capturedMeta = meta;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('bc-pagination-next')));
      await tester.pumpAndSettle();

      expect(capturedPage, 4);
      expect(capturedMeta, isNotNull);
    });

    testWidgets('prev disabled on first page (VAL-M3-007)',
        (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcPagination(
              currentPage: 1,
              totalPages: 10,
              onPageChange: (_, __) => callCount++,
            ),
          ),
        ),
      );

      final prevBtn = tester.widget<FilledButton>(
        find.byKey(const Key('bc-pagination-prev')),
      );
      expect(prevBtn.onPressed, isNull);

      final nextBtn = tester.widget<FilledButton>(
        find.byKey(const Key('bc-pagination-next')),
      );
      expect(nextBtn.onPressed, isNotNull);

      await tester.tap(find.byKey(const Key('bc-pagination-prev')),
          warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });

    testWidgets('direct page number tap emits that page (VAL-M3-008)',
        (tester) async {
      int? capturedPage;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcPagination(
              currentPage: 3,
              totalPages: 10,
              siblingCount: 2,
              onPageChange: (page, meta) {
                capturedPage = page;
                capturedMeta = meta;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('bc-pagination-page-5')));
      await tester.pumpAndSettle();

      expect(capturedPage, 5);
      expect(capturedMeta, isNotNull);
    });
  });
}
