/// Top-level lifecycle payload/result redaction for ADR-018 parity.
library bitcode.ui_schema.actions.redact;

import 'runtime_context.dart' show RedactConfig;

Object? redactSensitiveFields(Object? value, RedactConfig? config) {
  if (config == null || config.fields.isEmpty) return _cloneShallow(value);
  if (value is! Map) return _cloneShallow(value);
  final fields = config.fields.toSet();
  final out = <String, Object?>{};
  value.forEach((key, val) {
    final k = key.toString();
    if (config.mode == 'remove') {
      if (!fields.contains(k)) out[k] = val;
    } else {
      out[k] = fields.contains(k) ? '***' : val;
    }
  });
  return out;
}

Object? _cloneShallow(Object? value) {
  if (value == null) return null;
  if (value is List) return List<Object?>.from(value);
  if (value is Map) return Map<String, Object?>.from(value);
  return value;
}
