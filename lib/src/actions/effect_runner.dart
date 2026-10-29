/// Deterministic action effect runner for ADR-018 parity.
library bitcode.ui_schema.actions.effect_runner;

import 'effect.dart';
import 'runtime_context.dart'
    show EffectSink, I18nAdapter, NavigationAdapter, ToastAdapter;
import 'validate.dart' show ActionValidationDiagnostic;

List<ActionValidationDiagnostic> applyEffects(
  List<ActionEffect> effects,
  EffectSink sink,
  ActionEffectAdapters adapters,
) {
  final diagnostics = <ActionValidationDiagnostic>[];
  if (effects.isEmpty) return diagnostics;
  final indexed = <_IndexedEffect>[
    for (var i = 0; i < effects.length; i++) _IndexedEffect(effects[i], i),
  ];
  indexed.sort((a, b) {
    final tierCompare = effectTier(
      a.effect.type,
    ).compareTo(effectTier(b.effect.type));
    if (tierCompare != 0) return tierCompare;
    return a.originalIndex.compareTo(b.originalIndex);
  });
  for (final item in indexed) {
    final diagnostic = _applyOne(
      item.effect,
      sink,
      adapters,
      item.originalIndex,
    );
    if (diagnostic != null) diagnostics.add(diagnostic);
  }
  return diagnostics;
}

class ActionEffectAdapters {
  const ActionEffectAdapters({this.navigation, this.toast, this.i18n});

  final NavigationAdapter? navigation;
  final ToastAdapter? toast;
  final I18nAdapter? i18n;
}

class _IndexedEffect {
  const _IndexedEffect(this.effect, this.originalIndex);

  final ActionEffect effect;
  final int originalIndex;
}

ActionValidationDiagnostic? _applyOne(
  ActionEffect effect,
  EffectSink sink,
  ActionEffectAdapters adapters,
  int index,
) {
  switch (effect) {
    case SetValueEffect(:final path, :final value):
      sink.setValue(path, value);
      return null;
    case SetMetaEffect(:final path, :final meta):
      sink.setMeta(path, meta);
      return null;
    case SetErrorEffect(:final path, :final error):
      sink.setError(path, error);
      return null;
    case RefreshDataSourceEffect(:final key):
      sink.refreshDataSource(key);
      return null;
    case InvalidateKeyEffect(:final key):
      sink.invalidateKey(key);
      return null;
    case ToastEffect():
      if (adapters.toast == null) {
        return ActionValidationDiagnostic(
          code: 'ACTION_EFFECT_ADAPTER_MISSING',
          message:
              "Effect 'toast' at index $index requires a toast adapter, which is not registered.",
          fieldPath: 'effects[$index].type',
        );
      }
      adapters.toast!.show(
        effect.level,
        _resolveToastMessage(effect, adapters.i18n),
      );
      return null;
    case NavigateEffect(:final to, :final replace, :final params):
      if (adapters.navigation == null) {
        return ActionValidationDiagnostic(
          code: 'ACTION_EFFECT_ADAPTER_MISSING',
          message:
              "Effect 'navigate' at index $index requires a navigation adapter, which is not registered.",
          fieldPath: 'effects[$index].type',
        );
      }
      adapters.navigation!.navigate(to, replace: replace, params: params);
      return null;
    case CloseOverlayEffect(:final overlayId):
      sink.closeOverlay(overlayId);
      return null;
    case ResetFormEffect(:final formId, :final scope):
      sink.resetForm(formId, scope);
      return null;
    case EmitEffect(:final event, :final payload):
      sink.emit(event, payload);
      return null;
  }
}

String _resolveToastMessage(ToastEffect effect, I18nAdapter? i18n) {
  if (effect.messageKey != null && i18n != null) {
    return i18n.t(effect.messageKey!, effect.fallbackMessage);
  }
  return effect.fallbackMessage;
}
