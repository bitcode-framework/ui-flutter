/// ReactiveStore — pure Dart port of @bitcode/ui-schema/src/reactive/store.ts.
///
/// Headless reactive engine (ADR-004 / ADR-011 Section 4).
/// NO Flutter imports — testable via `dart test` without Flutter binding.
///
/// Responsibilities:
///   - Store named cells (values) and per-field metadata.
///   - Maintain a reaction dependency graph.
///   - Re-run reactions when cells change (work queue, fixpoint).
///   - Emit change events to subscribers.
///
/// The Flutter adapter [ReactiveStoreNotifier] wraps this class to bridge
/// subscriptions to ChangeNotifier.notifyListeners().

library reactive_store;

import '../actions/actions.dart' as actions;
import '../expressions/scope.dart' show ExpressionScope, PermissionSnapshot;

typedef FieldPath = String;
typedef Listener = void Function(Map<String, dynamic> snapshot);

/// Per-field metadata. Mirrors TS FieldMeta.
class FieldMeta {
  bool visible;
  bool disabled;
  bool required;
  List<dynamic>? options;
  List<ValidationRule>? rules;
  String? error;
  bool loading;

  FieldMeta({
    this.visible = true,
    this.disabled = false,
    this.required = false,
    this.options,
    this.rules,
    this.error,
    this.loading = false,
  });

  FieldMeta copyWith({
    bool? visible,
    bool? disabled,
    bool? required,
    List<dynamic>? options,
    List<ValidationRule>? rules,
    String? error,
    bool? loading,
  }) => FieldMeta(
    visible: visible ?? this.visible,
    disabled: disabled ?? this.disabled,
    required: required ?? this.required,
    options: options ?? this.options,
    rules: rules ?? this.rules,
    error: error ?? this.error,
    loading: loading ?? this.loading,
  );
}

/// Validation rule. Mirrors TS ValidationRule.
class ValidationRule {
  final String type;
  final dynamic value;
  final String? message;
  final bool Function(dynamic value)? fn;

  const ValidationRule({required this.type, this.value, this.message, this.fn});
}

/// Effect types (discriminated union via kind).
enum EffectKind { data, value, ui, validation }

/// Base effect class. Concrete subtypes below.
abstract class Effect {
  EffectKind get kind;
}

/// Re-query a field's data source when dependencies change.
class DataEffect extends Effect {
  final DataSource source;
  final bool clearOnChange;

  DataEffect({required this.source, this.clearOnChange = false});

  @override
  EffectKind get kind => EffectKind.data;
}

/// Compute a field's value from a function.
class ValueEffect extends Effect {
  final dynamic Function(Map<String, dynamic> scope)? expr;

  ValueEffect({this.expr});

  @override
  EffectKind get kind => EffectKind.value;
}

/// Show/hide, enable/disable, require/unrequire.
class UiEffect extends Effect {
  final dynamic Function(Map<String, dynamic> scope)? visible;
  final dynamic Function(Map<String, dynamic> scope)? disabled;
  final dynamic Function(Map<String, dynamic> scope)? required;

  UiEffect({this.visible, this.disabled, this.required});

  @override
  EffectKind get kind => EffectKind.ui;
}

/// Replace a field's validation rules.
class ValidationEffect extends Effect {
  final dynamic
  rules; // List<ValidationRule> or Function(scope) => List<ValidationRule>

  ValidationEffect({required this.rules});

  @override
  EffectKind get kind => EffectKind.validation;
}

/// Data source for DATA effects.
class DataSource {
  final String type; // 'model' | 'url' | 'fetcher' | 'local'
  final String? name;
  final String? url;
  final Future<List<dynamic>> Function(Map<String, dynamic> scope)? fetcher;
  final List<dynamic>? data;
  final Map<String, dynamic>? filters;

  const DataSource({
    required this.type,
    this.name,
    this.url,
    this.fetcher,
    this.data,
    this.filters,
  });
}

/// A reaction: when [when] changes, apply [effect] to [target].
class Reaction {
  final List<FieldPath> when;
  final FieldPath target;
  final Effect effect;
  final bool Function(Map<String, dynamic> scope)? condition;

  Reaction({
    required dynamic when,
    required this.target,
    required this.effect,
    this.condition,
  }) : when = when is List<FieldPath>
           ? when
           : when is List
           ? List<FieldPath>.from(when)
           : [when];
}

