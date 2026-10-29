/// Portable ActionRunner for ADR-018 action runtime parity.
library bitcode.ui_schema.actions.runner;

import 'dart:async';
import 'dart:math' show Random;

import '../core/types.dart' show BcChangeMeta, BcChangeReason, BcEventSource;
import '../expressions/ast.dart' show PortableExpression;
import '../expressions/evaluator.dart' show ExpressionEvaluator;
import '../expressions/permission_scope.dart' show buildPermissionFilteredScope;
import '../expressions/scope.dart' show ExpressionScope;
import 'adapter.dart';
import 'effect_runner.dart' show ActionEffectAdapters, applyEffects;
import 'lifecycle.dart' show ActionLifecycleEmitter, buildLifecycleEvent;
import 'redact.dart' show redactSensitiveFields;
import 'registry.dart' show CustomActionRegistry;
import 'result.dart';
import 'runtime_context.dart' show ActionRuntimeContext;
import 'source.dart';
import 'validate.dart'
    show checkUrlPolicy, validateActionSource, validateRuntimeContext;

class ActionRunOptions {
  const ActionRunOptions({this.signal, this.timeoutMs, this.actionId});

  final ActionAbortSignal? signal;
  final int? timeoutMs;
  final String? actionId;
}

class ActionRunnerDeps {
  const ActionRunnerDeps({
    required this.adapterRegistry,
    required this.customRegistry,
    this.evaluator,
    this.emit,
  });

  final ActionAdapterRegistry adapterRegistry;
  final CustomActionRegistry customRegistry;
  final ExpressionEvaluator? evaluator;
  final ActionLifecycleEmitter? emit;
}

class ActionRunner {
  ActionRunner(this.deps);

  final ActionRunnerDeps deps;
  final Map<String, Future<ActionResult<Object?>>> _inFlight = {};

  Future<ActionResult<Object?>> run(
    ActionSource action,
    Object? payload,
    ActionRuntimeContext ctx, [
    ActionRunOptions opts = const ActionRunOptions(),
  ]) {
    final actionId = opts.actionId ?? _generateActionId();
    if (opts.actionId != null && _inFlight.containsKey(opts.actionId)) {
      return _inFlight[opts.actionId]!;
    }
    final runFuture = _execute(action, payload, ctx, opts, actionId);
    if (opts.actionId != null) {
      final dedupId = opts.actionId!;
      _inFlight[dedupId] = runFuture;
      runFuture.whenComplete(() => _inFlight.remove(dedupId));
    }
    return runFuture;
  }

  Future<ActionResult<Object?>> _execute(
    ActionSource action,
    Object? payload,
    ActionRuntimeContext ctx,
    ActionRunOptions opts,
    String actionId,
  ) async {
    const meta = BcChangeMeta(
      reason: BcChangeReason.programmatic,
      source: BcEventSource.programmatic,
    );
    final emit = deps.emit;
    final redact = ctx.redact;

    ActionResult<Object?> failPreflight(ActionResult<Object?> result) {
      emit?.call(
        buildLifecycleEvent(
          actionId,
          action,
          'error',
          meta,
          result: _redactResult(result, redact),
        ),
      );
      emit?.call(buildLifecycleEvent(actionId, action, 'settled', meta));
      return result;
    }

    if (opts.signal?.aborted == true) {
      return failPreflight(
        errorResult(
          'ACTION_ABORTED',
          'Action was aborted before it started.',
          recoverable: true,
        ),
      );
    }

    final sourceResult = validateActionSource(action);
    if (!sourceResult.valid) {
      return failPreflight(
        errorResult(
          'ACTION_SOURCE_INVALID',
          sourceResult.diagnostics.map((d) => d.message).join(' '),
        ),
      );
    }

    final ctxDiags = validateRuntimeContext(
      action,
      ctx,
      deps.adapterRegistry,
      deps.customRegistry,
    );
    if (ctxDiags.isNotEmpty) {
      final first = ctxDiags.first;
      return failPreflight(
        errorResult(first.code, ctxDiags.map((d) => d.message).join(' ')),
      );
    }

    if (action is UrlActionSource) {
      final urlDiags = checkUrlPolicy(action, ctx.adapters.urlPolicy);
      if (urlDiags.isNotEmpty) {
        return failPreflight(
          errorResult(urlDiags.first.code, urlDiags.first.message),
        );
      }
    }

    final baseScope = ctx.permissions == null
        ? ctx.scope
        : ExpressionScope(
            values: ctx.scope.values,
            meta: ctx.scope.meta,
            data: ctx.scope.data,
            services: ctx.scope.services,
            permissions: ctx.permissions!,
            args: ctx.scope.args,
          );
    final filteredScope = buildPermissionFilteredScope(baseScope);

    Object? resolvedPayload = payload;
    try {
      resolvedPayload = _resolvePayload(action, payload, filteredScope);
    } catch (err) {
      return failPreflight(
        errorResult(
          'ACTION_SOURCE_INVALID',
          'Payload expression evaluation failed: ${err.toString()}',
        ),
      );
    }

    emit?.call(
      buildLifecycleEvent(
        actionId,
        action,
        'start',
        meta,
        payload: redactSensitiveFields(resolvedPayload, redact),
      ),
    );

    Object? rawResult;
    try {
      if (action is LocalActionSource) {
        rawResult = _runLocal(action, ctx);
      } else {
        rawResult = await _runAdapter(action, resolvedPayload, ctx, opts);
      }
    } catch (err) {
      final result = _classifyThrow(err, opts);
      _finishRun(action, actionId, meta, emit, ctx, result);
      return result;
    }

    final result = normalizeActionResult(rawResult);
    _finishRun(action, actionId, meta, emit, ctx, result);
    return result;
  }

