/// Block Renderer Contract - Dart mirror of @bitcode/ui-schema block-renderer/
/// types.ts (ADR-017 §3, Agent H).
///
/// The composition + render-plan surface. The Dart port mirrors the TypeScript
/// `BlockNode`, `BlockBindings`, and `RenderPlan` union field-for-field so the
/// JSON wire shape is byte-identical across platforms.
///
/// DESIGN (matches the TypeScript engine, amendments 2-6):
///   - The renderer engine emits RENDER PLANS only — never Flutter widgets.
///     The Flutter widget (BcBlockRenderer) lives in a follow-up; this file
///     is the contract mirror that keeps Dart parity with the portable
///     engine before the widget lands.
///   - The registry stores COMPONENT METADATA only — never a widget object.
///   - Actions are bound as deferred handler plans; the runner executes them
///     on user events, NOT during tree resolution.
///
/// Manual sealed classes (no freezed) to control the JSON discriminator.
library bitcode.ui_schema.block_renderer.types;

import '../actions/source.dart' show ActionSource;
import '../expressions/ast.dart' show PortableExpression;

// ---------------------------------------------------------------------------
// Block composition tree (input surface)
// ---------------------------------------------------------------------------

/// A node in the block composition tree (ADR-017 §3).
///
/// A node is EITHER a catalog entry reference ([blockId]) OR an anonymous
/// inline schema ([schema]). Children compose a recursive tree. Per-node
/// bindings are evaluated by the engine; actions are bound as deferred plans.
class BlockNode {
  const BlockNode({
    this.blockId,
    this.version,
    this.schema,
    this.children,
    this.bindings,
    this.props,
    this.actions,
  });

  /// Catalog entry id (e.g. 'content.hero'). Mutually exclusive with [schema].
  final String? blockId;

  /// Optional version pin for the catalog entry.
  final String? version;

  /// Anonymous inline schema (escape hatch). Mutually exclusive with [blockId].
  final Map<String, dynamic>? schema;

  /// Nested child nodes.
  final List<BlockNode>? children;

  /// Per-node bindings evaluated by the engine.
  final BlockBindings? bindings;

  /// Props forwarded to a component-strategy catalog entry.
  final Map<String, dynamic>? props;

  /// Named action bindings (trigger name -> ActionSource).
  final Map<String, ActionSource>? actions;

  Map<String, dynamic> toJson() => {
    if (blockId != null) 'blockId': blockId,
    if (version != null) 'version': version,
    if (schema != null) 'schema': schema,
    if (children != null) 'children': children!.map((c) => c.toJson()).toList(),
    if (bindings != null) 'bindings': bindings!.toJson(),
    if (props != null) 'props': props,
    if (actions != null)
      'actions': actions!.map((key, value) => MapEntry(key, value.toJson())),
  };
}

/// Per-node bindings evaluated by the engine.
class BlockBindings {
  const BlockBindings({
    this.values,
    this.visible,
    this.disabled,
    this.readOnly,
    this.data,
  });

  final Map<String, dynamic>? values;

  /// Literal bool or PortableExpression.
  final Object? visible;
  final Object? disabled;
  final Object? readOnly;
  final Map<String, dynamic>? data;

  Map<String, dynamic> toJson() => {
    if (values != null) 'values': values,
    if (visible != null)
      'visible': visible is bool
          ? visible
          : (visible as PortableExpression).toJson(),
    if (disabled != null)
      'disabled': disabled is bool
          ? disabled
          : (disabled as PortableExpression).toJson(),
    if (readOnly != null)
      'readOnly': readOnly is bool
          ? readOnly
          : (readOnly as PortableExpression).toJson(),
    if (data != null) 'data': data,
  };
}

// ---------------------------------------------------------------------------
// Render plans (portable OUTPUT — never framework objects)
// ---------------------------------------------------------------------------

/// Discriminated union of render plans. Mirrors the TypeScript RenderPlan.
/// The engine emits these; the Flutter widget translates them into widgets.
sealed class RenderPlan {
  const RenderPlan();
  String get kind;
  String get key;
  Map<String, dynamic> toJson();
}

/// A schema-strategy plan. The engine materialized the schema preset.
class SchemaRenderPlan extends RenderPlan {
  const SchemaRenderPlan({
    required this.schema,
    required this.values,
    required this.disabled,
    required this.readOnly,
    required this.key,
  });

  final Map<String, dynamic> schema;
  final Map<String, dynamic> values;
  final bool disabled;
  final bool readOnly;
  @override
  final String key;

  @override
  String get kind => 'schema';

  @override
  Map<String, dynamic> toJson() => {
    'kind': 'schema',
    'schema': schema,
    'values': values,
    'disabled': disabled,
    'readOnly': readOnly,
    'key': key,
  };
}

/// A component-strategy plan. The Flutter widget resolves the actual widget
/// from the platform registry (the portable registry stores metadata only).
class ComponentRenderPlan extends RenderPlan {
  const ComponentRenderPlan({
    required this.componentKey,
    required this.props,
    required this.disabled,
    required this.key,
  });

  final String componentKey;
  final Map<String, dynamic> props;
  final bool disabled;
  @override
  final String key;

  @override
  String get kind => 'component';

