/// Stable action diagnostic codes for ADR-018 action runtime parity.
library bitcode.ui_schema.actions.diagnostic_codes;

typedef ActionDiagnosticCode = String;

const String actionSourceInvalid = 'ACTION_SOURCE_INVALID';
const String actionAdapterMissing = 'ACTION_ADAPTER_MISSING';
const String actionAdapterThrew = 'ACTION_ADAPTER_THREW';
const String actionUrlNotAllowed = 'ACTION_URL_NOT_ALLOWED';
const String actionEffectAdapterMissing = 'ACTION_EFFECT_ADAPTER_MISSING';
const String actionAborted = 'ACTION_ABORTED';
const String actionTimeout = 'ACTION_TIMEOUT';
const String actionResultMalformed = 'ACTION_RESULT_MALFORMED';
const String actionDuplicateActionId = 'ACTION_DUPLICATE_ACTION_ID';

const Set<String> actionDiagnosticCodes = {
  actionSourceInvalid,
  actionAdapterMissing,
  actionAdapterThrew,
  actionUrlNotAllowed,
  actionEffectAdapterMissing,
  actionAborted,
  actionTimeout,
  actionResultMalformed,
  actionDuplicateActionId,
};

bool isActionDiagnosticCode(String code) =>
    actionDiagnosticCodes.contains(code);
