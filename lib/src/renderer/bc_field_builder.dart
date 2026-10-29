library bc_field_builder;

import 'package:flutter/material.dart';

import '../components/bc_checkbox.dart';
import '../components/bc_date_field.dart';
import '../components/bc_input.dart';
import '../components/bc_number_field.dart';
import '../components/bc_select.dart';
import '../components/bc_toggle.dart';
import '../core/reactive_store.dart' hide Listener;
import '../core/types.dart';
import '../schema/ui_schema.dart';

/// Builds a concrete Flutter widget for a single [FieldNode], wiring the
/// [ReactiveStore] for value read/write and live metadata (visible /
/// disabled / required).
///
/// The returned widget is reactive: it subscribes to [store] via the public
/// `subscribe` / `unsubscribe` APIs and rebuilds whenever any store change
/// fires, so that metadata-driven visibility and disabled state are always
/// up-to-date.
///
/// See ADR-005 (metadata-driven UI) and the VAL-FB-* validation contract.
Widget buildField(
  FieldNode node,
  ReactiveStore store, {
  bool disabled = false,
}) {
  return _BcFieldBuilder(
    node: node,
    store: store,
    rendererDisabled: disabled,
  );
}

// ---------------------------------------------------------------------------
// JSON value coercion
// ---------------------------------------------------------------------------
//
// `ReactiveStore.get()` returns `dynamic`, and the values a renderer receives
// originate from JSON documents (or a host app's initial-values map), not from
// Dart natives. A hard cast such as `as DateTime?` is runtime-checked and
// throws a TypeError on any shape mismatch, which tears down the whole field
// subtree. Every builder therefore coerces, and unconvertible input degrades to
// `null` instead of crashing.

/// Coerces a JSON scalar to [String]. `null` stays `null` so callers can
/// distinguish "absent" from "empty".
String? coerceString(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return null;
}

/// Coerces a JSON scalar to [num], parsing numeric strings.
num? coerceNum(Object? value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value.trim());
  if (value is bool) return value ? 1 : 0;
  return null;
}

/// Coerces a JSON date to [DateTime].
///
/// Accepts a native [DateTime], an ISO 8601 string (`yyyy-MM-dd` or a full
/// timestamp — the shape declared by the shared schema contract), or epoch
/// milliseconds.
DateTime? coerceDateTime(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return DateTime.tryParse(trimmed);
  }
  return null;
}

/// Coerces a JSON scalar to [bool], accepting `1`/`0` and the common string
/// spellings produced by form posts and query strings.
bool? coerceBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
      case 'on':
        return true;
      case 'false':
      case '0':
      case 'no':
      case 'off':
      case '':
        return false;
    }
  }
  return null;
}

// ---------------------------------------------------------------------------
// Reactive wrapper widget
// ---------------------------------------------------------------------------

class _BcFieldBuilder extends StatefulWidget {
  final FieldNode node;
  final ReactiveStore store;
  final bool rendererDisabled;

  const _BcFieldBuilder({
    required this.node,
    required this.store,
    required this.rendererDisabled,
  });

  @override
  State<_BcFieldBuilder> createState() => _BcFieldBuilderState();
}

class _BcFieldBuilderState extends State<_BcFieldBuilder> {
  late final void Function(Map<String, dynamic>) _listener;

  @override
  void initState() {
    super.initState();
    _listener = _onStoreChange;
    widget.store.subscribe(_listener);
  }

  void _onStoreChange(Map<String, dynamic> snapshot) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.store.unsubscribe(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final store = widget.store;
    final name = node.name;

    final meta = store.getMeta(name);

    // VAL-FB-023 / VAL-FB-053 — hidden fields produce no interactive control.
    if (!meta.visible) {
      return const SizedBox.shrink();
    }

    // VAL-FB-014..016, VAL-FB-052 — disabled precedence:
    // renderer disabled → live metadata → node (OR semantics, any true wins).
    final effectiveDisabled =
        widget.rendererDisabled || meta.disabled || node.disabled;

    return _buildFieldWidget(node, store, effectiveDisabled);
  }

