/// ActionResult and ActionError for ADR-018 action runtime parity.
library bitcode.ui_schema.actions.result;

import 'effect.dart' show ActionEffect;

typedef ActionResultStatus = Object;

class ActionError {
  const ActionError({
    required this.code,
    required this.message,
    this.path,
    this.field,
    this.severity = 'error',
    this.recoverable = false,
    this.details,
  });

  final String code;
  final String message;
  final String? path;
  final String? field;
  final String severity;
  final bool recoverable;
  final Map<String, dynamic>? details;

  factory ActionError.fromJson(Map<String, dynamic> json) => ActionError(
    code: json['code'] as String,
    message: json['message'] as String,
    path: json['path'] as String?,
    field: json['field'] as String?,
    severity: json['severity'] as String? ?? 'error',
    recoverable: json['recoverable'] == true,
    details: json['details'] == null
        ? null
        : Map<String, dynamic>.from(json['details'] as Map),
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    if (path != null) 'path': path,
    if (field != null) 'field': field,
    'severity': severity,
    'recoverable': recoverable,
    if (details != null) 'details': details,
  };
}

class ActionResult<T> {
  const ActionResult({
    required this.ok,
    required this.status,
    this.data,
    this.message,
    this.errors,
    this.errorList,
    this.effects,
    this.meta,
  });

  final bool ok;
  final ActionResultStatus status;
  final T? data;
  final String? message;
  final Map<String, Object>? errors;
  final List<ActionError>? errorList;
  final List<ActionEffect>? effects;
  final Map<String, dynamic>? meta;

  Map<String, dynamic> toJson() => {
    'ok': ok,
    'status': status,
    if (data != null) 'data': data,
    if (message != null) 'message': message,
    if (errors != null) 'errors': errors,
    if (errorList != null)
      'errorList': errorList!.map((e) => e.toJson()).toList(),
    if (effects != null) 'effects': effects!.map((e) => e.toJson()).toList(),
    if (meta != null) 'meta': meta,
  };
}

ActionResult<Object?> normalizeActionResult(Object? raw) {
  if (raw is ActionResult<Object?>) return raw;
  if (raw is ActionResult) {
    return ActionResult<Object?>(
      ok: raw.ok,
      status: raw.status,
      data: raw.data,
      message: raw.message,
      errors: raw.errors,
      errorList: raw.errorList,
      effects: raw.effects,
      meta: raw.meta,
    );
  }
  if (!_isPlainObject(raw)) {
    return errorResult(
      'ACTION_RESULT_MALFORMED',
      'Adapter returned a non-object result.',
    );
  }
  final r = Map<String, dynamic>.from(raw as Map);
  final ok = r['ok'] is bool ? r['ok'] as bool : false;
  final hasValidationErrors =
      (r['errors'] != null && _isNonEmpty(r['errors'])) ||
      (r['errorList'] is List && (r['errorList'] as List).isNotEmpty);
  final rawStatus = r['status'];
  final status = _isValidStatus(rawStatus)
      ? rawStatus as Object
      : ok
      ? 'success'
      : hasValidationErrors
      ? 'validation-error'
      : 'error';

  final errors = _errorsFromRaw(r['errors']);
  var errorList = _errorListFromRaw(r['errorList']);
  if (!ok && errorList == null && errors != null) {
    errorList = _synthesizeErrorList(errors);
  }

  return ActionResult<Object?>(
    ok: ok,
    status: status,
    data: r['data'],
    message: r['message'] is String ? r['message'] as String : null,
    errors: errors,
    errorList: errorList,
    effects: r['effects'] is List
        ? (r['effects'] as List)
              .map(
                (e) =>
                    ActionEffect.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList()
        : null,
    meta: _isPlainObject(r['meta'])
        ? Map<String, dynamic>.from(r['meta'] as Map)
        : null,
  );
}

ActionResult<T> successResult<T>(
  T? data, {
  List<ActionEffect>? effects,
  Map<String, dynamic>? meta,
  String? message,
  ActionResultStatus status = 'success',
}) => ActionResult<T>(
  ok: true,
  status: status,
  data: data,
  effects: effects,
  meta: meta,
  message: message,
);

ActionResult<Object?> errorResult(
  String code,
  String message, {
  bool recoverable = false,
  String? field,
  String? path,
  Map<String, dynamic>? details,
  ActionResultStatus status = 'error',
  List<ActionEffect>? effects,
}) => ActionResult<Object?>(
  ok: false,
  status: status,
  errorList: [
    ActionError(
      code: code,
      message: message,
      field: field,
      path: path,
      recoverable: recoverable,
      details: details,
    ),
  ],
  effects: effects,
);

ActionResult<Object?> validationErrorResult(
  Map<String, Object> errors, {
  String? message,
  ActionResultStatus status = 'validation-error',
}) => ActionResult<Object?>(
  ok: false,
  status: status,
  errors: errors,
  errorList: _synthesizeErrorList(errors),
  message: message,
);

bool isValidationError(ActionResult<Object?> result) {
  if (result.ok) return false;
  if (result.status == 'validation-error') return true;
  return (result.errors != null && result.errors!.isNotEmpty) ||
      (result.errorList != null &&
          result.errorList!.any((e) => e.field != null));
}

bool _isPlainObject(Object? value) => value is Map;

bool _isNonEmpty(Object? value) => value is Map && value.isNotEmpty;

bool _isValidStatus(Object? status) =>
    status is num ||
    status == 'idle' ||
    status == 'loading' ||
    status == 'success' ||
    status == 'error' ||
    status == 'validation-error';

Map<String, Object>? _errorsFromRaw(Object? raw) {
  if (raw is! Map) return null;
  final out = <String, Object>{};
  raw.forEach((key, value) {
    if (value is String || value is List) out[key.toString()] = value;
  });
  return out;
}

List<ActionError>? _errorListFromRaw(Object? raw) {
  if (raw is! List) return null;
  final out = <ActionError>[];
  for (final item in raw) {
    if (item is Map && item['code'] is String && item['message'] is String) {
      out.add(ActionError.fromJson(Map<String, dynamic>.from(item)));
    }
  }
  return out;
}

List<ActionError> _synthesizeErrorList(Map<String, Object> errors) {
  final out = <ActionError>[];
  for (final entry in errors.entries) {
    final value = entry.value;
    if (value is List) {
      for (final message in value) {
        out.add(
          ActionError(
            code: 'VALIDATION_ERROR',
            message: message.toString(),
            field: entry.key,
          ),
        );
      }
    } else {
      out.add(
        ActionError(
          code: 'VALIDATION_ERROR',
          message: value.toString(),
          field: entry.key,
        ),
      );
    }
  }
  return out;
}
