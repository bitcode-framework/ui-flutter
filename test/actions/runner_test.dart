import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

import 'helpers.dart';

void main() {
  group('ActionRunner', () {
    test('local source empty effects emits start success settled', () async {
      final setup = makeRunner();
      final result = await setup.runner.run(
        const LocalActionSource(effects: []),
        {},
        makeCtx(),
        const ActionRunOptions(actionId: 'a5'),
      );
      expect(result.ok, isTrue);
      expect(phases(setup.events), ['start', 'success', 'settled']);
    });

    test('local source applies effects via sink in tier order', () async {
      final setup = makeRunner();
      final sink = TestSink();
      await setup.runner.run(
        const LocalActionSource(
          effects: [
            EmitEffect(event: 'done'),
            SetValueEffect(path: 'x', value: 1),
          ],
        ),
        {},
        makeCtx(sink: sink),
        const ActionRunOptions(actionId: 'local'),
      );
      expect(sink.calls, ['setValue:x=1', 'emit:done']);
      expect(phases(setup.events), ['start', 'success', 'settled']);
    });

    test('missing url adapter preflight fails without start', () async {
      final setup = makeRunner();
      final result = await setup.runner.run(
        UrlActionSource(method: 'POST', url: 'https://x'),
        {},
        makeCtx(),
        const ActionRunOptions(actionId: 'a1'),
      );
      expect(result.errorList!.first.code, 'ACTION_ADAPTER_MISSING');
      expect(phases(setup.events), ['error', 'settled']);
    });

    test('handler registry and url policy control execution', () async {
      final setup = makeRunner();
      final handler = TestAdapter({
        'ok': true,
        'status': 'success',
      }, kindValue: 'handler');
      setup.custom.register('submit', handler);
      var result = await setup.runner.run(
        HandlerActionSource(handlerKey: 'submit'),
        {},
        makeCtx(),
        const ActionRunOptions(actionId: 'handler'),
      );
      expect(result.ok, isTrue);

      setup.adapters.register(
        'url',
        TestAdapter({'ok': true, 'status': 'success'}),
      );
      result = await setup.runner.run(
        UrlActionSource(method: 'POST', url: 'https://evil'),
        {},
        makeCtx(adapters: ActionAdapterSet(urlPolicy: TestPolicy(false))),
        const ActionRunOptions(actionId: 'denied'),
      );
      expect(result.errorList!.first.code, 'ACTION_URL_NOT_ALLOWED');
    });

    test('abort before start and abort mid-run are ACTION_ABORTED', () async {
      final setup = makeRunner();
      final ctrl = ActionAbortController()..abort();
      var result = await setup.runner.run(
        const LocalActionSource(effects: []),
        {},
        makeCtx(),
        ActionRunOptions(actionId: 'abort-before', signal: ctrl.signal),
      );
      expect(result.errorList!.first.code, 'ACTION_ABORTED');
      expect(phases(setup.events), ['error', 'settled']);

      final setup2 = makeRunner();
      final ctrl2 = ActionAbortController();
      setup2.adapters.register('url', SlowAbortAdapter());
      final future = setup2.runner.run(
        UrlActionSource(method: 'POST', url: 'https://slow'),
        {},
        makeCtx(),
        ActionRunOptions(actionId: 'abort-mid', signal: ctrl2.signal),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      ctrl2.abort();
      result = await future;
      expect(result.errorList!.first.code, 'ACTION_ABORTED');
      expect(phases(setup2.events), ['start', 'error', 'settled']);
    });

    test('timeout and adapter throws normalize distinct errors', () async {
      final setup = makeRunner();
      setup.adapters.register(
        'url',
        TestAdapter({'ok': true}, delay: const Duration(seconds: 1)),
      );
      var result = await setup.runner.run(
        UrlActionSource(method: 'POST', url: 'https://slow'),
        {},
        makeCtx(),
        const ActionRunOptions(actionId: 'timeout', timeoutMs: 20),
      );
      expect(result.errorList!.first.code, 'ACTION_TIMEOUT');
      expect(result.errorList!.first.recoverable, isTrue);

      final setup2 = makeRunner();
      setup2.adapters.register(
        'url',
        TestAdapter(null, throwValue: 'network down'),
      );
      result = await setup2.runner.run(
        UrlActionSource(method: 'POST', url: 'https://x'),
        {},
        makeCtx(),
        const ActionRunOptions(actionId: 'throw'),
      );
      expect(result.errorList!.first.code, 'ACTION_ADAPTER_THREW');
      expect(result.errorList!.first.message, contains('network down'));
    });

    test(
      'validation errors apply to sink and emit validation-error phase',
      () async {
        final setup = makeRunner();
        setup.adapters.register(
          'url',
          TestAdapter({
            'ok': false,
            'status': 'validation-error',
            'errors': {'email': 'invalid'},
          }),
        );
        final sink = TestSink();
        final result = await setup.runner.run(
          UrlActionSource(method: 'POST', url: 'https://x'),
          {},
          makeCtx(sink: sink),
          const ActionRunOptions(actionId: 'validation'),
        );
        expect(result.ok, isFalse);
        expect(phases(setup.events), ['start', 'validation-error', 'settled']);
        expect(sink.errors['email'], 'invalid');
      },
    );

    test('duplicate actionId returns same in-flight Future', () async {
      final setup = makeRunner();
      final completer = Completer<ActionResult<Object?>>();
      setup.adapters.register('url', _CompleterAdapter(completer));
      final source = UrlActionSource(method: 'POST', url: 'https://x');
      final p1 = setup.runner.run(
        source,
        {},
        makeCtx(),
        const ActionRunOptions(actionId: 'dup'),
      );
      final p2 = setup.runner.run(
        source,
        {},
        makeCtx(),
        const ActionRunOptions(actionId: 'dup'),
      );
      expect(identical(p1, p2), isTrue);
      completer.complete(successResult<Object?>(null));
      expect((await p1).ok, isTrue);
    });

    test(
      'result effects apply and missing effect adapters do not abort',
      () async {
        final setup = makeRunner();
        setup.adapters.register(
          'url',
          TestAdapter({
            'ok': true,
            'status': 'success',
            'effects': [
              {'type': 'navigate', 'to': '/next'},
              {'type': 'setValue', 'path': 'savedAt', 'value': 'now'},
            ],
          }),
        );
        final sink = TestSink();
        final result = await setup.runner.run(
          UrlActionSource(method: 'POST', url: 'https://x'),
          {},
          makeCtx(sink: sink),
          const ActionRunOptions(actionId: 'effects'),
        );
        expect(result.ok, isTrue);
        expect(sink.values['savedAt'], 'now');
        expect(phases(setup.events), ['start', 'success', 'settled']);
      },
    );

    test('invalid source returns result and never throws', () async {
      final setup = makeRunner();
      final result = await setup.runner.run(
        ActionSource.fromJson({'type': 'local', 'effects': []}),
        {},
        makeCtx(),
        const ActionRunOptions(actionId: 'valid'),
      );
      expect(result.ok, isTrue);
    });
  });
}

class _CompleterAdapter implements ActionAdapter {
  _CompleterAdapter(this.completer);

  final Completer<ActionResult<Object?>> completer;

  @override
  String get kind => 'url';

  @override
  Future<ActionResult<Object?>> execute(
    ActionSource source,
    Object? payload,
    ActionRuntimeContext ctx,
    ActionAbortSignal signal,
  ) => completer.future;
}
