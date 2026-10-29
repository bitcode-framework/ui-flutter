/// Declarative action effects for ADR-018 action runtime parity.
library bitcode.ui_schema.actions.effect;

import '../expressions/ast.dart' show PortableExpression;
import 'result.dart' show ActionError;

const Set<String> actionEffectKinds = {
  'setValue',
  'setMeta',
  'setError',
  'refreshDataSource',
  'invalidateKey',
  'toast',
  'navigate',
  'closeOverlay',
  'resetForm',
  'emit',
};

bool isActionEffectKind(String kind) => actionEffectKinds.contains(kind);

sealed class ActionEffect {
  const ActionEffect();

  String get type;
  Map<String, dynamic> toJson();

  static ActionEffect fromJson(Map<String, dynamic> json) {
    final rawType = json['type'];
    if (rawType is! String) {
      throw const FormatException('ActionEffect requires a string type.');
    }
    switch (rawType) {
      case 'setValue':
        final path = json['path'];
        if (path is! String) {
          throw const FormatException('setValue.path must be a string.');
        }
        return SetValueEffect(path: path, value: json['value']);
      case 'setMeta':
        final path = json['path'];
        if (path is! String) {
          throw const FormatException('setMeta.path must be a string.');
        }
        return SetMetaEffect(
          path: path,
          meta: Map<String, dynamic>.from(json['meta'] as Map? ?? const {}),
        );
      case 'setError':
        final path = json['path'];
        if (path is! String) {
          throw const FormatException('setError.path must be a string.');
        }
        return SetErrorEffect(path: path, error: json['error']);
      case 'refreshDataSource':
        final key = json['key'];
        if (key is! String) {
          throw const FormatException(
            'refreshDataSource.key must be a string.',
          );
        }
        return RefreshDataSourceEffect(key: key);
      case 'invalidateKey':
        final key = json['key'];
        if (key is! String) {
          throw const FormatException('invalidateKey.key must be a string.');
        }
        return InvalidateKeyEffect(key: key);
      case 'toast':
        final level = json['level'];
        final fallbackMessage = json['fallbackMessage'];
        if (level is! String || fallbackMessage is! String) {
          throw const FormatException(
            'toast requires level and fallbackMessage.',
          );
        }
        return ToastEffect(
          level: level,
          fallbackMessage: fallbackMessage,
          messageKey: json['messageKey'] as String?,
        );
      case 'navigate':
        final to = json['to'];
        if (to is! String) {
          throw const FormatException('navigate.to must be a string.');
        }
        return NavigateEffect(
          to: to,
          replace: json['replace'] as bool?,
          params: Map<String, dynamic>.from(json['params'] as Map? ?? const {}),
        );
      case 'closeOverlay':
        return CloseOverlayEffect(overlayId: json['overlayId'] as String?);
      case 'resetForm':
        return ResetFormEffect(
          formId: json['formId'] as String?,
          scope: json['scope'] as String?,
        );
      case 'emit':
        final event = json['event'];
        if (event is! String) {
          throw const FormatException('emit.event must be a string.');
        }
        return EmitEffect(event: event, payload: json['payload']);
      default:
        throw FormatException("Unknown action effect type '$rawType'.");
    }
  }
}

final class SetValueEffect extends ActionEffect {
  const SetValueEffect({required this.path, this.value});

  final String path;
  final Object? value;

  @override
  String get type => 'setValue';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'path': path,
    'value': value is PortableExpression
        ? (value as PortableExpression).toJson()
        : value,
  };
}

final class SetMetaEffect extends ActionEffect {
  const SetMetaEffect({required this.path, required this.meta});

  final String path;
  final Map<String, dynamic> meta;

  @override
  String get type => 'setMeta';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'path': path, 'meta': meta};
}

final class SetErrorEffect extends ActionEffect {
  const SetErrorEffect({required this.path, required this.error});

  final String path;
  final Object? error;

  @override
  String get type => 'setError';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'path': path,
    'error': error is ActionError ? (error as ActionError).toJson() : error,
  };
}

final class RefreshDataSourceEffect extends ActionEffect {
  const RefreshDataSourceEffect({required this.key});

  final String key;

  @override
  String get type => 'refreshDataSource';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'key': key};
}

final class InvalidateKeyEffect extends ActionEffect {
  const InvalidateKeyEffect({required this.key});

  final String key;

  @override
  String get type => 'invalidateKey';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'key': key};
}

final class ToastEffect extends ActionEffect {
  const ToastEffect({
    required this.level,
    required this.fallbackMessage,
    this.messageKey,
  });

  final String level;
  final String fallbackMessage;
  final String? messageKey;

  @override
  String get type => 'toast';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'level': level,
    if (messageKey != null) 'messageKey': messageKey,
    'fallbackMessage': fallbackMessage,
  };
}

final class NavigateEffect extends ActionEffect {
  const NavigateEffect({
    required this.to,
    this.replace,
    this.params = const {},
  });

  final String to;
  final bool? replace;
  final Map<String, dynamic> params;

  @override
  String get type => 'navigate';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'to': to,
    if (replace != null) 'replace': replace,
    if (params.isNotEmpty) 'params': params,
  };
}

final class CloseOverlayEffect extends ActionEffect {
  const CloseOverlayEffect({this.overlayId});

  final String? overlayId;

  @override
  String get type => 'closeOverlay';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (overlayId != null) 'overlayId': overlayId,
  };
}

final class ResetFormEffect extends ActionEffect {
  const ResetFormEffect({this.formId, this.scope});

  final String? formId;
  final String? scope;

  @override
  String get type => 'resetForm';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (formId != null) 'formId': formId,
    if (scope != null) 'scope': scope,
  };
}

final class EmitEffect extends ActionEffect {
  const EmitEffect({required this.event, this.payload});

  final String event;
  final Object? payload;

  @override
  String get type => 'emit';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event': event,
    if (payload != null) 'payload': payload,
  };
}

const List<List<String>> effectTierOrder = [
  ['setValue', 'setMeta', 'setError'],
  ['invalidateKey', 'refreshDataSource'],
  ['toast', 'closeOverlay', 'resetForm'],
  ['navigate'],
  ['emit'],
];

int effectTier(String kind) {
  for (var i = 0; i < effectTierOrder.length; i++) {
    if (effectTierOrder[i].contains(kind)) return i;
  }
  return effectTierOrder.length - 1;
}
