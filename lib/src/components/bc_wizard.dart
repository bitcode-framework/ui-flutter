library bc_wizard;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Validation strategy for a wizard step.
///
/// Mirrors TS `WizardValidationMode`:
/// - `client`: validate on-device using the step's schema rules (ADR-004).
/// - `server`: POST `{ step, values }` to [BcWizardStep.validationEndpoint].
/// - `both`: run client validation first, then server validation.
enum BcWizardValidationMode { client, server, both }

/// Single wizard step descriptor.
///
/// Mirrors TS `WizardStepSchema` / `BcWizardStep` contract (ADR-005 §2,
/// ADR-014). Supports icon, schema-driven content, per-step validation
/// mode, server validation endpoint, and skippable steps.
class BcWizardStep {
  final String title;
  final String? description;
  final bool blocking;

  /// Icon name/identifier rendered in the step indicator.
  /// When null, a numeric badge (1-based) is shown instead.
  final String? icon;

  /// Form fragment (UiSchema) rendered per step via the consumer-provided
  /// `renderStepContent` callback (ADR-005 §2 compositor). When null,
  /// the step content falls back to `stepContentBuilder` (legacy mode).
  final Map<String, dynamic>? schema;

  /// Validation strategy for this step. Default: [BcWizardValidationMode.client].
  final BcWizardValidationMode validationMode;

  /// Endpoint for server-side validation (when mode is server/both).
  /// POSTs `{ step, values }` and expects `{ ok, errors }`.
  final String? validationEndpoint;

  /// When true, the step can be skipped without validation.
  final bool skippable;

  const BcWizardStep({
    required this.title,
    this.description,
    this.blocking = false,
    this.icon,
    this.schema,
    this.validationMode = BcWizardValidationMode.client,
    this.validationEndpoint,
    this.skippable = false,
  });