  ActionResult<Object?> _runLocal(
    LocalActionSource action,
    ActionRuntimeContext ctx,
  ) {
    final diags = applyEffects(
      action.effects,
      ctx.effectSink,
      ActionEffectAdapters(
        navigation: ctx.adapters.navigation,
        toast: ctx.adapters.toast,
        i18n: ctx.adapters.i18n,
      ),
    );
    if (diags.isEmpty) return successResult<Object?>(null);
    return ActionResult<Object?>(
      ok: true,
      status: 'success',
      message: 'Action completed with effect warnings.',
      errorList: [
        for (final diag in diags)
          ActionError(
            code: diag.code,
            message: diag.message,
            severity: 'warning',
          ),
      ],
    );
  }

  Future<Object?> _runAdapter(
    ActionSource action,
    Object? payload,
    ActionRuntimeContext ctx,
    ActionRunOptions opts,
  ) async {
    final adapter = _resolveAdapter(action);
    final signal = opts.signal ?? ActionAbortController().signal;
    if (opts.timeoutMs != null && opts.timeoutMs! > 0) {
      return _raceWithTimeout(
        () => adapter.execute(action, payload, ctx, signal),
        opts.timeoutMs!,
        signal,
      );
    }
    return adapter.execute(action, payload, ctx, signal);
  }

  Future<Object?> _raceWithTimeout(
    Future<Object?> Function() run,
    int timeoutMs,
    ActionAbortSignal signal,
  ) {
    final completer = Completer<Object?>();
    late Timer timer;
    void onAbort() {
      if (!completer.isCompleted) {
        completer.completeError(const ActionAbortedException());
      }
      timer.cancel();
    }

    if (signal.aborted) {
      return Future<Object?>.error(const ActionAbortedException());
    }
    signal.addListener(onAbort);
    timer = Timer(Duration(milliseconds: timeoutMs), () {
      if (!completer.isCompleted) {
        completer.completeError(ActionTimeoutException(timeoutMs));
      }
    });
    run()
        .then((value) {
          if (!completer.isCompleted) completer.complete(value);
        })
        .catchError((Object err) {
          if (!completer.isCompleted) completer.completeError(err);
        })
        .whenComplete(() {
          timer.cancel();
          signal.removeListener(onAbort);
        });
    return completer.future;
  }

  ActionAdapter _resolveAdapter(ActionSource action) {
    if (action is HandlerActionSource) {
      return deps.customRegistry.resolve(action.handlerKey)!;
    }
    if (action is UrlActionSource) {
      return deps.adapterRegistry.resolve('url')!;
    }
    if (action is ModelActionSource) {
      return deps.adapterRegistry.resolve(action.adapter ?? 'model')!;
    }
    throw StateError(
      "resolveAdapter: unsupported source type '${action.type}'.",
    );
  }

