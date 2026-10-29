import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_search.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) =>
      MaterialApp(home: Scaffold(body: child));

  group('VAL-M7-014 — BcSearch renders input with search icon and emits query', () {
    testWidgets('renders input with search icon', (tester) async {
      await tester.pumpWidget(harness(
        const BcSearch(placeholder: 'Search...'),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_search')), findsOneWidget);
      expect(find.byKey(const Key('bc_search_input')), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Search...'), findsOneWidget);
    });

    testWidgets('typing text invokes onSearch with query and meta', (tester) async {
      String? capturedQuery;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcSearch(
          onSearch: (query, meta) {
            capturedQuery = query;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('bc_search_input')), 'hello');
      await tester.pumpAndSettle();

      expect(capturedQuery, 'hello');
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, BcChangeReason.input);
      expect(capturedMeta!.source, BcEventSource.keyboard);
    });

    testWidgets('submitting query emits with submit reason', (tester) async {
      String? capturedQuery;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcSearch(
          onSearch: (query, meta) {
            capturedQuery = query;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('bc_search_input')), 'test');
      await tester.pumpAndSettle();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(capturedQuery, 'test');
      expect(capturedMeta!.reason, BcChangeReason.submit);
    });

    testWidgets('renders results dropdown when results provided', (tester) async {
      await tester.pumpWidget(harness(
        const BcSearch(
          results: [
            BcSearchResult(id: '1', label: 'Apple'),
            BcSearchResult(id: '2', label: 'Banana'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      // enter text to trigger results visibility
      await tester.enterText(find.byKey(const Key('bc_search_input')), 'a');
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_search_results')), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
    });

    testWidgets('renders loading spinner when loading is true', (tester) async {
      await tester.pumpWidget(harness(
        const BcSearch(value: 'query', loading: true),
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('VAL-M7-015 — BcSearch clear button resets input and emits empty', () {
    testWidgets('clear button visible when query is non-empty', (tester) async {
      await tester.pumpWidget(harness(
        const BcSearch(value: 'some query'),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_search_clear')), findsOneWidget);
    });

    testWidgets('clear button not visible when query is empty', (tester) async {
      await tester.pumpWidget(harness(
        const BcSearch(),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_search_clear')), findsNothing);
    });

    testWidgets('tapping clear resets input and emits empty string', (tester) async {
      String? capturedQuery;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcSearch(
          onSearch: (query, meta) {
            capturedQuery = query;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Enter text first
      await tester.enterText(find.byKey(const Key('bc_search_input')), 'something');
      await tester.pumpAndSettle();

      // Clear button should now be visible
      await tester.tap(find.byKey(const Key('bc_search_clear')));
      await tester.pumpAndSettle();

      expect(capturedQuery, '');
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, BcChangeReason.clear);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });
  });
}
