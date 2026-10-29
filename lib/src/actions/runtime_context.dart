/// Runtime context and host adapters for ADR-018 action runtime parity.
library bitcode.ui_schema.actions.runtime_context;

import '../expressions/scope.dart' show ExpressionScope, PermissionSnapshot;

abstract class EffectSink {
  void setValue(String path, Object? value);
  void setMeta(String path, Map<String, dynamic> meta);
  void setError(String path, Object? error);
  void refreshDataSource(String key);
  void invalidateKey(String key);
  void closeOverlay([String? overlayId]);
  void resetForm([String? formId, String? scope]);
  void emit(String event, [Object? payload]);
}

abstract class PermissionAdapter {
  Future<ExpressionScope> enrichScope(ExpressionScope scope);
  Future<PermissionSnapshot> revalidate(ExpressionScope scope);
}

abstract class NavigationAdapter {
  void navigate(String to, {bool? replace, Map<String, dynamic>? params});
}

abstract class ToastAdapter {
  void show(String level, String message);
}

abstract class I18nAdapter {
  String t(String key, String fallback, [Map<String, dynamic>? vars]);
  String locale();
}

abstract class UrlPolicy {
  bool isAllowed(String url, String method);
}

class ActionAdapterSet {
  const ActionAdapterSet({
    this.permission,
    this.navigation,
    this.toast,
    this.i18n,
    this.urlPolicy,
  });

  final PermissionAdapter? permission;
  final NavigationAdapter? navigation;
  final ToastAdapter? toast;
  final I18nAdapter? i18n;
  final UrlPolicy? urlPolicy;
}

class RedactConfig {
  const RedactConfig({required this.fields, required this.mode});

  final List<String> fields;
  final String mode;
}

class ActionRuntimeContext {
  const ActionRuntimeContext({
    required this.values,
    required this.meta,
    required this.data,
    required this.scope,
    required this.adapters,
    required this.effectSink,
    this.redact,
    this.permissions,
  });

  final Map<String, dynamic> values;
  final Map<String, dynamic> meta;
  final Map<String, dynamic> data;
  final ExpressionScope scope;
  final ActionAdapterSet adapters;
  final EffectSink effectSink;
  final RedactConfig? redact;
  final PermissionSnapshot? permissions;
}

class RecordingEffectSink implements EffectSink {
  final List<String> calls = [];
  final Map<String, Object?> values = {};
  final Map<String, Map<String, dynamic>> metas = {};
  final Map<String, Object?> errors = {};

  @override
  void closeOverlay([String? overlayId]) =>
      calls.add('closeOverlay:${overlayId ?? ''}');

  @override
  void emit(String event, [Object? payload]) {
    calls.add('emit:$event');
  }

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
  void setMeta(String path, Map<String, dynamic> meta) {
    calls.add('setMeta:$path');
    metas[path] = meta;
  }

  @override
  void setValue(String path, Object? value) {
    calls.add('setValue:$path');
    values[path] = value;
  }
}
