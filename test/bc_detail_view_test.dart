import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_detail_view.dart';

void main() {
  group('BcDetailView', () {
    Widget buildHarness({
      String? title,
      String? subtitle,
      List<BcDetailViewField>? fields,
      List<BcDetailViewAction>? actions,
      String emptyText = 'No data',
      bool loading = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BcDetailView(
            title: title,
            subtitle: subtitle,
            fields: fields,
            actions: actions,
            emptyText: emptyText,
            loading: loading,
          ),
        ),
      );
    }

    testWidgets('renders title + subtitle in header (VAL-A1-001)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        title: 'Contact',
        subtitle: 'John Doe',
        fields: [const BcDetailViewField(label: 'Email', value: 'john@test.com')],
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-detail-view')), findsOneWidget);
      expect(find.byKey(const Key('bc-detail-view-title')), findsOneWidget);
      expect(find.text('Contact'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('renders fields grid with label + value (VAL-A1-002)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        title: 'Record',
        fields: [
          const BcDetailViewField(label: 'Name', value: 'Alice'),
          const BcDetailViewField(label: 'Age', value: 30, type: 'currency'),
        ],
      ));
      await tester.pumpAndSettle();
      expect(find.text('NAME'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('AGE'), findsOneWidget);
    });

    testWidgets('empty state renders emptyText when no fields/tabs (VAL-A1-003)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        title: 'Empty',
        emptyText: 'Nothing here',
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-detail-view-empty')), findsOneWidget);
      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('loading state renders skeleton message (VAL-A1-004)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        title: 'Loading',
        loading: true,
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-detail-view-loading')), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('action buttons render and forward onClick (VAL-A1-005)',
        (tester) async {
      var pressed = false;
      await tester.pumpWidget(buildHarness(
        title: 'Actions',
        fields: [const BcDetailViewField(label: 'x', value: 'y')],
        actions: [
          BcDetailViewAction(
            label: 'Edit',
            variant: BcDetailViewActionVariant.primary,
            onClick: () => pressed = true,
          ),
        ],
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-detail-view-action-Edit')), findsOneWidget);
      await tester.tap(find.byKey(const Key('bc-detail-view-action-Edit')));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });

    testWidgets('boolean field formats as Yes/No (VAL-A1-006)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        fields: [
          const BcDetailViewField(label: 'Active', value: true, type: 'boolean'),
          const BcDetailViewField(label: 'Blocked', value: false, type: 'boolean'),
        ],
      ));
      await tester.pumpAndSettle();
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });
  });
}