/// Minimal contract for a parent scope (nested stores).
abstract class ReactiveScopeLike {
  Map<String, dynamic> snapshot();
  ReactiveScopeLike getRoot();
}

/// Options for constructing a [ReactiveStore].
class ReactiveStoreOptions {
  final Map<String, dynamic>? initialValues;
  final List<Reaction>? reactions;
  final void Function(FieldPath path, dynamic value)? onChange;
  final ReactiveScopeLike? parent;
  final int? index;
  final Evaluator? evaluator;

  const ReactiveStoreOptions({
    this.initialValues,
    this.reactions,
    this.onChange,
    this.parent,
    this.index,
    this.evaluator,
  });
}

/// Plug-in slot for string-based expression evaluators.
abstract class Evaluator {
  dynamic evaluate(String expr, Map<String, dynamic> scope);
}

/// Headless reactive store (ADR-004, ADR-011 Section 4 Layer 1).
///
/// Pure Dart — no Flutter dependency. Testable with `dart test`.
class ReactiveStore implements ReactiveScopeLike {
  final Map<String, dynamic> _values = {};
  final Map<String, FieldMeta> _meta = {};
  final List<Reaction> _reactions;
  final void Function(FieldPath path, dynamic value)? _onChange;
  final Set<Listener> _listeners = {};
  ReactiveScopeLike? _parent;
  final int? _index;
  Evaluator? _evaluator;

  ReactiveStore([ReactiveStoreOptions opts = const ReactiveStoreOptions()])
    : _reactions = opts.reactions != null ? List.from(opts.reactions!) : [],
      _onChange = opts.onChange,
      _parent = opts.parent,
      _index = opts.index,
      _evaluator = opts.evaluator {
    if (opts.initialValues != null) {
      _values.addAll(opts.initialValues!);
    }
  }

  // -- Scope linkage -------------------------------------------------------

  @override
  ReactiveScopeLike getRoot() {
    ReactiveScopeLike cursor = this;
    for (var i = 0; i < 64; i++) {
      if (cursor is! ReactiveStore) return cursor;
      final next = cursor._parent;
      if (next == null) return cursor;
      cursor = next;
    }
    return cursor;
  }

  void setEvaluator(Evaluator? evaluator) {
    _evaluator = evaluator;
  }

  Evaluator? getEvaluator() => _evaluator;

  Future<actions.ActionResult<Object?>> runAction(
    actions.ActionSource source, {
    Object? payload,
    actions.ActionRunner? runner,
    actions.ActionAdapterRegistry? adapterRegistry,
    actions.CustomActionRegistry? customRegistry,
    actions.ActionAdapterSet adapters = const actions.ActionAdapterSet(),
    ExpressionScope? scope,
    PermissionSnapshot permissions = const PermissionSnapshot(superuser: true),
    actions.RedactConfig? redact,
    actions.ActionRunOptions options = const actions.ActionRunOptions(),
  }) {
    final sink = _ReactiveStoreEffectSink(this);
    final ctx = actions.ActionRuntimeContext(
      values: _localSnapshot(),
      meta: _metaSnapshot(),
      data: const {},
      scope:
          scope ??
          ExpressionScope(
            values: _localSnapshot(),
            meta: _metaSnapshot(),
            data: const {},
            services: const {},
            permissions: permissions,
          ),
      adapters: adapters,
      effectSink: sink,
      redact: redact,
      permissions: permissions,
    );
    final effectiveRunner =
        runner ??
        actions.ActionRunner(
          actions.ActionRunnerDeps(
            adapterRegistry:
                adapterRegistry ?? actions.InMemoryActionAdapterRegistry(),
            customRegistry:
                customRegistry ?? actions.InMemoryCustomActionRegistry(),
          ),
        );
    return effectiveRunner.run(source, payload, ctx, options);
  }

  // -- Read / write cells --------------------------------------------------

  dynamic get(FieldPath path) => _values[path];

  void set(FieldPath path, dynamic value) {
    final old = _values[path];
    if (old == value) return;
    _values[path] = value;
    _onChange?.call(path, value);
    _runAffected(path);
    _notify();
  }

  void setMany(Map<String, dynamic> patch) {
    var changed = false;
    final affected = <FieldPath>{};
    for (final entry in patch.entries) {
      final old = _values[entry.key];
      if (old == entry.value) continue;
      _values[entry.key] = entry.value;
      _onChange?.call(entry.key, entry.value);
      affected.add(entry.key);
      changed = true;
    }
    if (!changed) return;
    for (final k in affected) {
      _runAffected(k);
    }
    _notify();
  }

