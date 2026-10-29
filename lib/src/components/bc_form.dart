library bc_form;

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../core/reactive_store.dart';
import '../renderer/bc_field_builder.dart';
import '../schema/ui_schema.dart';

/// Material-only form container with reactive store binding (ADR-011 Section 5).
///
/// Supports two modes:
///   - **Legacy mode** (`fields` is null): thin container that creates a
///     [ReactiveStore], wraps an optional `child` via [_BcFormScope]
///     (InheritedWidget), and exposes it through [storeOf].
///   - **Schema-driven mode** (`fields` is non-null): renders fields via
///     [buildField] (BcFieldBuilder), action buttons via
///     [PlatformElevatedButton], and wires `onChange` / `onSubmit` /
///     `onAction` callbacks.
///
/// Both modes can coexist: when both `fields` and `child` are provided, the
/// fields render first and the child appears below (VAL-FORM-003).
class BcForm extends StatefulWidget {
  final Map<String, dynamic>? initialValues;
  final List<Reaction>? reactions;
  final void Function(ReactiveStore store)? onCreateStore;
  final Widget? child;

  // -- Schema-driven parameters (all optional for backward compatibility) --

  /// Fields rendered via [buildField]. When null, BcForm operates in legacy
  /// child-only mode.
  final List<FieldNode>? fields;

  /// Action buttons rendered below the fields.
  final List<UiAction>? actions;

  /// Layout direction for fields. Defaults to vertical.
  final FormLayout layout;

  /// When true, all rendered fields are disabled regardless of their
  /// individual [FieldNode.disabled] setting.
  final bool disabled;

  /// Fired on every field value change with the full values map.
  final void Function(Map<String, dynamic> values)? onChange;

  /// Fired when a `submit: true` action is tapped.
  final void Function(Map<String, dynamic> values)? onSubmit;

  /// Fired when a non-submit action is tapped.
  final void Function(String name, Map<String, dynamic> values)? onAction;

  const BcForm({
    super.key,
    this.initialValues,
    this.reactions,
    this.onCreateStore,
    this.child,
    this.fields,
    this.actions,
    this.layout = FormLayout.vertical,
    this.disabled = false,
    this.onChange,
    this.onSubmit,
    this.onAction,
  });

  @override
  State<BcForm> createState() => _BcFormState();

  /// Access the nearest BcForm's store via context.
  static ReactiveStore? storeOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_BcFormScope>();
    return scope?.store;
  }
}

class _BcFormState extends State<BcForm> {
  late ReactiveStore _store;
  late void Function(Map<String, dynamic>) _changeListener;

  @override
  void initState() {
    super.initState();
    _store = ReactiveStore(ReactiveStoreOptions(
      initialValues: widget.initialValues,
      reactions: widget.reactions,
    ));
    _store.runAll();
    widget.onCreateStore?.call(_store);

    // Wire onChange: subscribe to store notifications and fire the callback
    // with the current snapshot (VAL-FORM-008).
    _changeListener = widget.onChange != null
        ? (Map<String, dynamic> snapshot) {
            // Strip internal keys ($self, $root, $parent, $index) before
            // forwarding to the consumer.
            final filtered = Map<String, dynamic>.from(snapshot)
              ..removeWhere((key, _) => key.startsWith(r'$'));
            widget.onChange!(filtered);
          }
        : (_) {};

    if (widget.onChange != null) {
      _store.subscribe(_changeListener);
    }
  }

  @override
  void dispose() {
    if (widget.onChange != null) {
      _store.unsubscribe(_changeListener);
    }
    _store.dispose();
    super.dispose();
  }

  void _handleAction(UiAction action) {
    final values = _storeValues();
    if (action.submit) {
      widget.onSubmit?.call(values);
    } else {
      widget.onAction?.call(action.name, values);
    }
  }

  /// Returns the current store values without internal $-prefixed keys.
  Map<String, dynamic> _storeValues() {
    final snap = _store.snapshot();
    return Map<String, dynamic>.from(snap)
      ..removeWhere((key, _) => key.startsWith(r'$'));
  }

  @override
  Widget build(BuildContext context) {
    final hasFields = widget.fields != null && widget.fields!.isNotEmpty;
    final hasActions = widget.actions != null && widget.actions!.isNotEmpty;
    final hasChild = widget.child != null;

    // Legacy child-only mode (VAL-FORM-001): no fields, just the child.
    if (!hasFields && !hasActions) {
      return _BcFormScope(
        store: _store,
        child: Form(
          child: hasChild
              ? widget.child!
              : const SizedBox.shrink(),
        ),
      );
    }

    // Schema-driven mode: build fields + actions + optional child.
    final fieldWidgets = <Widget>[];

    if (hasFields) {
      for (final node in widget.fields!) {
        fieldWidgets.add(
          buildField(node, _store, disabled: widget.disabled),
        );
      }
    }

    Widget fieldsArea;
    if (fieldWidgets.isEmpty) {
      fieldsArea = const SizedBox.shrink();
    } else if (widget.layout == FormLayout.horizontal) {
      fieldsArea = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fieldWidgets
            .map((w) => Expanded(child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: w,
                )))
            .toList(),
      );
    } else {
      fieldsArea = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: fieldWidgets,
      );
    }

    // Action buttons (VAL-FORM-004).
    final actionButtons = <Widget>[];
    if (hasActions) {
      for (final action in widget.actions!) {
        final label = action.label ?? _humanize(action.name);
        final isDisabled = action.disabled || widget.disabled;
        actionButtons.add(
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PlatformElevatedButton(
              onPressed: isDisabled ? null : () => _handleAction(action),
              child: Text(label),
            ),
          ),
        );
      }
    }

    return _BcFormScope(
      store: _store,
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            fieldsArea,
            if (hasActions)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(
                  spacing: 0,
                  runSpacing: 0,
                  children: actionButtons,
                ),
              ),
            if (hasChild) ...[
              const SizedBox(height: 12),
              widget.child!,
            ],
          ],
        ),
      ),
    );
  }

  /// Converts a camelCase / snake_case name into a human-readable label.
  String _humanize(String name) {
    // Split on camelCase boundaries and underscores, then capitalize.
    final parts = <String>[];
    final buffer = StringBuffer();
    for (var i = 0; i < name.length; i++) {
      final ch = name[i];
      if (ch == '_' || ch == '-') {
        if (buffer.isNotEmpty) {
          parts.add(buffer.toString());
          buffer.clear();
        }
      } else if (ch.toUpperCase() == ch && ch.toLowerCase() != ch) {
        if (buffer.isNotEmpty) {
          parts.add(buffer.toString());
          buffer.clear();
        }
        buffer.write(ch);
      } else {
        buffer.write(ch);
      }
    }
    if (buffer.isNotEmpty) {
      parts.add(buffer.toString());
    }
    if (parts.isEmpty) return name;
    return parts.map((p) {
      if (p.isEmpty) return p;
      return p[0].toUpperCase() + p.substring(1).toLowerCase();
    }).join(' ');
  }
}

class _BcFormScope extends InheritedWidget {
  final ReactiveStore store;

  const _BcFormScope({required this.store, required super.child});

  @override
  bool updateShouldNotify(_BcFormScope oldWidget) =>
      store != oldWidget.store;
}
