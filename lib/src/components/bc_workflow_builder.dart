// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use
library bc_workflow_builder;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:http/http.dart' as http;
import '../theme/bc_theme.dart';

/// Step type identifiers mirroring the TS `BcWorkflowStepType` union.
///
/// All engine step types are supported.
enum BcWorkflowStepType {
  call,
  ifCondition,
  loop,
  switchType,
  script,
  dag,
  validate,
  query,
  create,
  update,
  delete,
  emit,
  http,
  assign,
  log,
  upsert,
  count,
  sum;

  String get id {
    switch (this) {
      case BcWorkflowStepType.call:
        return 'call';
      case BcWorkflowStepType.ifCondition:
        return 'if';
      case BcWorkflowStepType.loop:
        return 'loop';
      case BcWorkflowStepType.switchType:
        return 'switch';
      case BcWorkflowStepType.script:
        return 'script';
      case BcWorkflowStepType.dag:
        return 'dag';
      case BcWorkflowStepType.validate:
        return 'validate';
      case BcWorkflowStepType.query:
        return 'query';
      case BcWorkflowStepType.create:
        return 'create';
      case BcWorkflowStepType.update:
        return 'update';
      case BcWorkflowStepType.delete:
        return 'delete';
      case BcWorkflowStepType.emit:
        return 'emit';
      case BcWorkflowStepType.http:
        return 'http';
      case BcWorkflowStepType.assign:
        return 'assign';
      case BcWorkflowStepType.log:
        return 'log';
      case BcWorkflowStepType.upsert:
        return 'upsert';
      case BcWorkflowStepType.count:
        return 'count';
      case BcWorkflowStepType.sum:
        return 'sum';
    }
  }

  String get label {
    switch (this) {
      case BcWorkflowStepType.call:
        return 'Call';
      case BcWorkflowStepType.ifCondition:
        return 'Condition';
      case BcWorkflowStepType.loop:
        return 'Loop';
      case BcWorkflowStepType.switchType:
        return 'Switch';
      case BcWorkflowStepType.script:
        return 'Script';
      case BcWorkflowStepType.dag:
        return 'DAG';
      case BcWorkflowStepType.validate:
        return 'Validate';
      case BcWorkflowStepType.query:
        return 'Query';
      case BcWorkflowStepType.create:
        return 'Create';
      case BcWorkflowStepType.update:
        return 'Update';
      case BcWorkflowStepType.delete:
        return 'Delete';
      case BcWorkflowStepType.emit:
        return 'Emit';
      case BcWorkflowStepType.http:
        return 'HTTP';
      case BcWorkflowStepType.assign:
        return 'Assign';
      case BcWorkflowStepType.log:
        return 'Log';
      case BcWorkflowStepType.upsert:
        return 'Upsert';
      case BcWorkflowStepType.count:
        return 'Count';
      case BcWorkflowStepType.sum:
        return 'Sum';
    }
  }

  IconData get icon {
    switch (this) {
      case BcWorkflowStepType.call:
        return Icons.call_merge;
      case BcWorkflowStepType.ifCondition:
        return Icons.call_split;
      case BcWorkflowStepType.loop:
        return Icons.loop;
      case BcWorkflowStepType.switchType:
        return Icons.swap_horiz;
      case BcWorkflowStepType.script:
        return Icons.code;
      case BcWorkflowStepType.dag:
        return Icons.account_tree;
      case BcWorkflowStepType.validate:
        return Icons.check_circle_outline;
      case BcWorkflowStepType.query:
        return Icons.search;
      case BcWorkflowStepType.create:
        return Icons.add_circle_outline;
      case BcWorkflowStepType.update:
        return Icons.edit;
      case BcWorkflowStepType.delete:
        return Icons.delete_outline;
      case BcWorkflowStepType.emit:
        return Icons.notifications_active;
      case BcWorkflowStepType.http:
        return Icons.cloud;
      case BcWorkflowStepType.assign:
        return Icons.assignment;
      case BcWorkflowStepType.log:
        return Icons.subject;
      case BcWorkflowStepType.upsert:
        return Icons.sync;
      case BcWorkflowStepType.count:
        return Icons.exposure;
      case BcWorkflowStepType.sum:
        return Icons.functions;
    }
  }

  static BcWorkflowStepType fromString(String s) {
    switch (s) {
      case 'call':
        return BcWorkflowStepType.call;
      case 'if':
        return BcWorkflowStepType.ifCondition;
      case 'loop':
        return BcWorkflowStepType.loop;
      case 'switch':
        return BcWorkflowStepType.switchType;
      case 'script':
        return BcWorkflowStepType.script;
      case 'dag':
        return BcWorkflowStepType.dag;
      case 'validate':
        return BcWorkflowStepType.validate;
      case 'query':
        return BcWorkflowStepType.query;
      case 'create':
        return BcWorkflowStepType.create;
      case 'update':
        return BcWorkflowStepType.update;
      case 'delete':
        return BcWorkflowStepType.delete;
      case 'emit':
        return BcWorkflowStepType.emit;
      case 'http':
        return BcWorkflowStepType.http;
      case 'assign':
        return BcWorkflowStepType.assign;
      case 'log':
        return BcWorkflowStepType.log;
      case 'upsert':
        return BcWorkflowStepType.upsert;
      case 'count':
        return BcWorkflowStepType.count;
      case 'sum':
        return BcWorkflowStepType.sum;
      default:
        return BcWorkflowStepType.query;
    }
  }

  bool get needsModel =>
      this == BcWorkflowStepType.query ||
      this == BcWorkflowStepType.create ||
      this == BcWorkflowStepType.update ||
      this == BcWorkflowStepType.delete ||
      this == BcWorkflowStepType.upsert ||
      this == BcWorkflowStepType.count ||
      this == BcWorkflowStepType.sum;
}