  // -- Metadata ------------------------------------------------------------

  FieldMeta getMeta(FieldPath path) {
    return _meta[path] ?? FieldMeta();
  }

  // -- Snapshot ------------------------------------------------------------

  Map<String, dynamic> _localSnapshot() {
    return Map<String, dynamic>.from(_values);
  }

  Map<String, dynamic> _metaSnapshot() => _meta.map(
    (key, value) => MapEntry(key, {
      'visible': value.visible,
      'disabled': value.disabled,
      'required': value.required,
      if (value.options != null) 'options': value.options,
      if (value.error != null) 'error': value.error,
      'loading': value.loading,
    }),
  );

  @override
  Map<String, dynamic> snapshot() {
    final self = _localSnapshot();
    final s = <String, dynamic>{...self};
    s['\$self'] = self;
    if (_index != null) s['\$index'] = _index;
    if (_parent != null) {
      final parentLocal = _parent is ReactiveStore
          ? (_parent as ReactiveStore)._localSnapshot()
          : _parent!.snapshot();
      s['\$parent'] = parentLocal;
      final root = _parent!.getRoot();
      final rootLocal = root == _parent
          ? parentLocal
          : root is ReactiveStore
          ? root._localSnapshot()
          : root.snapshot();
      s['\$root'] = rootLocal;
    } else {
      s['\$root'] = self;
    }
    return s;
  }

  // -- Expression helper ---------------------------------------------------

  dynamic evaluate(String expr, [Map<String, dynamic>? scope]) {
    if (_evaluator == null) {
      throw StateError(
        'ReactiveStore.evaluate: no evaluator attached. '
        'Pass evaluator in options or use the function form of reactions.',
      );
    }
    return _evaluator!.evaluate(expr, scope ?? snapshot());
  }

  // -- Subscription --------------------------------------------------------

  void subscribe(Listener listener) {
    _listeners.add(listener);
  }

  void unsubscribe(Listener listener) {
    _listeners.remove(listener);
  }

  void _notify() {
    final snap = snapshot();
    for (final l in _listeners) {
      l(snap);
    }
  }

  // -- Reaction runner -----------------------------------------------------

  void _propagate(List<FieldPath> initial) {
    final queue = List<FieldPath>.from(initial);
    var iterations = 0;
    const maxIterations = 10000;
    while (queue.isNotEmpty) {
      if (++iterations > maxIterations) {
        throw StateError(
          'ReactiveStore: reaction cycle detected (iteration cap exceeded)',
        );
      }
      final source = queue.removeAt(0);
      for (final reaction in _reactions) {
        if (!reaction.when.contains(source)) continue;
        final scope = snapshot();
        if (reaction.condition != null && !reaction.condition!(scope)) continue;
        final valueChanged = _applyEffect(
          reaction.target,
          reaction.effect,
          scope,
        );
        if (valueChanged) queue.add(reaction.target);
      }
    }
  }

  void _runAffected(FieldPath source) {
    _propagate([source]);
  }

  /// Recompute all reactions (used on initialization).
  void runAll() {
    var scope = snapshot();
    for (final reaction in _reactions) {
      if (reaction.condition != null && !reaction.condition!(scope)) continue;
      final changed = _applyEffect(reaction.target, reaction.effect, scope);
      if (changed) scope = snapshot();
    }
  }

  /// Returns true if the effect changed the target's VALUE (triggers cascade).
  bool _applyEffect(
    FieldPath target,
    Effect effect,
    Map<String, dynamic> scope,
  ) {
    switch (effect.kind) {
      case EffectKind.ui:
        _applyUi(target, effect as UiEffect, scope);
        return false;
      case EffectKind.value:
        return _applyValue(target, effect as ValueEffect, scope);
      case EffectKind.validation:
        _applyValidation(target, effect as ValidationEffect, scope);
        return false;
      case EffectKind.data:
        return _applyData(target, effect as DataEffect, scope);
    }
  }

  void _applyUi(FieldPath target, UiEffect ui, Map<String, dynamic> scope) {
    var meta = getMeta(target);
    var changed = false;
    if (ui.visible != null) {
      final v = _resolveBool(ui.visible, scope);
      if (meta.visible != v) {
        meta = meta.copyWith(visible: v);
        changed = true;
      }
    }
    if (ui.disabled != null) {
      final v = _resolveBool(ui.disabled, scope);
      if (meta.disabled != v) {
        meta = meta.copyWith(disabled: v);
        changed = true;
      }
    }
    if (ui.required != null) {
      final v = _resolveBool(ui.required, scope);
      if (meta.required != v) {
        meta = meta.copyWith(required: v);
        changed = true;
      }
    }
    if (changed) _meta[target] = meta;
  }

