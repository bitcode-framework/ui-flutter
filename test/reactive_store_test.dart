import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/reactive_store.dart';

void main() {
  group('ReactiveStore — basic get/set', () {
    test('set and get a value', () {
      final store = ReactiveStore(const ReactiveStoreOptions(
        initialValues: {'name': 'Alice'},
      ));
      expect(store.get('name'), 'Alice');
      store.set('name', 'Bob');
      expect(store.get('name'), 'Bob');
      store.dispose();
    });

    test('setMany updates multiple values', () {
      final store = ReactiveStore();
      store.setMany({'a': 1, 'b': 2, 'c': 3});
      expect(store.get('a'), 1);
      expect(store.get('b'), 2);
      expect(store.get('c'), 3);
      store.dispose();
    });

    test('set with same value does not notify', () {
      final store = ReactiveStore(const ReactiveStoreOptions(
        initialValues: {'x': 10},
      ));
      var notified = 0;
      store.subscribe((_) => notified++);
      store.set('x', 10);
      expect(notified, 0);
      store.set('x', 20);
      expect(notified, 1);
      store.dispose();
    });
  });

  group('ReactiveStore — metadata', () {
    test('getMeta returns default FieldMeta', () {
      final store = ReactiveStore();
      final meta = store.getMeta('field');
      expect(meta.visible, isTrue);
      expect(meta.disabled, isFalse);
      expect(meta.required, isFalse);
      store.dispose();
    });

    test('UI effect updates visibility', () {
      final store = ReactiveStore(ReactiveStoreOptions(
        initialValues: {'show': true, 'target': 'hello'},
        reactions: [
          Reaction(
            when: 'show',
            target: 'target',
            effect: UiEffect(visible: (scope) => scope['show'] == true),
          ),
        ],
      ));
      store.runAll();
      expect(store.getMeta('target').visible, isTrue);
      store.set('show', false);
      expect(store.getMeta('target').visible, isFalse);
      store.dispose();
    });

    test('UI effect updates disabled', () {
      final store = ReactiveStore(ReactiveStoreOptions(
        initialValues: {'locked': true, 'field': ''},
        reactions: [
          Reaction(
            when: 'locked',
            target: 'field',
            effect: UiEffect(disabled: (scope) => scope['locked'] == true),
          ),
        ],
      ));
      store.runAll();
      expect(store.getMeta('field').disabled, isTrue);
      store.set('locked', false);
      expect(store.getMeta('field').disabled, isFalse);
      store.dispose();
    });
  });

  group('ReactiveStore — value effects (computed)', () {
    test('VALUE effect computes from function', () {
      final store = ReactiveStore(ReactiveStoreOptions(
        initialValues: {'qty': 3, 'price': 10},
        reactions: [
          Reaction(
            when: ['qty', 'price'],
            target: 'total',
            effect: ValueEffect(
              expr: (scope) => (scope['qty'] as int) * (scope['price'] as int),
            ),
          ),
        ],
      ));
      store.runAll();
      expect(store.get('total'), 30);
      store.set('qty', 5);
      expect(store.get('total'), 50);
      store.set('price', 20);
      expect(store.get('total'), 100);
      store.dispose();
    });

    test('VALUE effect cascades to dependent reactions', () {
      final store = ReactiveStore(ReactiveStoreOptions(
        initialValues: {'base': 10},
        reactions: [
          Reaction(
            when: 'base',
            target: 'doubled',
            effect: ValueEffect(expr: (scope) => (scope['base'] as int) * 2),
          ),
          Reaction(
            when: 'doubled',
            target: 'quadrupled',
            effect: ValueEffect(expr: (scope) => (scope['doubled'] as int) * 2),
          ),
        ],
      ));
      store.runAll();
      expect(store.get('doubled'), 20);
      expect(store.get('quadrupled'), 40);
      store.set('base', 5);
      expect(store.get('doubled'), 10);
      expect(store.get('quadrupled'), 20);
      store.dispose();
    });
  });

  group('ReactiveStore — subscription', () {
    test('subscribe receives snapshot on change', () {
      final store = ReactiveStore(const ReactiveStoreOptions(
        initialValues: {'a': 1},
      ));
      Map<String, dynamic>? lastSnapshot;
      store.subscribe((snap) => lastSnapshot = snap);
      store.set('a', 42);
      expect(lastSnapshot, isNotNull);
      expect(lastSnapshot!['a'], 42);
      store.dispose();
    });

    test('unsubscribe stops notifications', () {
      final store = ReactiveStore();
      var count = 0;
      void listener(_) => count++;
      store.subscribe(listener);
      store.set('x', 1);
      expect(count, 1);
      store.unsubscribe(listener);
      store.set('x', 2);
      expect(count, 1);
      store.dispose();
    });
  });

  group('ReactiveStore — snapshot', () {
    test('snapshot includes \$self, \$root', () {
      final store = ReactiveStore(const ReactiveStoreOptions(
        initialValues: {'a': 1, 'b': 2},
      ));
      final snap = store.snapshot();
      expect(snap['a'], 1);
      expect(snap['b'], 2);
      expect(snap['\$self'], isA<Map>());
      expect(snap['\$root'], isA<Map>());
      store.dispose();
    });
  });

  group('ReactiveStore — condition', () {
    test('reaction condition filters execution', () {
      final store = ReactiveStore(ReactiveStoreOptions(
        initialValues: {'enabled': false, 'src': 1, 'dst': 0},
        reactions: [
          Reaction(
            when: 'src',
            target: 'dst',
            effect: ValueEffect(expr: (scope) => (scope['src'] as int) * 10),
            condition: (scope) => scope['enabled'] == true,
          ),
        ],
      ));
      store.runAll();
      expect(store.get('dst'), 0);
      store.set('enabled', true);
      store.set('src', 5);
      expect(store.get('dst'), 50);
      store.dispose();
    });
  });

  group('ReactiveStore — dispose', () {
    test('dispose clears listeners and values', () {
      final store = ReactiveStore(const ReactiveStoreOptions(
        initialValues: {'x': 1},
      ));
      var count = 0;
      store.subscribe((_) => count++);
      store.dispose();
      store.set('x', 2);
      expect(count, 0);
    });
  });
}