/// A single workflow step on the canvas.
///
/// Mirrors TS `BcWorkflowStep`.
class BcWorkflowStep {
  final String id;
  final String name;
  final String? label;
  final BcWorkflowStepType type;
  final double x;
  final double y;
  final String? model;
  final String? condition;
  final String? field;
  final String? over;
  final String? event;
  final String? process;
  final String? runtime;
  final String? script;
  final String? url;
  final String? method;
  final String? variable;
  final String? value;
  final String? message;
  final String? thenStep;
  final String? elseStep;

  const BcWorkflowStep({
    required this.id,
    required this.name,
    required this.type,
    required this.x,
    required this.y,
    this.label,
    this.model,
    this.condition,
    this.field,
    this.over,
    this.event,
    this.process,
    this.runtime,
    this.script,
    this.url,
    this.method,
    this.variable,
    this.value,
    this.message,
    this.thenStep,
    this.elseStep,
  });

  BcWorkflowStep copyWith({
    String? name,
    String? label,
    BcWorkflowStepType? type,
    double? x,
    double? y,
    String? model,
    String? condition,
    String? field,
    String? over,
    String? event,
    String? process,
    String? runtime,
    String? script,
    String? url,
    String? method,
    String? variable,
    String? value,
    String? message,
    String? thenStep,
    String? elseStep,
  }) {
    return BcWorkflowStep(
      id: id,
      name: name ?? this.name,
      label: label ?? this.label,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      model: model ?? this.model,
      condition: condition ?? this.condition,
      field: field ?? this.field,
      over: over ?? this.over,
      event: event ?? this.event,
      process: process ?? this.process,
      runtime: runtime ?? this.runtime,
      script: script ?? this.script,
      url: url ?? this.url,
      method: method ?? this.method,
      variable: variable ?? this.variable,
      value: value ?? this.value,
      message: message ?? this.message,
      thenStep: thenStep ?? this.thenStep,
      elseStep: elseStep ?? this.elseStep,
    );
  }
}

/// A transition/edge between two steps.
///
/// Mirrors TS `BcWorkflowTransition`.
class BcWorkflowTransition {
  final String id;
  final String from;
  final String to;
  final String? label;
  final String? condition;

  const BcWorkflowTransition({
    required this.id,
    required this.from,
    required this.to,
    this.label,
    this.condition,
  });

  BcWorkflowTransition copyWith({
    String? from,
    String? to,
    String? label,
    String? condition,
  }) {
    return BcWorkflowTransition(
      id: id,
      from: from ?? this.from,
      to: to ?? this.to,
      label: label ?? this.label,
      condition: condition ?? this.condition,
    );
  }
}

/// A validation issue (error or warning) from the engine validate endpoint.
///
/// Mirrors TS `BcValidationIssue`.
class BcWorkflowValidationIssue {
  final String? field;
  final String message;

  const BcWorkflowValidationIssue({this.field, required this.message});
}

/// Validation result from the admin validate endpoint.
///
/// Mirrors TS `BcValidationResult`.
class BcWorkflowValidationResult {
  final bool valid;
  final List<BcWorkflowValidationIssue> errors;
  final List<BcWorkflowValidationIssue> warnings;

  const BcWorkflowValidationResult({
    required this.valid,
    this.errors = const [],
    this.warnings = const [],
  });

  factory BcWorkflowValidationResult.fromJson(Map<String, dynamic> json) {
    return BcWorkflowValidationResult(
      valid: json['valid'] == true,
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) => BcWorkflowValidationIssue(
                    field: e['field'] as String?,
                    message: e['message'] as String? ?? '',
                  ))
              .toList() ??
          [],
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => BcWorkflowValidationIssue(
                    field: e['field'] as String?,
                    message: e['message'] as String? ?? '',
                  ))
              .toList() ??
          [],
    );
  }
}

/// Data source for the workflow builder validation endpoint.
///
/// Mirrors TS `BcWorkflowBuilderDataSource`.
class BcWorkflowBuilderDataSource {
  final String? validateEndpoint;
  final Map<String, String>? headers;

  const BcWorkflowBuilderDataSource({this.validateEndpoint, this.headers});
}

/// The process.json output of the workflow builder.
///
/// Mirrors TS `BcProcessJson`.
class BcProcessJson {
  final String name;
  final String? runtime;
  final List<Map<String, dynamic>>? steps;
  final Map<String, Map<String, dynamic>>? nodes;
  final List<Map<String, dynamic>>? edges;

  const BcProcessJson({
    required this.name,
    this.runtime,
    this.steps,
    this.nodes,
    this.edges,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
    };
    if (runtime != null && runtime!.isNotEmpty) json['runtime'] = runtime;
    if (steps != null) json['steps'] = steps;
    if (nodes != null) json['nodes'] = nodes;
    if (edges != null) json['edges'] = edges;
    return json;
  }

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());
}

/// The active builder tab.
enum BcWorkflowBuilderTab { canvas, json }

/// Visual Workflow Builder widget (ADR-014 Phase 4).
///
/// Mirrors TS `BcWorkflowBuilder.lite.tsx` (ADR-006 Pure/Adapt pattern).
///
/// Features:
/// - Node canvas with drag-drop steps (palette of step types)
/// - Transition arrows between steps (then/else/case)
/// - DAG mode toggle for graph-based workflows
/// - Property panel per step (model, condition, script, url, etc.)
/// - JSON preview tab
/// - Validation via POST /api/v1/admin/processes/validate before save
/// - Platform-aware (ADR-011): iOS uses Cupertino-style controls in the
///   property panel; Android uses Material controls.
class BcWorkflowBuilder extends StatefulWidget {
  final String processName;
  final String runtime;
  final bool dagMode;
  final List<BcWorkflowStep> steps;
  final List<BcWorkflowTransition> transitions;
  final BcWorkflowBuilderDataSource? dataSource;
  final BcWorkflowValidationResult? validation;
  final bool validating;
  final bool saveDisabled;
  final Map<String, String>? i18n;
  final void Function(List<BcWorkflowStep> steps, List<BcWorkflowTransition> transitions)? onChange;
  final void Function(BcProcessJson processJson)? onValidate;
  final void Function(BcWorkflowValidationResult result)? onValidationResult;
  final void Function(BcProcessJson processJson)? onSave;

