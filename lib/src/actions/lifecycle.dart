/// Action lifecycle events for ADR-018 action runtime parity.
library bitcode.ui_schema.actions.lifecycle;

import '../core/types.dart' show BcChangeMeta;
import 'result.dart' show ActionError, ActionResult;
import 'source.dart' show ActionSource;

typedef ActionPhase = String;

const List<String> actionPhases = [
  'start',
  'success',
  'error',
  'validation-error',
  'settled',
];

class ActionLifecycleEvent {
  const ActionLifecycleEvent({
    required this.actionId,
    required this.source,
    required this.phase,
    required this.meta,
    required this.timestamp,
    this.payload,
    this.result,
    this.error,
  });

  final String actionId;
  final ActionSource source;
  final ActionPhase phase;
  final Object? payload;
  final ActionResult<Object?>? result;
  final ActionError? error;
  final BcChangeMeta meta;
  final int timestamp;
}

typedef ActionLifecycleEmitter = void Function(ActionLifecycleEvent event);

ActionLifecycleEvent buildLifecycleEvent(
  String actionId,
  ActionSource source,
  ActionPhase phase,
  BcChangeMeta meta, {
  Object? payload,
  ActionResult<Object?>? result,
  ActionError? error,
  int? timestamp,
}) => ActionLifecycleEvent(
  actionId: actionId,
  source: source,
  phase: phase,
  meta: meta,
  timestamp: timestamp ?? DateTime.now().millisecondsSinceEpoch,
  payload: payload,
  result: result,
  error: error,
);