  /// Create a step from a JSON map (for schema-driven wizard definitions).
  factory BcWizardStep.fromJson(Map<String, dynamic> json) {
    return BcWizardStep(
      title: json['title'] as String,
      description: json['description'] as String?,
      blocking: (json['blocking'] as bool?) ?? false,
      icon: json['icon'] as String?,
      schema: json['schema'] as Map<String, dynamic>?,
      validationMode: BcWizardValidationMode.values.firstWhere(
        (m) => m.name == (json['validationMode'] as String? ?? 'client'),
        orElse: () => BcWizardValidationMode.client,
      ),
      validationEndpoint: json['validationEndpoint'] as String?,
      skippable: (json['skippable'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        if (description != null) 'description': description,
        if (blocking) 'blocking': blocking,
        if (icon != null) 'icon': icon,
        if (schema != null) 'schema': schema,
        'validationMode': validationMode.name,
        if (validationEndpoint != null) 'validationEndpoint': validationEndpoint,
        if (skippable) 'skippable': skippable,
      };
}

/// Controller returned by [BcWizard.show] for programmatic step control.
///
/// [setStep] clamps the target index to `[0, steps.length - 1]` and emits
/// [onStepChange] through the original callback. When the per-step
/// [BcWizard.canAdvance] predicate returns `false` for an advance attempt,
/// the call is a no-op.
class BcWizardController {
  final int Function() _getCurrentStep;
  final void Function(int, BcChangeMeta) _doSetStep;
  final int _stepCount;
  final bool Function(int) _canAdvance;

  BcWizardController._(
    int Function() getCurrentStep,
    void Function(int, BcChangeMeta) doSetStep,
    bool Function(int) canAdvance,
    int stepCount,
  )  : _getCurrentStep = getCurrentStep,
        _doSetStep = doSetStep,
        _stepCount = stepCount,
        _canAdvance = canAdvance;
  int get currentStep => _getCurrentStep();

  void setStep(int target, BcChangeMeta meta) {
    final current = _getCurrentStep();
    if (target > current && !_canAdvance(current)) {
      return;
    }
    final clamped = _stepCount <= 0
        ? 0
        : target.clamp(0, _stepCount - 1);
    if (clamped == current) {
      return;
    }
    _doSetStep(clamped, meta);
  }

  void next(BcChangeMeta meta) => setStep(_getCurrentStep() + 1, meta);

  void previous(BcChangeMeta meta) => setStep(_getCurrentStep() - 1, meta);
}

/// Multi-step modal wizard with stepper.
///
/// Mirrors the TS `BcWizardContract`: a modal overlay rendering a stepper
/// (one entry per step) plus the current step's content area. Navigation
/// controls (Previous/Next/Finish/Cancel) drive step transitions.
///
/// The per-step [canAdvance] predicate gates forward movement: when it
/// returns `false` for the current step, the Next control is disabled and
/// a programmatic [BcWizardController.setStep] targeting a higher index is
/// a no-op. [BcWizardController.setStep] always clamps to `[0,
/// steps.length - 1]`, so `setStep(-1)` resolves to step 0 and
/// `setStep(steps.length)` resolves to the last index without throwing a
/// `RangeError`.
///
/// Any transition (pointer-driven Next/Previous, or programmatic via the
/// controller) emits [onStepChange] carrying the destination step index and
/// a [BcChangeMeta] whose source distinguishes the origin. The Finish
/// control is enabled only on the last step; activating it invokes
/// [onFinish] and dismisses the wizard. Cancel/Close disposes all
/// step-local controllers.
///
/// Controlled mode: the parent provides [step]; internal state is not
/// self-mutated on Next/Previous until the parent updates the prop.
/// Uncontrolled mode: [step] is null and [defaultStep] seeds the initial
/// state; Next/Previous update internally.
///
/// Platform-aware: renders a `CupertinoAlertDialog`-style layout on
/// iOS/macOS, `AlertDialog`-style elsewhere.
class BcWizard {
  BcWizard._();

  static BcWizardController show({
    required BuildContext context,
    required List<BcWizardStep> steps,
    int? step,
    int defaultStep = 0,
    bool Function(int)? canAdvance,
    String? title,
    String nextLabel = 'Next',
    String prevLabel = 'Previous',
    String finishLabel = 'Finish',
    String cancelLabel = 'Cancel',
    void Function(int index, BcChangeMeta meta)? onStepChange,

    /// Called when the wizard finishes. Receives the merged values from all
    /// steps (ADR-005 §2 — schema-driven content).
    void Function(Map<String, dynamic> values, BcChangeMeta meta)? onFinish,

    /// Legacy finish callback (no values). Used when [onFinish] is null.
    @Deprecated('Use onFinish with values parameter') void Function(BcChangeMeta meta)? onFinishLegacy,
    void Function(BcChangeMeta meta)? onCancel,

    /// Merged values across all steps (controlled mode). When provided,
    /// the wizard uses these instead of internal state.
    Map<String, dynamic>? values,

    /// Called when any step's values change.
    void Function(Map<String, dynamic> values)? onValuesChange,

    /// Optional step content renderer. When a step has `schema`, this
    /// callback is invoked to render the form fragment (ADR-005 §2
    /// compositor pattern — equivalent to the web `renderStepContent` prop).
    List<Widget> Function(int index, BcWizardStep step, Map<String, dynamic> values)? stepContentBuilder,

    /// Legacy step content builder (no values). Used when [stepContentBuilder]
    /// is null.
    @Deprecated('Use stepContentBuilder with values') List<Widget> Function(int index)? stepContentBuilderLegacy,
  }) {
    final gate = canAdvance ?? (_) => true;

    final route = _BcWizardRoute(
      context: context,
      steps: steps,
      step: step,
      defaultStep: defaultStep,
      canAdvance: gate,
      title: title,
      nextLabel: nextLabel,
      prevLabel: prevLabel,
      finishLabel: finishLabel,
      cancelLabel: cancelLabel,
      onStepChange: onStepChange,
      onFinish: onFinish,
      onFinishLegacy: onFinishLegacy,
      onCancel: onCancel,
      values: values,
      onValuesChange: onValuesChange,
      stepContentBuilder: stepContentBuilder,
      stepContentBuilderLegacy: stepContentBuilderLegacy,
    );

    Navigator.of(context, rootNavigator: true).push<dynamic>(route);

    return BcWizardController._(
      () => route.currentStepNotifier.value,
      (target, meta) => route.programmaticSetStep(target, meta),
      gate,
      steps.length,
    );
  }
}

class _BcWizardRoute extends PopupRoute<dynamic> {
  final BuildContext context;
  final List<BcWizardStep> steps;
  final int? step;
  final int defaultStep;
  final bool Function(int) canAdvance;
  final String? title;
  final String nextLabel;
  final String prevLabel;
  final String finishLabel;
  final String cancelLabel;
  final void Function(int index, BcChangeMeta meta)? onStepChange;

  /// Called when wizard finishes. Receives merged values from all steps.
  final void Function(Map<String, dynamic> values, BcChangeMeta meta)? onFinish;

  /// Legacy finish callback (no values). Used when [onFinish] is null.
  final void Function(BcChangeMeta meta)? onFinishLegacy;
  final void Function(BcChangeMeta meta)? onCancel;

  /// Merged values across all steps (controlled mode).
  final Map<String, dynamic>? values;

  /// Called when any step's values change.
  final void Function(Map<String, dynamic> values)? onValuesChange;

  /// Step content renderer with values (ADR-005 §2 compositor).
  final List<Widget> Function(int index, BcWizardStep step, Map<String, dynamic> values)? stepContentBuilder;

  /// Legacy step content builder (no values).
  final List<Widget> Function(int index)? stepContentBuilderLegacy;

  final ValueNotifier<int> currentStepNotifier;
  void Function(int target, BcChangeMeta meta)? _programmaticSetStepHandler;

  _BcWizardRoute({
    required this.context,
    required this.steps,
    required this.step,
    required this.defaultStep,
    required this.canAdvance,
    required this.title,
    required this.nextLabel,
    required this.prevLabel,
    required this.finishLabel,
    required this.cancelLabel,
    required this.onStepChange,
    required this.onFinish,
    this.onFinishLegacy,
    required this.onCancel,
    this.values,
    this.onValuesChange,
    this.stepContentBuilder,
    this.stepContentBuilderLegacy,
  }) : currentStepNotifier = ValueNotifier<int>(
          steps.isEmpty
              ? 0
              : defaultStep.clamp(0, steps.length - 1),
        );

  void registerProgrammaticSetStepHandler(
      void Function(int, BcChangeMeta) handler) {
    _programmaticSetStepHandler = handler;
  }

  void programmaticSetStep(int target, BcChangeMeta meta) {
    _programmaticSetStepHandler?.call(target, meta);
  }

  @override
  Color? get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _BcWizardPage(route: this);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  void dismiss([dynamic result]) {
    if (isCurrent) {
      Navigator.of(context).pop(result);
    }
  }
}

class _BcWizardPage extends StatefulWidget {
  final _BcWizardRoute route;

  const _BcWizardPage({required this.route});

  @override
  State<_BcWizardPage> createState() => _BcWizardPageState();
}

class _BcWizardPageState extends State<_BcWizardPage> {
  late int _internalStep;

  /// Per-step values collected from step content builders (uncontrolled mode).
  Map<String, dynamic> _stepValues = {};

  /// Whether async server validation is in-flight.
  bool _validating = false;

  /// Per-step validation errors (current step). field name → error message.
  Map<String, String> _stepErrors = {};

  /// Merged values: controlled `widget.route.values` takes priority,
  /// otherwise falls back to internal `_stepValues`.
  Map<String, dynamic> get _mergedValues =>
      widget.route.values ?? _stepValues;

  int get currentStep => _internalStep;

  @override
  void initState() {
    super.initState();
    final seed = widget.route.step ?? widget.route.defaultStep;
    if (widget.route.steps.isNotEmpty) {
      _internalStep = seed.clamp(0, widget.route.steps.length - 1);
    } else {
      _internalStep = 0;
    }
    widget.route.currentStepNotifier.value = currentStep;
    widget.route.registerProgrammaticSetStepHandler(programmaticSetStep);
  }

  @override
  void didUpdateWidget(covariant _BcWizardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _notifyState() {
    widget.route.currentStepNotifier.value = currentStep;
  }

  void _transitionTo(int target, BcChangeMeta meta) {
    final clamped = widget.route.steps.isEmpty
        ? 0
        : target.clamp(0, widget.route.steps.length - 1);
    if (clamped == currentStep) return;

    setState(() {
      _internalStep = clamped;
    });
    widget.route.onStepChange?.call(clamped, meta);
    _notifyState();
  }

  void programmaticSetStep(int target, BcChangeMeta meta) {
    final current = currentStep;
    if (target > current && !widget.route.canAdvance(current)) {
      return;
    }
    _transitionTo(target, meta);
  }

  Future<void> _handleNext() async {
    final valid = await _validateCurrentStep();
    if (!valid) return;
    _transitionTo(
      currentStep + 1,
      const BcChangeMeta(
        reason: BcChangeReason.increment,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _handlePrev() {
    _transitionTo(
      currentStep - 1,
      const BcChangeMeta(
        reason: BcChangeReason.decrement,
        source: BcEventSource.pointer,
      ),
    );
  }

  Future<void> _handleFinish() async {
    final valid = await _validateCurrentStep();
    if (!valid) return;
    const meta = BcChangeMeta(
      reason: BcChangeReason.submit,
      source: BcEventSource.pointer,
    );
    if (widget.route.onFinish != null) {
      widget.route.onFinish!(_mergedValues, meta);
    } else {
      // ignore: deprecated_member_use_from_same_package
      widget.route.onFinishLegacy?.call(meta);
    }
    widget.route.dismiss(true);
  }

  void _handleCancel() {
    widget.route.onCancel?.call(
      const BcChangeMeta(
        reason: BcChangeReason.cancel,
        source: BcEventSource.pointer,
      ),
    );
    widget.route.dismiss(false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Merge incoming values into `_stepValues`, notify controlled-mode
  /// listener, and trigger rebuild. Mirrors the web `onStepValuesChange`.
  ///
  /// Exposed as a state API for controlled-mode consumers whose form widgets
  /// report changes. The `stepContentBuilder` signature (ADR-005 §2) passes
  /// `(index, step, values)` without an onChange callback, so this method is
  /// invoked by consumer form widgets that obtain a reference to this state
  /// (e.g. via `Builder`/`context.findAncestorStateOfType`). It is intentionally
  /// kept to mirror the web `onStepValuesChange` contract.
  // ignore: unused_element
  void _onStepValuesChange(Map<String, dynamic> vals) {
    _stepValues = {..._stepValues, ...vals};
    widget.route.onValuesChange?.call(_mergedValues);
    setState(() {});
  }

  /// Validate a single field value against its validation rules (ADR-004).
  /// Returns the first error message, or null if valid.
  /// Mirrors the web `validateField`.
  String? _validateField(
    Object? value,
    List<Map<String, dynamic>> rules,
    bool required,
  ) {
    if (required && (value == null || value == '')) {
      return 'This field is required';
    }
    if (value == null || value == '') return null;
    for (final rule in rules) {
      final type = rule['type'] as String?;
      final ruleValue = rule['value'];
      final message = rule['message'] as String?;
      if (type == 'min' && value is num && ruleValue is num) {
        if (value < ruleValue) return message ?? 'Minimum is $ruleValue';
      }
      if (type == 'max' && value is num && ruleValue is num) {
        if (value > ruleValue) return message ?? 'Maximum is $ruleValue';
      }
      if (type == 'length' && value is String && ruleValue is num) {
        if (value.length > ruleValue.toInt()) {
          return message ?? 'Max length is $ruleValue';
        }
      }
      if (type == 'pattern' && value is String && ruleValue is String) {
        if (!RegExp(ruleValue).hasMatch(value)) {
          return message ?? 'Invalid format';
        }
      }
      if (type == 'custom' && rule['fn'] is bool Function(Object?)) {
        final fn = rule['fn'] as bool Function(Object?);
        if (!fn(value)) return message ?? 'Invalid value';
      }
    }
    return null;
  }

  /// Client-side validation for the current step (ADR-004 ValidationRule).
  /// Returns a map of field-name → error message, or empty map if valid.
  /// Mirrors the web `validateStepClient`.
  Map<String, String> _validateStepClient(
    Map<String, dynamic>? schema,
    Map<String, dynamic> values,
  ) {
    final errors = <String, String>{};
    if (schema == null) return errors;
    final fields = schema['fields'];
    if (fields is! List) return errors;
    for (final field in fields) {
      if (field is! Map<String, dynamic>) continue;
      final name = field['name'] as String?;
      if (name == null) continue;
      final rulesRaw = field['validation'];
      final rules = rulesRaw is List
          ? rulesRaw
              .whereType<Map<String, dynamic>>()
              .toList(growable: false)
          : <Map<String, dynamic>>[];
      final required = (field['required'] as bool?) ?? false;
      final err = _validateField(values[name], rules, required);
      if (err != null) errors[name] = err;
    }
    return errors;
  }

  /// Server-side validation for the current step (ADR-005 §3).
  /// POSTs `{ step, values }` to [endpoint] and expects `{ ok, errors }`.
  /// Returns a map of field-name → error message, or empty map if valid.
  /// Mirrors the web `validateStepServer`.
  Future<Map<String, String>> _validateStepServer(
    String? endpoint,
    int stepIndex,
    Map<String, dynamic> values,
  ) async {
    if (endpoint == null) return {};
    try {
      final res = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'step': stepIndex, 'values': values}),
      );
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic> &&
          data['ok'] == false &&
          data['errors'] is Map) {
        final errors = <String, String>{};
        for (final entry in (data['errors'] as Map).entries) {
          errors[entry.key.toString()] = entry.value.toString();
        }
        return errors;
      }
      return {};
    } catch (_) {
      return {'_server': 'Server validation failed'};
    }
  }

  /// Run validation for the current step. Returns true if the step is valid
  /// (or skippable). Implements client → server cascade per validationMode.
  /// Mirrors the web `validateCurrentStep`.
  Future<bool> _validateCurrentStep() async {
    if (widget.route.steps.isEmpty) return true;
    final step = widget.route.steps[currentStep];
    if (step.skippable) return true;

    final mode = step.validationMode;
    final values = _mergedValues;

    if (mode == BcWizardValidationMode.client ||
        mode == BcWizardValidationMode.both) {
      final errors = _validateStepClient(step.schema, values);
      if (errors.isNotEmpty) {
        setState(() {
          _stepErrors = errors;
        });
        return false;
      }
    }

    if (mode == BcWizardValidationMode.server ||
        mode == BcWizardValidationMode.both) {
      setState(() {
        _validating = true;
      });
      final errors = await _validateStepServer(
        step.validationEndpoint,
        currentStep,
        values,
      );
      if (mounted) {
        setState(() {
          _validating = false;
        });
      }
      if (errors.isNotEmpty) {
        setState(() {
          _stepErrors = errors;
        });
        return false;
      }
    }

    setState(() {
      _stepErrors = {};
    });
    return true;
  }

  /// Map common icon names (mirroring web `step.icon` identifiers) to
  /// Flutter [IconData]. Returns null when no mapping exists, in which
  /// case the caller falls back to a numeric badge.
  IconData? _iconData(String? iconName) {
    if (iconName == null) return null;
    switch (iconName) {
      case 'person':
      case 'user':
        return Icons.person;
      case 'email':
      case 'mail':
        return Icons.email;
      case 'lock':
      case 'password':
        return Icons.lock;
      case 'phone':
        return Icons.phone;
      case 'home':
        return Icons.home;
      case 'settings':
      case 'gear':
        return Icons.settings;
      case 'check':
      case 'check_circle':
        return Icons.check_circle;
      case 'info':
      case 'info_circle':
        return Icons.info;
      case 'warning':
      case 'warning_circle':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'success':
        return Icons.check_circle;
      case 'calendar':
        return Icons.calendar_today;
      case 'clock':
      case 'time':
        return Icons.access_time;
      case 'search':
        return Icons.search;
      case 'edit':
      case 'pencil':
        return Icons.edit;
      case 'delete':
      case 'trash':
        return Icons.delete;
      case 'add':
      case 'plus':
        return Icons.add;
      case 'remove':
      case 'minus':
        return Icons.remove;
      case 'close':
      case 'x':
        return Icons.close;
      case 'arrow_back':
      case 'back':
        return Icons.arrow_back;
      case 'arrow_forward':
      case 'forward':
        return Icons.arrow_forward;
      case 'upload':
        return Icons.upload;
      case 'download':
        return Icons.download;
      case 'file':
        return Icons.insert_drive_file;
      case 'folder':
        return Icons.folder;
      case 'image':
      case 'photo':
        return Icons.image;
      case 'video':
        return Icons.video_library;
      case 'star':
        return Icons.star;
      case 'heart':
        return Icons.favorite;
      case 'shopping_cart':
      case 'cart':
        return Icons.shopping_cart;
      case 'location':
      case 'map':
        return Icons.location_on;
      case 'key':
        return Icons.key;
      case 'eye':
        return Icons.visibility;
      case 'eye_off':
        return Icons.visibility_off;
      case 'menu':
        return Icons.menu;
      case 'more':
        return Icons.more_horiz;
      case 'help':
      case 'question':
        return Icons.help;
      case 'notifications':
      case 'bell':
        return Icons.notifications;
      case 'cloud':
        return Icons.cloud;
      case 'shield':
        return Icons.shield;
      case 'credit_card':
      case 'card':
        return Icons.credit_card;
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'chart':
        return Icons.bar_chart;
      case 'list':
        return Icons.list;
      case 'grid':
        return Icons.grid_view;
      case 'tag':
        return Icons.tag;
      case 'gift':
        return Icons.card_giftcard;
      case 'flag':
        return Icons.flag;
      case 'book':
        return Icons.book;
      case 'code':
        return Icons.code;
      case 'database':
        return Icons.storage;
      case 'server':
        return Icons.dns;
      case 'wifi':
        return Icons.wifi;
      case 'bluetooth':
        return Icons.bluetooth;
      case 'battery':
        return Icons.battery_full;
      case 'print':
        return Icons.print;
      case 'share':
        return Icons.share;
      case 'link':
        return Icons.link;
      case 'copy':
        return Icons.content_copy;
      case 'cut':
        return Icons.content_cut;
      case 'paste':
        return Icons.content_paste;
      case 'undo':
        return Icons.undo;
      case 'redo':
        return Icons.redo;
      case 'refresh':
      case 'reload':
        return Icons.refresh;
      case 'sync':
        return Icons.sync;
      case 'logout':
      case 'sign_out':
        return Icons.logout;
      case 'login':
      case 'sign_in':
        return Icons.login;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isIOS = platform == TargetPlatform.iOS ||
        platform == TargetPlatform.macOS;
    return isIOS ? _buildCupertino() : _buildMaterial();
  }

  Widget _buildMaterial() {
    final isLast = currentStep == widget.route.steps.length - 1;
    final isFirst = currentStep == 0;
    final canAdvanceNow = widget.route.canAdvance(currentStep);

    return Center(
      child: AlertDialog(
        key: const Key('bc-wizard-dialog'),
        title: widget.route.title != null ? Text(widget.route.title!) : null,
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepper(),
              const Divider(height: 24),
              Flexible(child: _buildContent()),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('bc-wizard-cancel'),
            onPressed: _handleCancel,
            child: Text(widget.route.cancelLabel),
          ),
          if (!isFirst)
            TextButton(
              key: const Key('bc-wizard-prev'),
              onPressed: _handlePrev,
              child: Text(widget.route.prevLabel),
            ),
          if (isLast)
            FilledButton(
              key: const Key('bc-wizard-finish'),
              onPressed: _validating ? null : _handleFinish,
              child: Text(_validating ? 'Validating...' : widget.route.finishLabel),
            )
          else
            FilledButton(
              key: const Key('bc-wizard-next'),
              onPressed: (_validating || !canAdvanceNow) ? null : _handleNext,
              child: Text(_validating ? 'Validating...' : widget.route.nextLabel),
            ),
        ],
      ),
    );
  }

  Widget _buildCupertino() {
    final isLast = currentStep == widget.route.steps.length - 1;
    final isFirst = currentStep == 0;
    final canAdvanceNow = widget.route.canAdvance(currentStep);

    return Center(
      child: CupertinoAlertDialog(
        key: const Key('bc-wizard-dialog'),
        title: widget.route.title != null ? Text(widget.route.title!) : null,
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepper(),
              const SizedBox(height: 12),
              _buildContent(),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            key: const Key('bc-wizard-cancel'),
            onPressed: _handleCancel,
            child: Text(widget.route.cancelLabel),
          ),
          if (!isFirst)
            CupertinoDialogAction(
              key: const Key('bc-wizard-prev'),
              onPressed: _handlePrev,
              child: Text(widget.route.prevLabel),
            ),
          if (isLast)
            CupertinoDialogAction(
              key: const Key('bc-wizard-finish'),
              isDefaultAction: true,
              onPressed: _validating ? null : _handleFinish,
              child: Text(_validating ? 'Validating...' : widget.route.finishLabel),
            )
          else
            CupertinoDialogAction(
              key: const Key('bc-wizard-next'),
              isDefaultAction: true,
              onPressed: (_validating || !canAdvanceNow) ? null : _handleNext,
              child: Text(_validating ? 'Validating...' : widget.route.nextLabel),
            ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      key: const Key('bc-wizard-stepper'),
      child: Row(
        children: [
          for (var i = 0; i < widget.route.steps.length; i++) ...[
            _buildStepNode(i),
            if (i < widget.route.steps.length - 1)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    height: 2,
                    color: i < currentStep
                        ? BcTheme.primary
                        : BcTheme.border,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepNode(int index) {
    final isCurrent = index == currentStep;
    final isCompleted = index < currentStep;
    final step = widget.route.steps[index];

    final circle = Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCurrent
            ? BcTheme.primary
            : isCompleted
                ? BcTheme.primary
                : BcTheme.muted,
        border: isCurrent
            ? Border.all(color: BcTheme.ring, width: 2)
            : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, size: 14, color: BcTheme.primaryForeground)
            : _iconData(step.icon) != null
                ? Icon(
                    _iconData(step.icon),
                    size: 14,
                    color: isCurrent
                        ? BcTheme.primaryForeground
                        : BcTheme.mutedForeground,
                  )
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isCurrent
                          ? BcTheme.primaryForeground
                          : BcTheme.mutedForeground,
                    ),
                  ),
      ),
    );

    return Column(
      key: isCurrent
          ? const Key('bc-wizard-marker-current')
          : ValueKey<String>('bc-wizard-marker-$index'),
      mainAxisSize: MainAxisSize.min,
      children: [
        circle,
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 80),
          child: Text(
            step.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
              color: isCurrent ? BcTheme.foreground : BcTheme.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final step =
        widget.route.steps.isEmpty ? null : widget.route.steps[currentStep];

    final List<Widget> contentChildren;

    // Priority 1: 3-arg stepContentBuilder (index, step, values) — ADR-005 §2.
    if (widget.route.stepContentBuilder != null && step != null) {
      contentChildren = widget.route.stepContentBuilder!(
        currentStep,
        step,
        _mergedValues,
      );
    }
    // Priority 2: legacy 1-arg stepContentBuilder (index only).
    else if (widget.route.stepContentBuilderLegacy != null) {
      contentChildren = widget.route.stepContentBuilderLegacy!(currentStep);
    } else if (step == null) {
      contentChildren = const [];
    }
    // Default: render step title + description.
    else {
      contentChildren = [
        Text(
          step.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: BcTheme.foreground,
          ),
        ),
        if (step.description != null) ...[
          const SizedBox(height: 8),
          Text(
            step.description!,
            style: const TextStyle(
              fontSize: 14,
              color: BcTheme.mutedForeground,
            ),
          ),
        ],
      ];
    }

    // Validation error display (mirrors web BcWizard — ADR-004 ValidationRule).
    // Shows field-name → error-message pairs for the current step.
    final errorChildren = <Widget>[];
    if (_stepErrors.isNotEmpty) {
      errorChildren.add(
        Container(
          key: const Key('bc-wizard-errors'),
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: BcTheme.destructive, width: 1),
            borderRadius: BorderRadius.circular(6),
            color: BcTheme.destructive.withValues(alpha: 0.1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final entry in _stepErrors.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: BcTheme.destructive,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [...contentChildren, ...errorChildren],
    );
  }
}
