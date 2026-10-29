import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

import 'helpers.dart';

void main() {
  group('applyEffects', () {
    test(
      'runs effects in deterministic tier order and preserves within-tier order',
      () {
        final sink = TestSink();
        applyEffects(
          [
            const EmitEffect(event: 'done'),
            const SetValueEffect(path: 'a', value: 1),
            const SetMetaEffect(path: 'b', meta: {'visible': false}),
            const InvalidateKeyEffect(key: 'k1'),
            const RefreshDataSourceEffect(key: 'k2'),
          ],
          sink,
          const ActionEffectAdapters(),
        );
        expect(sink.calls, [
          'setValue:a=1',
          'setMeta:b',
          'invalidateKey:k1',
          'refreshDataSource:k2',
          'emit:done',
        ]);
      },
    );

    test('missing adapters return diagnostics without aborting', () {
      final sink = TestSink();
      final diags = applyEffects(
        [
          const NavigateEffect(to: '/next'),
          const ToastEffect(level: 'success', fallbackMessage: 'saved'),
          const SetValueEffect(path: 'x', value: 1),
        ],
        sink,
        const ActionEffectAdapters(),
      );
      expect(diags.map((d) => d.code), [
        'ACTION_EFFECT_ADAPTER_MISSING',
        'ACTION_EFFECT_ADAPTER_MISSING',
      ]);
      expect(sink.values['x'], 1);
    });

    test(
      'toast and navigation adapters are called, i18n resolves messageKey',
      () {
        final sink = TestSink();
        final toast = TestToast();
        final nav = TestNavigation();
        applyEffects(
          [
            const ToastEffect(
              level: 'info',
              messageKey: 'saved.key',
              fallbackMessage: 'saved',
            ),
            const NavigateEffect(to: '/done'),
          ],
          sink,
          ActionEffectAdapters(toast: toast, navigation: nav, i18n: TestI18n()),
        );
        expect(toast.calls, ['info:t:saved.key']);
        expect(nav.calls, ['/done']);
      },
    );

    test('effect tier metadata is stable', () {
      expect(effectTier('setValue'), 0);
      expect(effectTier('refreshDataSource'), 1);
      expect(effectTier('toast'), 2);
      expect(effectTier('navigate'), 3);
      expect(effectTier('emit'), 4);
      expect(effectTierOrder.length, 5);
    });
  });
}