  bool _resolveBool(dynamic fnOrVal, Map<String, dynamic> scope) {
    if (fnOrVal is Function) return fnOrVal(scope) == true;
    return fnOrVal == true;
  }

  bool _applyValue(
    FieldPath target,
    ValueEffect value,
    Map<String, dynamic> scope,
  ) {
    if (value.expr == null) return false;
    final next = value.expr!(scope);
    final old = _values[target];
    if (old == next) return false;
    _values[target] = next;
    _onChange?.call(target, next);
    return true;
  }

  void _applyValidation(
    FieldPath target,
    ValidationEffect validation,
    Map<String, dynamic> scope,
  ) {
    List<ValidationRule> rules;
    if (validation.rules is Function) {
      rules = (validation.rules as Function)(scope) as List<ValidationRule>;
    } else {
      rules = validation.rules as List<ValidationRule>;
    }
    _meta[target] = getMeta(target).copyWith(rules: rules);
  }

  bool _applyData(
    FieldPath target,
    DataEffect data,
    Map<String, dynamic> scope,
  ) {
    var valueChanged = false;
    if (data.clearOnChange) {
      final old = _values[target];
      if (old != null) {
        _values[target] = null;
        _onChange?.call(target, null);
        valueChanged = true;
      }
    }

    _meta[target] = getMeta(target).copyWith(loading: true);

    final fetcher = _buildFetcher(data, scope);
    if (fetcher == null) {
      _meta[target] = getMeta(target).copyWith(loading: false, options: []);
      return valueChanged;
    }

    // Fire-and-forget async re-query.
    fetcher()
        .then((options) {
          _meta[target] = getMeta(
            target,
          ).copyWith(loading: false, options: options);
          _notify();
        })
        .catchError((err) {
          _meta[target] = getMeta(
            target,
          ).copyWith(loading: false, options: [], error: err.toString());
          _notify();
        });

    return valueChanged;
  }

  Future<List<dynamic>> Function()? _buildFetcher(
    DataEffect data,
    Map<String, dynamic> scope,
  ) {
    switch (data.source.type) {
      case 'local':
        return () async => data.source.data ?? [];
      case 'fetcher':
        return data.source.fetcher != null
            ? () => data.source.fetcher!(scope)
            : null;
      case 'url':
        // Pure Dart — use dart:io HttpClient or leave to consumer.
        // For now, return null (consumer provides fetcher for network sources).
        return null;
      case 'model':
        return null;
      default:
        return null;
    }
  }

  // -- Lifecycle -----------------------------------------------------------

  void dispose() {
    _listeners.clear();
    _reactions.clear();
    _values.clear();
    _meta.clear();
    _parent = null;
    _evaluator = null;
  }
}

class _ReactiveStoreEffectSink implements actions.EffectSink {
  _ReactiveStoreEffectSink(this.store);

  final ReactiveStore store;

  @override
  void closeOverlay([String? overlayId]) {}

  @override
  void emit(String event, [Object? payload]) {}

  @override
  void invalidateKey(String key) {}

  @override
  void refreshDataSource(String key) {}

  @override
  void resetForm([String? formId, String? scope]) {
    if (scope == null || scope.isEmpty) {
      store.setMany({});
    }
  }

  @override
  void setError(String path, Object? error) {
    store._meta[path] = store.getMeta(path).copyWith(error: error?.toString());
    store._notify();
  }

  @override
  void setMeta(String path, Map<String, dynamic> meta) {
    var current = store.getMeta(path);
    current = current.copyWith(
      visible: meta['visible'] is bool ? meta['visible'] as bool : null,
      disabled: meta['disabled'] is bool ? meta['disabled'] as bool : null,
      required: meta['required'] is bool ? meta['required'] as bool : null,
      options: meta['options'] is List
          ? List<dynamic>.from(meta['options'] as List)
          : null,
      error: meta['error'] is String ? meta['error'] as String : null,
      loading: meta['loading'] is bool ? meta['loading'] as bool : null,
    );
    store._meta[path] = current;
    store._notify();
  }

  @override
  void setValue(String path, Object? value) {
    store.set(path, value);
  }
}
