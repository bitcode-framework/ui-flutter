/// ActionSource union for ADR-018 action runtime parity.
library bitcode.ui_schema.actions.source;

import '../expressions/ast.dart' show PortableExpression;
import 'effect.dart' show ActionEffect;

const Set<String> actionSourceTypes = {'local', 'handler', 'url', 'model'};

bool isActionSourceType(String type) => actionSourceTypes.contains(type);

sealed class ActionSource {
  const ActionSource();

  String get type;
  Map<String, dynamic> toJson();

  static ActionSource fromJson(Map<String, dynamic> json) {
    final rawType = json['type'];
    if (rawType is! String) {
      throw const FormatException('ActionSource requires a string type.');
    }
    switch (rawType) {
      case 'local':
        final rawEffects = json['effects'];
        final effects = rawEffects is List
            ? rawEffects
                  .map(
                    (e) => ActionEffect.fromJson(
                      Map<String, dynamic>.from(e as Map),
                    ),
                  )
                  .toList()
            : <ActionEffect>[];
        return LocalActionSource(effects: effects);
      case 'handler':
        final handlerKey = json['handlerKey'];
        if (handlerKey is! String) {
          throw const FormatException('handlerKey must be a string.');
        }
        return HandlerActionSource(handlerKey: handlerKey);
      case 'url':
        final method = json['method'];
        final url = json['url'];
        if (method is! String || url is! String) {
          throw const FormatException('url action requires method and url.');
        }
        return UrlActionSource(
          method: method,
          url: url,
          headers: Map<String, String>.from(
            json['headers'] as Map? ?? const {},
          ),
          body: _decodeAstOrObject(json['body']),
          idempotencyKey: json['idempotencyKey'] as String?,
        );
      case 'model':
        final model = json['model'];
        final operation = json['operation'];
        if (model is! String || operation is! String) {
          throw const FormatException(
            'model action requires model and operation.',
          );
        }
        return ModelActionSource(
          model: model,
          operation: operation,
          id: _decodeAstOrObject(json['id']),
          payload: _decodeAstOrObject(json['payload']),
          adapter: json['adapter'] as String?,
          customOperation: json['customOperation'] as String?,
        );
      default:
        throw FormatException("Unknown action source type '$rawType'.");
    }
  }
}

final class LocalActionSource extends ActionSource {
  const LocalActionSource({required this.effects});

  final List<ActionEffect> effects;

  @override
  String get type => 'local';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'effects': effects.map((e) => e.toJson()).toList(),
  };
}

final class HandlerActionSource extends ActionSource {
  const HandlerActionSource({required this.handlerKey});

  final String handlerKey;

  @override
  String get type => 'handler';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'handlerKey': handlerKey};
}

final class UrlActionSource extends ActionSource {
  const UrlActionSource({
    required this.method,
    required this.url,
    this.headers = const {},
    this.body,
    this.idempotencyKey,
  });

  final String method;
  final String url;
  final Map<String, String> headers;
  final Object? body;
  final String? idempotencyKey;

  @override
  String get type => 'url';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'method': method,
    'url': url,
    if (headers.isNotEmpty) 'headers': headers,
    if (body != null) 'body': _encodeAstOrObject(body),
    if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
  };
}

final class ModelActionSource extends ActionSource {
  const ModelActionSource({
    required this.model,
    required this.operation,
    this.id,
    this.payload,
    this.adapter,
    this.customOperation,
  });

  final String model;
  final String operation;
  final Object? id;
  final Object? payload;
  final String? adapter;
  final String? customOperation;

  @override
  String get type => 'model';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'model': model,
    'operation': operation,
    if (id != null) 'id': _encodeAstOrObject(id),
    if (payload != null) 'payload': _encodeAstOrObject(payload),
    if (adapter != null) 'adapter': adapter,
    if (customOperation != null) 'customOperation': customOperation,
  };
}

bool isLocalActionSource(ActionSource source) => source is LocalActionSource;
bool isHandlerActionSource(ActionSource source) =>
    source is HandlerActionSource;
bool isUrlActionSource(ActionSource source) => source is UrlActionSource;
bool isModelActionSource(ActionSource source) => source is ModelActionSource;

Object? _decodeAstOrObject(Object? value) {
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    if (map['kind'] is String) return PortableExpression.fromJson(map);
    return map;
  }
  return value;
}

Object? _encodeAstOrObject(Object? value) {
  if (value is PortableExpression) return value.toJson();
  return value;
}