  const BcWorkflowBuilder({
    super.key,
    this.processName = '',
    this.runtime = '',
    this.dagMode = false,
    this.steps = const [],
    this.transitions = const [],
    this.dataSource,
    this.validation,
    this.validating = false,
    this.saveDisabled = false,
    this.i18n,
    this.onChange,
    this.onValidate,
    this.onValidationResult,
    this.onSave,
  });

  @override
  State<BcWorkflowBuilder> createState() => _BcWorkflowBuilderState();
}

class _BcWorkflowBuilderState extends State<BcWorkflowBuilder> {
  List<BcWorkflowStep> _steps = [];
  List<BcWorkflowTransition> _transitions = [];
  String _selectedStepId = '';
  String _selectedTransitionId = '';
  BcWorkflowBuilderTab _activeTab = BcWorkflowBuilderTab.canvas;
  BcWorkflowValidationResult? _validation;
  bool _validating = false;
  bool _dagMode = false;
  String _connectingFromId = '';
  int _stepCounter = 0;
  int _edgeCounter = 0;

  String t(String key, String fallback) {
    if (widget.i18n != null && widget.i18n!.containsKey(key)) {
      return widget.i18n![key]!;
    }
    return fallback;
  }

  @override
  void initState() {
    super.initState();
    _steps = List.from(widget.steps);
    _transitions = List.from(widget.transitions);
    _dagMode = widget.dagMode;
  }

  List<BcWorkflowStep> get _effectiveSteps =>
      widget.steps.isNotEmpty ? widget.steps : _steps;

  List<BcWorkflowTransition> get _effectiveTransitions =>
      widget.transitions.isNotEmpty ? widget.transitions : _transitions;

  bool get _effectiveDagMode => widget.dagMode || _dagMode;

  BcWorkflowValidationResult? get _effectiveValidation =>
      widget.validation ?? _validation;

  bool get _effectiveValidating => widget.validating || _validating;

  bool get _effectiveSaveDisabled {
    if (widget.saveDisabled) return true;
    final val = _effectiveValidation;
    if (val != null && !val.valid) return true;
    return false;
  }

  void _emitChange(List<BcWorkflowStep> steps, List<BcWorkflowTransition> transitions) {
    setState(() {
      _steps = steps;
      _transitions = transitions;
    });
    widget.onChange?.call(steps, transitions);
  }

  BcWorkflowStep? get _selectedStep {
    if (_selectedStepId.isEmpty) return null;
    for (final s in _effectiveSteps) {
      if (s.id == _selectedStepId) return s;
    }
    return null;
  }

  BcWorkflowTransition? get _selectedTransition {
    if (_selectedTransitionId.isEmpty) return null;
    for (final tr in _effectiveTransitions) {
      if (tr.id == _selectedTransitionId) return tr;
    }
    return null;
  }

  Map<String, dynamic> _buildStepJson(BcWorkflowStep step) {
    final obj = <String, dynamic>{
      'name': step.name,
      'type': step.type.id,
    };
    if (step.label != null && step.label!.isNotEmpty) obj['label'] = step.label;
    if (step.model != null && step.model!.isNotEmpty) obj['model'] = step.model;
    if (step.condition != null && step.condition!.isNotEmpty) obj['condition'] = step.condition;
    if (step.thenStep != null && step.thenStep!.isNotEmpty) obj['then'] = step.thenStep;
    if (step.elseStep != null && step.elseStep!.isNotEmpty) obj['else'] = step.elseStep;
    if (step.over != null && step.over!.isNotEmpty) obj['over'] = step.over;
    if (step.field != null && step.field!.isNotEmpty) obj['field'] = step.field;
    if (step.process != null && step.process!.isNotEmpty) obj['process'] = step.process;
    if (step.runtime != null && step.runtime!.isNotEmpty) obj['runtime'] = step.runtime;
    if (step.script != null && step.script!.isNotEmpty) obj['script'] = step.script;
    if (step.event != null && step.event!.isNotEmpty) obj['event'] = step.event;
    if (step.url != null && step.url!.isNotEmpty) obj['url'] = step.url;
    if (step.method != null && step.method!.isNotEmpty) obj['method'] = step.method;
    if (step.variable != null && step.variable!.isNotEmpty) obj['variable'] = step.variable;
    if (step.value != null && step.value!.isNotEmpty) obj['value'] = step.value;
    if (step.message != null && step.message!.isNotEmpty) obj['message'] = step.message;
    return obj;
  }

  BcProcessJson _buildProcessJson() {
    final name = widget.processName.isNotEmpty
        ? widget.processName
        : 'workflow_process';
    final runtime = widget.runtime.isNotEmpty ? widget.runtime : null;

    if (_effectiveDagMode) {
      final nodesMap = <String, Map<String, dynamic>>{};
      for (final step in _effectiveSteps) {
        nodesMap[step.name] = _buildStepJson(step);
      }
      final edgesList = _effectiveTransitions.map((tr) {
        final edge = <String, dynamic>{
          'from': tr.from,
          'to': tr.to,
        };
        if (tr.condition != null && tr.condition!.isNotEmpty) {
          edge['condition'] = tr.condition;
        }
        return edge;
      }).toList();

      return BcProcessJson(
        name: name,
        runtime: runtime,
        nodes: nodesMap,
        edges: edgesList,
      );
    } else {
      final stepsList = _effectiveSteps.map((s) => _buildStepJson(s)).toList();
      return BcProcessJson(name: name, runtime: runtime, steps: stepsList);
    }
  }