  Object? _resolvePayload(
    ActionSource action,
    Object? payload,
    ExpressionScope scope,
  ) {
    final evaluator = deps.evaluator;
    if (evaluator == null) {
      _assertNoAst(action, payload);
      return payload;
    }
    if (action is UrlActionSource &&
        action.body != null &&
        _isAstNode(action.body)) {
      final evaluated = evaluator.evaluate(
        action.body! as PortableExpression,
        scope,
      );
      return {
        ..._payloadBase(payload),
        '__body': evaluated.ok ? evaluated.value : evaluated,
      };
    }
    if (action is ModelActionSource) {
      var resolvedId = action.id;
      var resolvedPayload = action.payload;
      if (resolvedId != null && _isAstNode(resolvedId)) {
        final evaluated = evaluator.evaluate(
          resolvedId as PortableExpression,
          scope,
        );
        resolvedId = evaluated.ok ? evaluated.value : evaluated;
      }
      if (resolvedPayload != null && _isAstNode(resolvedPayload)) {
        final evaluated = evaluator.evaluate(
          resolvedPayload as PortableExpression,
          scope,
        );
        resolvedPayload = evaluated.ok ? evaluated.value : evaluated;
      }
      final base = _payloadBase(payload);
      if (resolvedId != null) base['__id'] = resolvedId;
      if (resolvedPayload != null) base['__payload'] = resolvedPayload;
      return base;
    }
    _assertNoAst(action, payload);
    return payload;
  }

  void _assertNoAst(ActionSource action, Object? payload) {
    if (action is UrlActionSource && _isAstNode(action.body)) {
      throw StateError(
        'url action body is a PortableExpression but no evaluator is registered.',
      );
    }
    if (action is ModelActionSource &&
        (_isAstNode(action.id) || _isAstNode(action.payload))) {
      throw StateError(
        'model action id/payload is a PortableExpression but no evaluator is registered.',
      );
    }
    if (_isAstNode(payload)) {
      throw StateError(
        'payload is a PortableExpression but no evaluator is registered.',
      );
    }
  }

  ActionResult<Object?> _classifyThrow(Object err, ActionRunOptions opts) {
    if (err is ActionAbortedException || opts.signal?.aborted == true) {
      return errorResult(
        'ACTION_ABORTED',
        'Action was aborted.',
        recoverable: true,
      );
    }
    if (err is ActionTimeoutException) {
      return errorResult(
        'ACTION_TIMEOUT',
        'Action exceeded timeout of ${err.timeoutMs}ms.',
        recoverable: true,
      );
    }
    return errorResult(
      'ACTION_ADAPTER_THREW',
      'Adapter threw an un-normalized error: ${err.toString()}',
    );
  }

  void _finishRun(
    ActionSource action,
    String actionId,
    BcChangeMeta meta,
    ActionLifecycleEmitter? emit,
    ActionRuntimeContext ctx,
    ActionResult<Object?> result,
  ) {
    final redacted = _redactResult(result, ctx.redact);
    if (!result.ok && result.errors != null) {
      for (final entry in result.errors!.entries) {
        final value = entry.value;
        final message = value is List ? value.join('; ') : value.toString();
        ctx.effectSink.setError(entry.key, message);
      }
    }
    if (result.effects != null && result.effects!.isNotEmpty) {
      applyEffects(
        result.effects!,
        ctx.effectSink,
        ActionEffectAdapters(
          navigation: ctx.adapters.navigation,
          toast: ctx.adapters.toast,
          i18n: ctx.adapters.i18n,
        ),
      );
    }
    final phase = result.ok
        ? 'success'
        : isValidationError(result)
        ? 'validation-error'
        : 'error';
    emit?.call(
      buildLifecycleEvent(actionId, action, phase, meta, result: redacted),
    );
    emit?.call(buildLifecycleEvent(actionId, action, 'settled', meta));
  }

  ActionResult<Object?> _redactResult(
    ActionResult<Object?> result,
    Object? redact,
  ) {
    if (redact == null || result.data == null) return result;
    return ActionResult<Object?>(
      ok: result.ok,
      status: result.status,
      data: redactSensitiveFields(result.data, redact as dynamic),
      message: result.message,
      errors: result.errors,
      errorList: result.errorList,
      effects: result.effects,
      meta: result.meta,
    );
  }

  Map<String, Object?> _payloadBase(Object? payload) {
    if (payload is Map) return Map<String, Object?>.from(payload);
    return <String, Object?>{};
  }

  bool _isAstNode(Object? value) =>
      value is PortableExpression ||
      (value is Map &&
          value['kind'] is String &&
          {'literal', 'path', 'op', 'call', 'if'}.contains(value['kind']));

  String _generateActionId() {
    final suffix = Random().nextInt(0xFFFFFF).toRadixString(36).padLeft(4, '0');
    return 'action-${DateTime.now().millisecondsSinceEpoch}-$suffix';
  }
}

class ActionAbortedException implements Exception {
  const ActionAbortedException();
}

class ActionTimeoutException implements Exception {
  const ActionTimeoutException(this.timeoutMs);

  final int timeoutMs;
}