  @override
  Map<String, dynamic> toJson() => {
    'kind': 'component',
    'componentKey': componentKey,
    'props': props,
    'disabled': disabled,
    'key': key,
  };
}

/// A hidden plan. visible resolved to false; the subtree is pruned.
class HiddenPlan extends RenderPlan {
  const HiddenPlan({required this.reason, required this.key});

  /// 'literal' (bool false) or 'evaluated' (AST false).
  final String reason;
  @override
  final String key;

  @override
  String get kind => 'hidden';

  @override
  Map<String, dynamic> toJson() => {
    'kind': 'hidden',
    'reason': reason,
    'key': key,
  };
}

/// A diagnostic plan. Resolution failed. The Flutter widget renders an
/// accessible fallback — never silent.
class DiagnosticPlan extends RenderPlan {
  const DiagnosticPlan({required this.diagnostics, required this.key});

  final List<Map<String, dynamic>> diagnostics;
  @override
  final String key;

  @override
  String get kind => 'error';

  @override
  Map<String, dynamic> toJson() => {
    'kind': 'error',
    'diagnostics': diagnostics,
    'key': key,
  };
}

/// A resolved block tree node: plan + children + diagnostics + actions.
class ResolvedBlockTree {
  const ResolvedBlockTree({
    required this.plan,
    required this.children,
    required this.diagnostics,
    required this.key,
    this.actions,
  });

  final RenderPlan plan;
  final List<ResolvedBlockTree> children;
  final List<Map<String, dynamic>> diagnostics;
  final String key;
  final Map<String, ActionHandlerPlan>? actions;
}

class ActionHandlerPlan {
  const ActionHandlerPlan({required this.source, this.trigger});

  final ActionSource source;
  final String? trigger;

  Map<String, dynamic> toJson() => {
    'source': source.toJson(),
    if (trigger != null) 'trigger': trigger,
  };
}

// ---------------------------------------------------------------------------
// Render options + resolved bindings
// ---------------------------------------------------------------------------

/// Options for the renderer engine.
class RenderOptions {
  const RenderOptions({this.allowCandidate = false, this.platform});

  /// By default the engine rejects candidate/deprecated entries. Set true for
  /// builder/dev/diagnostic tooling.
  final bool allowCandidate;

  /// 'web' | 'flutter' | 'react-native' | 'server'.
  final String? platform;

  Map<String, dynamic> toJson() => {
    if (allowCandidate) 'allowCandidate': allowCandidate,
    if (platform != null) 'platform': platform,
  };
}

/// Resolved binding flags after evaluating visible/disabled/readOnly.
class ResolvedBindings {
  const ResolvedBindings({
    required this.visible,
    required this.disabled,
    required this.readOnly,
  });

  final bool visible;
  final bool disabled;
  final bool readOnly;
}

// ---------------------------------------------------------------------------
// Registry metadata (portable — widget lives in the Flutter binding)
// ---------------------------------------------------------------------------

/// Portable metadata about a registered component. The portable registry
/// stores ONLY this metadata (never a widget object — amendment 3).
class ComponentMetadata {
  const ComponentMetadata({
    required this.componentKey,
    this.category,
    this.capabilities,
    this.supportedPlatforms,
    this.adapterRef,
  });

  final String componentKey;
  final String? category;
  final List<String>? capabilities;
  final List<String>? supportedPlatforms;
  final String? adapterRef;

  Map<String, dynamic> toJson() => {
    'componentKey': componentKey,
    if (category != null) 'category': category,
    if (capabilities != null) 'capabilities': capabilities,
    if (supportedPlatforms != null) 'supportedPlatforms': supportedPlatforms,
    if (adapterRef != null) 'adapterRef': adapterRef,
  };
}

// ---------------------------------------------------------------------------
// Diagnostic codes (runtime block renderer layer)
// ---------------------------------------------------------------------------

/// Stable runtime diagnostic codes produced by the block renderer. Mirrors
/// BLOCK_RENDER_DIAGNOSTIC_CODES in the TypeScript package.
class BlockRenderDiagnosticCodes {
  static const entryNotFound = 'BLOCK_ENTRY_NOT_FOUND';
  static const entryNotReady = 'BLOCK_ENTRY_NOT_READY';
  static const componentMissing = 'BLOCK_COMPONENT_MISSING';
  static const functionMissing = 'BLOCK_FUNCTION_MISSING';
  static const adapterMissing = 'BLOCK_ADAPTER_MISSING';
  static const platformUnsupported = 'BLOCK_PLATFORM_UNSUPPORTED';
  static const schemaInvalid = 'BLOCK_SCHEMA_INVALID';
  static const renderStrategyInvalid = 'BLOCK_RENDER_STRATEGY_INVALID';
  static const expressionEvalFailed = 'BLOCK_EXPRESSION_EVAL_FAILED';
  static const renderAborted = 'BLOCK_RENDER_ABORTED';

  static const Set<String> all = {
    entryNotFound,
    entryNotReady,
    componentMissing,
    functionMissing,
    adapterMissing,
    platformUnsupported,
    schemaInvalid,
    renderStrategyInvalid,
    expressionEvalFailed,
    renderAborted,
  };
}
