/// ActionSource and runtime context validators for ADR-018 parity.
library bitcode.ui_schema.actions.validate;

import 'adapter.dart' show ActionAdapterRegistry;
import 'registry.dart' show CustomActionRegistry;
import 'runtime_context.dart' show ActionRuntimeContext, UrlPolicy;
import 'source.dart'
    show
        ActionSource,
        HandlerActionSource,
        LocalActionSource,
        ModelActionSource,
        UrlActionSource,
        isActionSourceType;

class ActionValidationDiagnostic {
  const ActionValidationDiagnostic({
    required this.code,
    required this.message,
    this.fieldPath,
  });

  final String code;
  final String message;
  final String? fieldPath;

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    if (fieldPath != null) 'fieldPath': fieldPath,
  };
}

class SourceValidationResult {
  const SourceValidationResult({
    required this.valid,
    required this.diagnostics,
  });

  final bool valid;
  final List<ActionValidationDiagnostic> diagnostics;
}

SourceValidationResult validateActionSource(Object? source) {
  final diagnostics = <ActionValidationDiagnostic>[];
  if (source is! ActionSource && source is! Map) {
    return const SourceValidationResult(
      valid: false,
      diagnostics: [
        ActionValidationDiagnostic(
          code: 'ACTION_SOURCE_INVALID',
          message: 'ActionSource must be a plain object.',
        ),
      ],
    );
  }
  final record = source is ActionSource
      ? source.toJson()
      : Map<String, dynamic>.from(source as Map);
  final type = record['type'];
  if (type is! String || !isActionSourceType(type)) {
    diagnostics.add(
      ActionValidationDiagnostic(
        code: 'ACTION_SOURCE_INVALID',
        message:
            "Unknown action source type '${type.toString()}'. Expected one of: local, handler, url, model.",
        fieldPath: 'source.type',
      ),
    );
    return SourceValidationResult(valid: false, diagnostics: diagnostics);
  }
  switch (type) {
    case 'local':
      if (record['effects'] is! List) {
        diagnostics.add(
          const ActionValidationDiagnostic(
            code: 'ACTION_SOURCE_INVALID',
            message: "local action source requires an 'effects' array.",
            fieldPath: 'source.effects',
          ),
        );
      }
      break;
    case 'handler':
      if (record['handlerKey'] is! String ||
          (record['handlerKey'] as String).isEmpty) {
        diagnostics.add(
          const ActionValidationDiagnostic(
            code: 'ACTION_SOURCE_INVALID',
            message: 'handler action source requires a non-empty handlerKey.',
            fieldPath: 'source.handlerKey',
          ),
        );
      }
      break;
    case 'url':
      if (record['url'] is! String || (record['url'] as String).isEmpty) {
        diagnostics.add(
          const ActionValidationDiagnostic(
            code: 'ACTION_SOURCE_INVALID',
            message: 'url action source requires a non-empty url.',
            fieldPath: 'source.url',
          ),
        );
      }
      const validMethods = {'POST', 'PUT', 'PATCH', 'DELETE'};
      if (!validMethods.contains(record['method'])) {
        diagnostics.add(
          ActionValidationDiagnostic(
            code: 'ACTION_SOURCE_INVALID',
            message:
                "url action source method must be one of POST|PUT|PATCH|DELETE, got '${record['method'].toString()}'.",
            fieldPath: 'source.method',
          ),
        );
      }
      break;
    case 'model':
      if (record['model'] is! String || (record['model'] as String).isEmpty) {
        diagnostics.add(
          const ActionValidationDiagnostic(
            code: 'ACTION_SOURCE_INVALID',
            message: 'model action source requires a non-empty model name.',
            fieldPath: 'source.model',
          ),
        );
      }
      const validOps = {
        'create',
        'update',
        'delete',
        'upsert',
        'restore',
        'custom',
      };
      if (!validOps.contains(record['operation'])) {
        diagnostics.add(
          ActionValidationDiagnostic(
            code: 'ACTION_SOURCE_INVALID',
            message:
                "model action source operation must be one of create|update|delete|upsert|restore|custom, got '${record['operation'].toString()}'.",
            fieldPath: 'source.operation',
          ),
        );
      }
      if (record['operation'] == 'custom' &&
          (record['customOperation'] is! String ||
              (record['customOperation'] as String).isEmpty)) {
        diagnostics.add(
          const ActionValidationDiagnostic(
            code: 'ACTION_SOURCE_INVALID',
            message:
                "model action source with operation 'custom' requires a non-empty customOperation.",
            fieldPath: 'source.customOperation',
          ),
        );
      }
      break;
  }
  return SourceValidationResult(
    valid: diagnostics.isEmpty,
    diagnostics: diagnostics,
  );
}

List<ActionValidationDiagnostic> validateRuntimeContext(
  ActionSource source,
  ActionRuntimeContext? ctx,
  ActionAdapterRegistry adapterRegistry,
  CustomActionRegistry customRegistry,
) {
  final diags = <ActionValidationDiagnostic>[];
  if (ctx == null) {
    return const [
      ActionValidationDiagnostic(
        code: 'ACTION_SOURCE_INVALID',
        message: 'Runtime context is missing.',
      ),
    ];
  }
  switch (source) {
    case LocalActionSource():
      break;
    case HandlerActionSource(:final handlerKey):
      if (!customRegistry.has(handlerKey)) {
        diags.add(
          ActionValidationDiagnostic(
            code: 'ACTION_ADAPTER_MISSING',
            message: "No handler registered for handlerKey '$handlerKey'.",
            fieldPath: 'source.handlerKey',
          ),
        );
      }
      break;
    case UrlActionSource():
      if (!adapterRegistry.has('url')) {
        diags.add(
          const ActionValidationDiagnostic(
            code: 'ACTION_ADAPTER_MISSING',
            message: "No adapter registered for url actions (key 'url').",
            fieldPath: 'adapters.url',
          ),
        );
      }
      break;
    case ModelActionSource(:final adapter):
      final key = adapter ?? 'model';
      if (!adapterRegistry.has(key)) {
        diags.add(
          ActionValidationDiagnostic(
            code: 'ACTION_ADAPTER_MISSING',
            message: "No adapter registered for model actions (key '$key').",
            fieldPath: 'adapters.$key',
          ),
        );
      }
      break;
  }
  return diags;
}

List<ActionValidationDiagnostic> checkUrlPolicy(
  UrlActionSource source,
  UrlPolicy? policy,
) {
  if (policy == null) return const [];
  if (policy.isAllowed(source.url, source.method)) return const [];
  return [
    ActionValidationDiagnostic(
      code: 'ACTION_URL_NOT_ALLOWED',
      message:
          "URL '${source.url}' (${source.method}) is not allowed by the url policy.",
      fieldPath: 'source.url',
    ),
  ];
}