  void _addStep(BcWorkflowStepType type) {
    _stepCounter++;
    final id = 'step_$_stepCounter';
    final name = '${type.id}_$_stepCounter';
    final col = _effectiveSteps.length % 4;
    final row = _effectiveSteps.length ~/ 4;
    final step = BcWorkflowStep(
      id: id,
      name: name,
      label: name[0].toUpperCase() + name.substring(1),
      type: type,
      x: 40.0 + col * 180,
      y: 40.0 + row * 120,
    );
    final next = [..._effectiveSteps, step];
    _emitChange(next, _effectiveTransitions);
    setState(() {
      _selectedStepId = id;
      _selectedTransitionId = '';
    });
  }

  void _removeStep(String id) {
    final next = _effectiveSteps.where((s) => s.id != id).toList();
    final nextTransitions = _effectiveTransitions
        .where((tr) => tr.from != id && tr.to != id)
        .toList();
    _emitChange(next, nextTransitions);
    if (_selectedStepId == id) {
      setState(() {
        _selectedStepId = '';
      });
    }
  }

  void _updateStep(String id, BcWorkflowStep Function(BcWorkflowStep) updater) {
    final next = _effectiveSteps.map((s) {
      return s.id == id ? updater(s) : s;
    }).toList();
    _emitChange(next, _effectiveTransitions);
  }

  void _removeTransition(String id) {
    final next = _effectiveTransitions.where((tr) => tr.id != id).toList();
    _emitChange(_effectiveSteps, next);
    if (_selectedTransitionId == id) {
      setState(() {
        _selectedTransitionId = '';
      });
    }
  }

  void _updateTransition(String id, BcWorkflowTransition Function(BcWorkflowTransition) updater) {
    final next = _effectiveTransitions.map((tr) {
      return tr.id == id ? updater(tr) : tr;
    }).toList();
    _emitChange(_effectiveSteps, next);
  }

  void _selectStep(String id) {
    setState(() {
      _selectedStepId = id;
      _selectedTransitionId = '';
    });
  }

  void _selectTransition(String id) {
    setState(() {
      _selectedTransitionId = id;
      _selectedStepId = '';
    });
  }

  void _handleTransitionTap(
    Offset localPosition,
    List<BcWorkflowTransition> transitions,
    List<BcWorkflowStep> steps,
  ) {
    final stepMap = <String, BcWorkflowStep>{};
    for (final s in steps) {
      stepMap[s.name] = s;
    }
    const threshold = 30.0;
    for (final tr in transitions) {
      final fromStep = stepMap[tr.from];
      final toStep = stepMap[tr.to];
      if (fromStep == null || toStep == null) continue;
      final startX = fromStep.x + 140;
      final startY = fromStep.y + 30;
      final endX = toStep.x;
      final endY = toStep.y + 30;
      final midX = (startX + endX) / 2;
      final t = ((localPosition.dx - startX) / (endX - startX))
          .clamp(0.0, 1.0);
      final bezierY = (1 - t) * (1 - t) * startY +
          2 * (1 - t) * t * ((startY + endY) / 2) +
          t * t * endY;
      final bezierX = (1 - t) * (1 - t) * startX +
          2 * (1 - t) * t * midX +
          t * t * endX;
      final dist = (Offset(bezierX, bezierY) - localPosition).distance;
      if (dist < threshold) {
        _selectTransition(tr.id);
        return;
      }
    }
    _selectTransition('');
  }

  void _startConnection(String fromId) {
    setState(() {
      _connectingFromId = fromId;
    });
  }

  void _completeConnection(String toId) {
    if (_connectingFromId.isEmpty || _connectingFromId == toId) {
      setState(() {
        _connectingFromId = '';
      });
      return;
    }
    final exists = _effectiveTransitions.any(
      (tr) => tr.from == _connectingFromId && tr.to == toId,
    );
    if (!exists) {
      _edgeCounter++;
      final fromStep = _effectiveSteps.firstWhere(
        (s) => s.id == _connectingFromId,
        orElse: () => _effectiveSteps.first,
      );
      final toStep = _effectiveSteps.firstWhere(
        (s) => s.id == toId,
        orElse: () => _effectiveSteps.first,
      );
      final newTransition = BcWorkflowTransition(
        id: 'edge_$_edgeCounter',
        from: fromStep.name,
        to: toStep.name,
      );
      _emitChange(_effectiveSteps, [..._effectiveTransitions, newTransition]);
    }
    setState(() {
      _connectingFromId = '';
    });
  }

  void _toggleDagMode() {
    setState(() {
      _dagMode = !_effectiveDagMode;
    });
  }

