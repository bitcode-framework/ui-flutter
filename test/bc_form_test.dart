import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_form.dart';
import 'package:bc_ui_flutter/src/core/reactive_store.dart';

void main() {
  testWidgets('BcForm creates store and provides it', (tester) async {
    ReactiveStore? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BcForm(
            initialValues: const {'name': 'Alice'},
            onCreateStore: (store) => captured = store,
            child: Builder(
              builder: (context) {
                final store = BcForm.storeOf(context);
                return Text(store?.get('name') ?? 'none');
              },
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(captured, isNotNull);
    expect(captured!.get('name'), 'Alice');
    expect(find.text('Alice'), findsOneWidget);
  });

  testWidgets('BcForm runs reactions on init', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BcForm(
            initialValues: const {'qty': 3, 'price': 10},
            reactions: [
              Reaction(
                when: ['qty', 'price'],
                target: 'total',
                effect: ValueEffect(
                  expr: (scope) => (scope['qty'] as int) * (scope['price'] as int),
                ),
              ),
            ],
            child: Builder(
              builder: (context) {
                final store = BcForm.storeOf(context);
                return Text('Total: ${store?.get('total')}');
              },
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Total: 30'), findsOneWidget);
  });
}
