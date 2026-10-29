import 'dart:async';

import 'package:bc_ui_flutter/bc_ui_flutter.dart';

class TestSink implements EffectSink {
  final List<String> calls = [];
  final Map<String, Object?> values = {};
  final Map<String, Object?> errors = {};

  @override
  void closeOverlay([String? overlayId]) =>
      calls.add('closeOverlay:${overlayId ?? ''}');

  @override
  void emit(String event, [Object? payload]) => calls.add('emit:$event');

  @override
  void invalidateKey(String key) => calls.add('invalidateKey:$key');

  @override
  void refreshDataSource(String key) => calls.add('refreshDataSource:$key');

  @override
  void resetForm([String? formId, String? scope]) =>
      calls.add('resetForm:${formId ?? ''}:${scope ?? ''}');

  @override
  void setError(String path, Object? error) {
    calls.add('setError:$path');
    errors[path] = error;
  }

  @override
  void setMeta(String path, Map<String, dynamic> meta) =>
      calls.add('setMeta:$path');

  @override
  void setValue(String path, Object? value) {
    calls.add('setValue:$path=$value');
    values[path] = value;
  }
}

class TestAdapter implements ActionAdapter {
  TestAdapter(
    this.result, {
    this.kindValue = 'url',
    this.delay,
    this.throwValue,
  });

  final Object? result;
  final String kindValue;
  final Duration? delay;
  final Object? throwValue;

  @override
  String get kind => kindValue;

  @override
  Future<ActionResult<Object?>> execute(
    ActionSource source,
    Object? payload,
    ActionRuntimeContext ctx,
    ActionAbortSignal signal,
  ) async {
    if (delay != null) await Future<void>.delayed(delay!);
    if (signal.aborted) throw const ActionAbortedException();
    if (throwValue != null) throw throwValue!;
    return normalizeActionResult(result);
  }
}

class SlowAbortAdapter implements ActionAdapter {
  @override
  String get kind => 'url';

  @override
  Future<ActionResult<Object?>> execute(
    ActionSource source,
    Object? payload,
    ActionRuntimeContext ctx,
    ActionAbortSignal signal,
  ) {
    final completer = Completer<ActionResult<Object?>>();
    void onAbort() {
      if (!completer.isCompleted)
        completer.completeError(const ActionAbortedException());
    }

    signal.addListener(onAbort);
    Timer(const Duration(seconds: 5), () {
      signal.removeListener(onAbort);
      if (!completer.isCompleted)
        completer.complete(successResult<Object?>(null));
    });
    return completer.future;
  }
}

class TestToast implements ToastAdapter {
  final List<String> calls = [];

  @override
  void show(String level, String message) => calls.add('$level:$message');
}

class TestNavigation implements NavigationAdapter {
  final List<String> calls = [];

  @override
  void navigate(String to, {bool? replace, Map<String, dynamic>? params}) =>
      calls.add(to);
}

class TestI18n implements I18nAdapter {
  @override
  String locale() => 'en';

  @override
  String t(String key, String fallback, [Map<String, dynamic>? vars]) =>
      't:$key';
}

class TestPolicy implements UrlPolicy {
  TestPolicy(this.allowed);

  final bool allowed;

  @override
  bool isAllowed(String url, String method) => allowed;
}

({
  ActionRunner runner,
  InMemoryActionAdapterRegistry adapters,
  InMemoryCustomActionRegistry custom,
  List<ActionLifecycleEvent> events,
})
makeRunner() {
  final events = <ActionLifecycleEvent>[];
  final adapters = InMemoryActionAdapterRegistry();
  final custom = InMemoryCustomActionRegistry();
  final runner = ActionRunner(
    ActionRunnerDeps(
      adapterRegistry: adapters,
      customRegistry: custom,
      emit: events.add,
    ),
  );
  return (runner: runner, adapters: adapters, custom: custom, events: events);
}

ActionRuntimeContext makeCtx({
  ActionAdapterSet adapters = const ActionAdapterSet(),
  TestSink? sink,
}) {
  final s = sink ?? TestSink();
  return ActionRuntimeContext(
    values: const {},
    meta: const {},
    data: const {},
    scope: const ExpressionScope(
      values: {},
      meta: {},
      data: {},
      services: {},
      permissions: PermissionSnapshot(superuser: true),
    ),
    adapters: adapters,
    effectSink: s,
  );
}

List<String> phases(List<ActionLifecycleEvent> events) =>
    events.map((e) => e.phase).toList();