  Future<void> _runValidation() async {
    final processJson = _buildProcessJson();
    setState(() {
      _validating = true;
    });

    widget.onValidate?.call(processJson);

    final endpoint = widget.dataSource?.validateEndpoint ??
        '/api/v1/admin/processes/validate';

    try {
      final uri = Uri.parse(endpoint);
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ...?widget.dataSource?.headers,
        },
        body: jsonEncode(processJson.toJson()),
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final result = BcWorkflowValidationResult.fromJson(json);
      setState(() {
        _validation = result;
        _validating = false;
      });
      widget.onValidationResult?.call(result);
    } catch (e) {
      final result = BcWorkflowValidationResult(
        valid: false,
        errors: [
          BcWorkflowValidationIssue(message: 'Validation request failed: $e'),
        ],
      );
      setState(() {
        _validation = result;
        _validating = false;
      });
      widget.onValidationResult?.call(result);
    }
  }

  void _handleSave() {
    if (_effectiveSaveDisabled || _effectiveValidating) return;
    widget.onSave?.call(_buildProcessJson());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('bc-workflow-builder'),
      decoration: BoxDecoration(
        border: Border.all(color: BcTheme.border),
        borderRadius: BorderRadius.circular(BcTheme.radius),
      ),
      child: Column(
        children: [
          _buildToolbar(),
          Expanded(child: _buildTabContent()),
          if (_effectiveValidation != null &&
              !_effectiveValidation!.valid &&
              !_effectiveValidating)
            _buildErrorBar(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      key: const Key('bc-workflow-builder-tabs'),
      decoration: BoxDecoration(
        color: BcTheme.muted,
        border: Border(
          bottom: BorderSide(color: BcTheme.border),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabs = <Widget>[
            _buildTabButton(BcWorkflowBuilderTab.canvas,
                t('workflow_builder.canvas', 'Canvas')),
            const SizedBox(width: 4),
            _buildTabButton(BcWorkflowBuilderTab.json,
                t('workflow_builder.json_preview', 'JSON')),
            const SizedBox(width: 8),
            _buildModeToggle(),
          ];

          final status = <Widget>[
            if (_effectiveValidating)
              Padding(
                key: const Key('bc-workflow-builder-validating'),
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: BcTheme.mutedForeground,
                  ),
                ),
              ),
            if (_effectiveValidation != null && !_effectiveValidating)
              Padding(
                key: const Key('bc-workflow-builder-validation-status'),
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  _effectiveValidation!.valid
                      ? t('workflow_builder.validation_passed', 'Valid')
                      : t('workflow_builder.validation_failed', 'Invalid'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _effectiveValidation!.valid
                        ? BcTheme.success
                        : BcTheme.destructive,
                  ),
                ),
              ),
            PlatformElevatedButton(
              key: const Key('bc-workflow-builder-validate'),
              onPressed: _effectiveValidating ? null : _runValidation,
              child: Text(t('workflow_builder.validate', 'Validate')),
            ),
            const SizedBox(width: 4),
            PlatformElevatedButton(
              key: const Key('bc-workflow-builder-save'),
              onPressed: (_effectiveSaveDisabled || _effectiveValidating)
                  ? null
                  : _handleSave,
              child: Text(t('workflow_builder.save', 'Save')),
            ),
          ];

          // Tabs plus actions exceed a narrow host, so scroll instead of
          // overflowing. A Spacer needs bounded width, so it is only used in
          // the wide layout.
          if (constraints.maxWidth < 620) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [...tabs, const SizedBox(width: 12), ...status],
              ),
            );
          }

          return Row(children: [...tabs, const Spacer(), ...status]);
        },
      ),
    );
  }

  Widget _buildTabButton(BcWorkflowBuilderTab tab, String label) {
    final isActive = _activeTab == tab;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = tab;
        });
      },
      child: Container(
        key: Key('bc-workflow-builder-tab-${tab.name}'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? BcTheme.foreground : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isActive ? BcTheme.foreground : BcTheme.mutedForeground,
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return GestureDetector(
      onTap: _toggleDagMode,
      child: Container(
        key: const Key('bc-workflow-builder-mode'),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _effectiveDagMode ? BcTheme.foreground : BcTheme.background,
          border: Border.all(color: BcTheme.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          _effectiveDagMode
              ? t('workflow_builder.dag_mode', 'DAG Mode')
              : t('workflow_builder.sequential', 'Sequential'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _effectiveDagMode ? BcTheme.background : BcTheme.foreground,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case BcWorkflowBuilderTab.canvas:
        return _buildCanvasTab();
      case BcWorkflowBuilderTab.json:
        return _buildJsonTab();
    }
  }

  Widget _buildCanvasTab() {
    // Palette and property panel have fixed widths, so the three-pane row
    // overflows as soon as the host is narrower than their sum plus a usable
    // canvas. Below that threshold, keep every pane reachable by scrolling
    // horizontally instead of clipping content.
    const paletteWidth = 160.0;
    const panelWidth = 280.0;
    const minCanvasWidth = 340.0;
    const minTotalWidth = paletteWidth + panelWidth + minCanvasWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        final panes = Row(
          children: [
            _buildPalette(),
            Expanded(child: _buildCanvas()),
            _buildPropertyPanel(),
          ],
        );

        if (constraints.maxWidth >= minTotalWidth) return panes;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: minTotalWidth, child: panes),
        );
      },
    );
  }

  Widget _buildPalette() {
    return Container(
      key: const Key('bc-workflow-builder-palette'),
      width: 160,
      decoration: BoxDecoration(
        color: BcTheme.muted,
        border: Border(
          right: BorderSide(color: BcTheme.border),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              t('workflow_builder.step_types', 'Step Types'),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: BcTheme.mutedForeground,
              ),
            ),
          ),
          for (final st in BcWorkflowStepType.values) _buildPaletteItem(st),
        ],
      ),
    );
  }

  Widget _buildPaletteItem(BcWorkflowStepType st) {
    return LongPressDraggable<BcWorkflowStepType>(
      data: st,
      delay: const Duration(milliseconds: 200),
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(BcTheme.radius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: BcTheme.background,
            border: Border.all(color: BcTheme.foreground),
            borderRadius: BorderRadius.circular(BcTheme.radius),
          ),
          child: Text(
            st.label,
            style: TextStyle(fontSize: 14, color: BcTheme.foreground),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _paletteItemContent(st),
      ),
      child: _paletteItemContent(st),
    );
  }

  Widget _paletteItemContent(BcWorkflowStepType st) {
    return GestureDetector(
      key: Key('bc-workflow-builder-palette-item-${st.id}'),
      onTap: () => _addStep(st),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: BcTheme.background,
          border: Border.all(color: BcTheme.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(st.icon, size: 16, color: BcTheme.mutedForeground),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                st.label,
                style: TextStyle(fontSize: 14, color: BcTheme.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    final steps = _effectiveSteps;
    final transitions = _effectiveTransitions;
    return DragTarget<BcWorkflowStepType>(
      key: const Key('bc-workflow-builder-canvas'),
      onAcceptWithDetails: (details) {
        _addStep(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Container(
          color: isHovering ? BcTheme.accent : null,
          child: steps.isEmpty
              ? Center(
                  key: const Key('bc-workflow-builder-empty'),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      t('workflow_builder.drag_hint',
                          'Drag steps here to build your workflow'),
                      style: TextStyle(
                        fontSize: 14,
                        color: BcTheme.mutedForeground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (transitions.isNotEmpty)
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTapUp: (details) {
                            _handleTransitionTap(
                                details.localPosition, transitions, steps);
                          },
                          child: CustomPaint(
                            key: const Key('bc-workflow-builder-edges'),
                            painter: _TransitionEdgePainter(
                              transitions: transitions,
                              steps: steps,
                              selectedTransitionId: _selectedTransitionId,
                            ),
                          ),
                        ),
                      ),
                    for (final step in steps) _buildStepNode(step),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildStepNode(BcWorkflowStep step) {
    final isSelected = _selectedStepId == step.id;
    final isConnecting = _connectingFromId == step.id;
    return Positioned(
      key: Key('bc-workflow-builder-step-${step.id}'),
      left: step.x,
      top: step.y,
      child: GestureDetector(
        onTap: () => _selectStep(step.id),
        onPanUpdate: (details) {
          _updateStep(step.id, (s) => s.copyWith(
            x: math.max(0, s.x + details.delta.dx),
            y: math.max(0, s.y + details.delta.dy),
          ));
        },
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: BcTheme.background,
            border: Border.all(
              color: isSelected
                  ? BcTheme.foreground
                  : isConnecting
                      ? Colors.blue
                      : BcTheme.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(BcTheme.radius),
            boxShadow: [
              if (isSelected || isConnecting)
                BoxShadow(
                  color: (isConnecting ? Colors.blue : BcTheme.foreground)
                      .withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(step.type.icon, size: 14, color: BcTheme.mutedForeground),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      step.label ?? step.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: BcTheme.foreground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: BcTheme.muted,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        step.type.label,
                        style: TextStyle(
                          fontSize: 10,
                          color: BcTheme.mutedForeground,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    key: Key('bc-workflow-builder-connect-${step.id}'),
                    onTap: () {
                      if (_connectingFromId.isNotEmpty &&
                          _connectingFromId != step.id) {
                        _completeConnection(step.id);
                      } else {
                        _startConnection(step.id);
                      }
                    },
                    child: Icon(
                      Icons.arrow_forward,
                      size: 12,
                      color: BcTheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(width: 2),
                  GestureDetector(
                    key: Key('bc-workflow-builder-remove-step-${step.id}'),
                    onTap: () => _removeStep(step.id),
                    child: Icon(
                      Icons.close,
                      size: 12,
                      color: BcTheme.destructive,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyPanel() {
    final selected = _selectedStep;
    final selectedTr = _selectedTransition;
    return Container(
      key: const Key('bc-workflow-builder-properties'),
      width: 280,
      decoration: BoxDecoration(
        color: BcTheme.background,
        border: Border(
          left: BorderSide(color: BcTheme.border),
        ),
      ),
      child: selected == null && selectedTr == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  t('workflow_builder.select_hint',
                      'Select a step or transition to edit properties'),
                  style: TextStyle(
                    fontSize: 14,
                    color: BcTheme.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : selected != null
              ? _buildStepPropertyPanel(selected)
              : _buildTransitionPropertyPanel(selectedTr!),
    );
  }

  Widget _buildStepPropertyPanel(BcWorkflowStep step) {
    return ListView(
      key: const Key('bc-workflow-builder-step-properties'),
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          t('workflow_builder.step_properties', 'Step Properties'),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: BcTheme.mutedForeground,
          ),
        ),
        if (_effectiveDagMode)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: BcTheme.muted,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                'DAG',
                style: TextStyle(fontSize: 10, color: BcTheme.mutedForeground),
              ),
            ),
          ),
        const SizedBox(height: 12),
        _buildTextField(
          key: 'bc-workflow-builder-prop-label',
          label: t('workflow_builder.label', 'Label'),
          value: step.label ?? '',
          onChanged: (v) => _updateStep(step.id, (s) => s.copyWith(label: v)),
        ),
        _buildTextField(
          key: 'bc-workflow-builder-prop-name',
          label: t('workflow_builder.step_name', 'Step Name'),
          value: step.name,
          onChanged: (v) => _updateStep(step.id, (s) => s.copyWith(name: v)),
        ),
        _buildDropdownField(
          key: 'bc-workflow-builder-prop-type',
          label: t('workflow_builder.step_type', 'Step Type'),
          value: step.type,
          items: BcWorkflowStepType.values,
          itemLabel: (st) => st.label,
          onChanged: (st) => _updateStep(step.id, (s) => s.copyWith(type: st)),
        ),
        if (step.type == BcWorkflowStepType.call)
          _buildTextField(
            key: 'bc-workflow-builder-prop-process',
            label: t('workflow_builder.process', 'Process'),
            value: step.process ?? '',
            onChanged: (v) => _updateStep(step.id, (s) => s.copyWith(process: v.isEmpty ? null : v)),
          ),
        if (step.type == BcWorkflowStepType.ifCondition) ...[
          _buildTextField(
            key: 'bc-workflow-builder-prop-condition',
            label: t('workflow_builder.condition', 'Condition'),
            value: step.condition ?? '',
            onChanged: (v) => _updateStep(step.id, (s) => s.copyWith(condition: v.isEmpty ? null : v)),
          ),
          _buildTextField(
            key: 'bc-workflow-builder-prop-then',
            label: t('workflow_builder.then_step', 'Then (step name)'),
            value: step.thenStep ?? '',
            onChanged: (v) => _updateStep(step.id, (s) => s.copyWith(thenStep: v.isEmpty ? null : v)),
          ),
          _buildTextField(
            key: 'bc-workflow-builder-prop-else',
            label: t('workflow_builder.else_step', 'Else (step name)'),
            value: step.elseStep ?? '',
            onChanged: (v) => _updateStep(step.id, (s) => s.copyWith(elseStep: v.isEmpty ? null : v)),
          ),
        ],
        if (step.type == BcWorkflowStepType.switchType)
          _buildTextField(
            key: 'bc-workflow-builder-prop-field',
            label: t('workflow_builder.field', 'Field'),
            value: step.field ?? '',
            onChanged: (v) => _updateStep(step.id, (s) => s.copyWith(field: v.isEmpty ? null : v)),
          ),
        if (step.type == BcWorkflowStepType.loop)
          _buildTextField(
            key: 'bc-workflow-builder-prop-over',
            label: t('workflow_builder.over', 'Over (expression)'),
            value: step.over ?? '',
            onChanged: (v) => _updateStep(step.id, (s) => s.copyWith(over: v.isEmpty ? null : v)),
          ),
        if (step.type == BcWorkflowStepType.script) ...[
          _buildTextField(
            key: 'bc-workflow-builder-prop-runtime',
            label: t('workflow_builder.runtime', 'Runtime'),
            value: step.runtime ?? '',
            onChanged: (v) => _updateStep(step.id, (s) => s.copyWith(runtime: v.isEmpty ? null : v)),
          ),
          _buildTextAreaField(
            key: 'bc-workflow-builder-prop-script',
            label: t('workflow_builder.script', 'Script'),
            value: step.script ?? '',
            onChanged: (v) => _updateStep(step.id, (s) => s.copyWith(script: v.isEmpty ? null : v)),
          ),
        ],
        if (step.type.needsModel)
          _buildTextField(
            key: 'bc-workflow-builder-prop-model',
            label: t('workflow_builder.model', 'Model'),
            value: step.model ?? '',
            onChanged: (v) => _updateStep(step.id, (s) => s.copyWith(model: v.isEmpty ? null : v)),
          ),
        if (step.type == BcWorkflowStepType.http) ...[
          _buildTextField(
            key: 'bc-workflow-builder-prop-url',
            label: t('workflow_builder.url', 'URL'),
            value: step.url ?? '',
            onChanged: (v) => _updateStep(step.id, (s) => s.copyWith(url: v.isEmpty ? null : v)),
          ),
          _buildDropdownField(
            key: 'bc-workflow-builder-prop-method',
            label: t('workflow_builder.method', 'Method'),
            value: step.method ?? 'GET',
            items: const ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
            itemLabel: (m) => m,
            onChanged: (m) => _updateStep(step.id, (s) => s.copyWith(method: m)),
          ),
        ],
        if (step.type == BcWorkflowStepType.emit)
          _buildTextField(
            key: 'bc-workflow-builder-prop-event',
            label: t('workflow_builder.event', 'Event'),
            value: step.event ?? '',
            onChanged: (v) => _updateStep(step.id, (s) => s.copyWith(event: v.isEmpty ? null : v)),
          ),
        if (step.type == BcWorkflowStepType.assign) ...[
          _buildTextField(
            key: 'bc-workflow-builder-prop-variable',
            label: t('workflow_builder.variable', 'Variable'),
            value: step.variable ?? '',
            onChanged: (v) => _updateStep(step.id, (s) => s.copyWith(variable: v.isEmpty ? null : v)),
          ),
          _buildTextField(
            key: 'bc-workflow-builder-prop-value',
            label: t('workflow_builder.value', 'Value'),
            value: step.value ?? '',
            onChanged: (v) => _updateStep(step.id, (s) => s.copyWith(value: v.isEmpty ? null : v)),
          ),
        ],
        if (step.type == BcWorkflowStepType.log)
          _buildTextField(
            key: 'bc-workflow-builder-prop-message',
            label: t('workflow_builder.message', 'Message'),
            value: step.message ?? '',
            onChanged: (v) => _updateStep(step.id, (s) => s.copyWith(message: v.isEmpty ? null : v)),
          ),
      ],
    );
  }

  Widget _buildTransitionPropertyPanel(BcWorkflowTransition tr) {
    return ListView(
      key: const Key('bc-workflow-builder-transition-properties'),
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          t('workflow_builder.transition_properties', 'Transition Properties'),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: BcTheme.mutedForeground,
          ),
        ),
        const SizedBox(height: 12),
        _buildReadOnlyField(
          key: 'bc-workflow-builder-prop-from',
          label: 'From',
          value: tr.from,
        ),
        _buildReadOnlyField(
          key: 'bc-workflow-builder-prop-to',
          label: 'To',
          value: tr.to,
        ),
        _buildTextField(
          key: 'bc-workflow-builder-prop-transition-condition',
          label: t('workflow_builder.condition', 'Condition'),
          value: tr.condition ?? '',
          onChanged: (v) => _updateTransition(tr.id, (t) => t.copyWith(condition: v.isEmpty ? null : v)),
        ),
        _buildTextField(
          key: 'bc-workflow-builder-prop-transition-label',
          label: t('workflow_builder.label', 'Label'),
          value: tr.label ?? '',
          onChanged: (v) => _updateTransition(tr.id, (t) => t.copyWith(label: v.isEmpty ? null : v)),
        ),
        const SizedBox(height: 8),
        PlatformElevatedButton(
          key: const Key('bc-workflow-builder-remove-transition'),
          onPressed: () => _removeTransition(tr.id),
          color: BcTheme.destructive,
          child: Text(
            t('workflow_builder.remove_transition', 'Remove Transition'),
            style: TextStyle(color: BcTheme.background),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String key,
    required String label,
    required String value,
    required void Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: BcTheme.foreground,
            ),
          ),
          const SizedBox(height: 4),
          PlatformWidget(
            key: Key(key),
            material: (context, platform) => TextField(
              controller: TextEditingController(text: value),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: BcTheme.border),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                isDense: true,
              ),
              style: TextStyle(fontSize: 14, color: BcTheme.foreground),
              onChanged: onChanged,
            ),
            cupertino: (context, platform) => CupertinoTextField(
              controller: TextEditingController(text: value),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: BcTheme.border),
                borderRadius: BorderRadius.circular(4),
              ),
              style: TextStyle(fontSize: 14, color: BcTheme.foreground),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextAreaField({
    required String key,
    required String label,
    required String value,
    required void Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: BcTheme.foreground,
            ),
          ),
          const SizedBox(height: 4),
          PlatformWidget(
            key: Key(key),
            material: (context, platform) => TextField(
              controller: TextEditingController(text: value),
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: BcTheme.border),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                isDense: true,
              ),
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
                color: BcTheme.foreground,
              ),
              onChanged: onChanged,
            ),
            cupertino: (context, platform) => CupertinoTextField(
              controller: TextEditingController(text: value),
              maxLines: 4,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: BcTheme.border),
                borderRadius: BorderRadius.circular(4),
              ),
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
                color: BcTheme.foreground,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String key,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: BcTheme.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            key: Key(key),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: BcTheme.muted,
              border: Border.all(color: BcTheme.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: BcTheme.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String key,
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: BcTheme.foreground,
            ),
          ),
          const SizedBox(height: 4),
          PlatformWidget(
            key: Key(key),
            material: (context, platform) => DropdownButtonFormField<T>(
              value: value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: BcTheme.border),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                isDense: true,
              ),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          itemLabel(item),
                          style: TextStyle(
                            fontSize: 14,
                            color: BcTheme.foreground,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
            cupertino: (context, platform) => CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: BcTheme.background,
              onPressed: () {
                _showCupertinoPicker(
                    context, items, value, itemLabel, onChanged);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    itemLabel(value),
                    style: TextStyle(
                      fontSize: 14,
                      color: BcTheme.foreground,
                    ),
                  ),
                  Icon(
                    CupertinoIcons.chevron_down,
                    size: 14,
                    color: BcTheme.mutedForeground,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCupertinoPicker<T>(
    BuildContext context,
    List<T> items,
    T currentValue,
    String Function(T) label,
    void Function(T) onChanged,
  ) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 250,
        color: BcTheme.background,
        child: CupertinoPicker(
          itemExtent: 32,
          scrollController: FixedExtentScrollController(
            initialItem:
                items.indexOf(currentValue).clamp(0, items.length - 1),
          ),
          onSelectedItemChanged: (index) {
            onChanged(items[index]);
          },
          children: items
              .map((item) => Center(
                    child: Text(
                      label(item),
                      style: TextStyle(
                        fontSize: 14,
                        color: BcTheme.foreground,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildJsonTab() {
    final jsonStr = _buildProcessJson().toJsonString();
    return Container(
      key: const Key('bc-workflow-builder-json'),
      color: BcTheme.muted,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: SelectableText(
          key: const Key('bc-workflow-builder-json-output'),
          jsonStr,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: BcTheme.foreground,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBar() {
    return Container(
      key: const Key('bc-workflow-builder-errors'),
      decoration: BoxDecoration(
        color: BcTheme.destructive.withValues(alpha: 0.05),
        border: Border(
          top: BorderSide(
            color: BcTheme.destructive.withValues(alpha: 0.3),
          ),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _effectiveValidation!.errors.map((err) {
          return Padding(
            key: Key(
                'bc-workflow-builder-error-${err.field ?? ''}-${err.message}'),
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              err.field != null && err.field!.isNotEmpty
                  ? '[${err.field}] ${err.message}'
                  : err.message,
              style: TextStyle(
                fontSize: 12,
                color: BcTheme.destructive,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Custom painter for drawing transition edges between workflow steps.
class _TransitionEdgePainter extends CustomPainter {
  final List<BcWorkflowTransition> transitions;
  final List<BcWorkflowStep> steps;
  final String selectedTransitionId;

  _TransitionEdgePainter({
    required this.transitions,
    required this.steps,
    required this.selectedTransitionId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stepMap = <String, BcWorkflowStep>{};
    for (final s in steps) {
      stepMap[s.name] = s;
    }

    for (final tr in transitions) {
      final fromStep = stepMap[tr.from];
      final toStep = stepMap[tr.to];
      if (fromStep == null || toStep == null) continue;

      final startX = fromStep.x + 140;
      final startY = fromStep.y + 30;
      final endX = toStep.x;
      final endY = toStep.y + 30;
      final midX = (startX + endX) / 2;

      final isSelected = tr.id == selectedTransitionId;
      final paint = Paint()
        ..color = isSelected ? BcTheme.foreground : BcTheme.mutedForeground
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final path = Path()
        ..moveTo(startX, startY)
        ..cubicTo(midX, startY, midX, endY, endX, endY);

      canvas.drawPath(path, paint);

      final arrowPaint = Paint()
        ..color = isSelected ? BcTheme.foreground : BcTheme.mutedForeground
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(endX, endY), 4, arrowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TransitionEdgePainter oldDelegate) {
    return oldDelegate.transitions != transitions ||
        oldDelegate.steps != steps ||
        oldDelegate.selectedTransitionId != selectedTransitionId;
  }
}