  Widget _buildFieldWidget(
    FieldNode node,
    ReactiveStore store,
    bool disabled,
  ) {
    final type = node.type ?? FieldType.input;

    switch (type) {
      case FieldType.input:
      case FieldType.email:
      case FieldType.password:
      case FieldType.url:
      case FieldType.tel:
      case FieldType.textarea:
        return _buildInput(node, store, type, disabled);
      case FieldType.number:
        return _buildNumber(node, store, disabled);
      case FieldType.date:
        return _buildDate(node, store, disabled);
      case FieldType.select:
        return _buildSelect(node, store, disabled);
      case FieldType.toggle:
        return _buildToggle(node, store, disabled);
      case FieldType.checkbox:
        return _buildCheckbox(node, store, disabled);
    }
  }

  // -- Input variants (VAL-FB-001..006, VAL-FB-033) -----------------------

  Widget _buildInput(
    FieldNode node,
    ReactiveStore store,
    FieldType type,
    bool disabled,
  ) {
    final name = node.name;
    final value = coerceString(store.get(name));

    TextInputType keyboardType;
    bool obscureText = false;
    int? maxLines = 1;

    switch (type) {
      case FieldType.input:
        keyboardType = TextInputType.text;
        break;
      case FieldType.email:
        keyboardType = TextInputType.emailAddress;
        break;
      case FieldType.password:
        keyboardType = TextInputType.text;
        obscureText = true;
        break;
      case FieldType.url:
        keyboardType = TextInputType.url;
        break;
      case FieldType.tel:
        keyboardType = TextInputType.phone;
        break;
      case FieldType.textarea:
        keyboardType = TextInputType.text;
        maxLines = null;
        break;
      default:
        keyboardType = TextInputType.text;
        break;
    }

    return BcInput(
      name: name,
      value: value,
      placeholder: node.placeholder,
      label: node.label,
      helperText: node.hint,
      disabled: disabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onValueChange: (String newValue, BcChangeMeta _) {
        store.set(name, newValue);
      },
    );
  }

  // -- Number field (VAL-FB-007, VAL-FB-047) -------------------------------

  Widget _buildNumber(
    FieldNode node,
    ReactiveStore store,
    bool disabled,
  ) {
    final name = node.name;
    final value = coerceNum(store.get(name));

    return BcNumberField(
      name: name,
      value: value,
      label: node.label,
      placeholder: node.placeholder,
      min: node.min,
      max: node.max,
      disabled: disabled,
      onValueChange: (num newValue, BcChangeMeta _) {
        store.set(name, newValue);
      },
    );
  }

  // -- Date field (VAL-FB-008) ---------------------------------------------

  Widget _buildDate(
    FieldNode node,
    ReactiveStore store,
    bool disabled,
  ) {
    final name = node.name;
    final value = coerceDateTime(store.get(name));

    return BcDateField(
      name: name,
      value: value,
      label: node.label,
      placeholder: node.placeholder,
      disabled: disabled,
      onValueChange: (DateTime newValue, BcChangeMeta _) {
        store.set(name, newValue);
      },
    );
  }

  // -- Select (VAL-FB-009, VAL-FB-040) --------------------------------------

  Widget _buildSelect(
    FieldNode node,
    ReactiveStore store,
    bool disabled,
  ) {
    final name = node.name;
    final value = coerceString(store.get(name));

    final options = node.options
        .map((opt) => BcSelectOption<String>(
              value: opt.value,
              label: opt.label,
            ))
        .toList();

    return BcSelect<String>(
      name: name,
      value: value,
      options: options,
      label: node.label,
      placeholder: node.placeholder,
      disabled: disabled,
      onValueChange: (String newValue, BcChangeMeta _) {
        store.set(name, newValue);
      },
    );
  }

  // -- Toggle (VAL-FB-011, VAL-FB-039) --------------------------------------

  Widget _buildToggle(
    FieldNode node,
    ReactiveStore store,
    bool disabled,
  ) {
    final name = node.name;
    final value = coerceBool(store.get(name));

    return BcToggle(
      name: name,
      value: value,
      label: node.label,
      disabled: disabled,
      onValueChange: (bool newValue, BcChangeMeta _) {
        store.set(name, newValue);
      },
    );
  }

  // -- Checkbox (VAL-FB-010, VAL-FB-039) ------------------------------------

  Widget _buildCheckbox(
    FieldNode node,
    ReactiveStore store,
    bool disabled,
  ) {
    final name = node.name;
    final value = coerceBool(store.get(name));

    return BcCheckbox(
      name: name,
      value: value,
      label: node.label,
      disabled: disabled,
      onValueChange: (bool newValue, BcChangeMeta _) {
        store.set(name, newValue);
      },
    );
  }
}
