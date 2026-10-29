import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_list.dart';

void main() {
  testWidgets('BcList renders items', (tester) async {
    final items = ['Apple', 'Banana', 'Cherry'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BcList<String>(
            items: items,
            itemBuilder: (context, item, index) => Text(item),
          ),
        ),
      ),
    );

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('Cherry'), findsOneWidget);
  });

  testWidgets('BcList shows empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BcList<String>(
            items: const [],
            itemBuilder: (context, item, index) => Text(item),
            emptyState: const Center(child: Text('Empty list')),
          ),
        ),
      ),
    );

    expect(find.text('Empty list'), findsOneWidget);
  });

  testWidgets('BcList calls onTap', (tester) async {
    String? tapped;
    final items = ['Item 1', 'Item 2'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BcList<String>(
            items: items,
            itemBuilder: (context, item, index) => Text(item),
            onTap: (item) => tapped = item,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Item 1'));
    await tester.pump();
    expect(tapped, 'Item 1');
  });
}
