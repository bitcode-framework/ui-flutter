library bc_field_morph;

import 'package:flutter/material.dart';
import '../core/types.dart';
import 'bc_input.dart';
import 'bc_select.dart';
import 'bc_number_field.dart';
import 'bc_date_field.dart';
import 'bc_checkbox.dart';

class BcFieldMorph extends StatefulWidget {
  final String? name;
  final String? label;
  final BcFieldMorphValue? value;
  final BcFieldMorphValue? defaultValue;
  final List<BcFieldMorphType>? types;
  final bool? disabled;
  final bool? required_;
  final bool? readonly;
  final String? placeholder;
  final bool? clearable;
  final String? hint;
  final String? description;
  final String? className;
  final BcChangeHandler<BcFieldMorphValue>? onValueChange;
  final void Function(BcFieldMorphValue)? onChange;

  const BcFieldMorph({
    super.key,
    this.name,
    this.label,
    this.value,
    this.defaultValue,
    this.types,
    this.disabled,
    this.required_,
    this.readonly,
    this.placeholder,
    this.clearable,
    this.hint,
    this.description,
    this.className,
    this.onValueChange,
    this.onChange,
  });

  @override
  State<BcFieldMorph> createState() => BcFieldMorphState();
}

class BcFieldMorphState extends State<BcFieldMorph> {
  late BcFieldMorphValue _internalValue;

  BcFieldMorphValue get currentValue => _internalValue;

  bool get _isControlled => widget.value != null;

  bool get _isDisabled => widget.disabled == true;

  bool get _isReadonly => widget.readonly == true;

  bool get _isClearable => widget.clearable == true;

  String get _selectedType => _internalValue.type;

  List<BcFieldMorphType> get _types => widget.types ?? const [];

  BcFieldMorphType? get _activeType {
    final matching =
        _types.where((t) => t.value == _selectedType).toList();
    return matching.isNotEmpty ? matching.first : null;
  }

  bool get _hasValue {
    if (_selectedType.isEmpty) return false;
    return _internalValue.value != null;
  }

  @override
  void initState() {
    super.initState();
    _internalValue = (widget.value ?? widget.defaultValue) ??
        const BcFieldMorphValue(type: '', value: null);
  }

  @override
  void didUpdateWidget(BcFieldMorph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isControlled) {
      final newValue = widget.value!;
      if (newValue != _internalValue) {
        _internalValue = newValue;
      }
    }
  }

  void _emit(
    BcFieldMorphValue val, {
    BcChangeReason reason = BcChangeReason.valueChange,
    BcEventSource source = BcEventSource.programmatic,
  }) {
    if (!_isControlled) {
      setState(() => _internalValue = val);
    }
    widget.onValueChange?.call(
      val,
      BcChangeMeta(reason: reason, source: source),
    );
    widget.onChange?.call(val);
  }

  void _onTypeSelected(String? typeValue) {
    if (typeValue == null || typeValue == _selectedType) return;

    final sourceKind = _activeType?.widget;
    final morphValue = _coerceForType(typeValue, _internalValue.value, sourceKind);

    _emit(
      BcFieldMorphValue(type: typeValue, value: morphValue),
      reason: BcChangeReason.typeChange,
      source: BcEventSource.pointer,
    );
  }

  Object? _coerceForType(
      String newType, Object? oldValue, String? sourceKind) {
    final typeDef = _types.where((t) => t.value == newType).toList();
    if (typeDef.isEmpty) return null;
    final kind = typeDef.first.widget;

    if (oldValue == null) return null;

    final compatible = _areKindsCompatible(sourceKind, kind);
    if (!compatible) return null;

    switch (kind) {
      case 'text':
        if (oldValue is String) return oldValue;
        if (oldValue is num) return oldValue.toString();
        return null;
      case 'number':
        if (oldValue is num) return oldValue;
        if (oldValue is String) {
          return num.tryParse(oldValue);
        }
        return null;
      default:
        return null;
    }
  }

  bool _areKindsCompatible(String? sourceKind, String targetKind) {
    if (sourceKind == null) return false;
    if (sourceKind == targetKind) return true;
    const textNumber = {'text', 'number'};
    if (textNumber.contains(sourceKind) && textNumber.contains(targetKind)) {
      return true;
    }
    return false;
  }

  void _onChildValueChanged(Object? childValue) {
    _emit(
      BcFieldMorphValue(type: _selectedType, value: childValue),
      reason: BcChangeReason.valueChange,
      source: BcEventSource.pointer,
    );
  }

  void reset() {
    setState(() {
      _internalValue = const BcFieldMorphValue(type: '', value: null);
    });
  }

  void clear() {
    _emit(
      const BcFieldMorphValue(type: '', value: null),
      reason: BcChangeReason.clear,
      source: BcEventSource.pointer,
    );
  }

  Widget _buildTypeSelector() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedType.isEmpty ? null : _selectedType,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      hint: const Text('Select type'),
      items: _types
          .map((t) => DropdownMenuItem<String>(
                value: t.value,
                child: Text(t.label),
              ))
          .toList(),
      onChanged: (_isDisabled || _isReadonly) ? null : _onTypeSelected,
    );
  }

  Widget _buildValueControl() {
    final active = _activeType;
    if (active == null) {
      return const SizedBox.shrink();
    }

    final kind = active.widget;
    final childValue = _internalValue.value;

    switch (kind) {
      case 'text':
        final textValue = childValue is String ? childValue : null;
        return BcInput(
          value: textValue,
          disabled: _isDisabled,
          readOnly: _isReadonly,
          placeholder: widget.placeholder,
          onValueChange: (v, m) => _onChildValueChanged(v),
        );
      case 'number':
        final numValue = childValue is num ? childValue : null;
        return BcNumberField(
          value: numValue,
          disabled: _isDisabled,
          placeholder: widget.placeholder,
          onValueChange: (v, m) => _onChildValueChanged(v),
        );
      case 'date':
        DateTime? dateValue;
        if (childValue is String) {
          dateValue = DateTime.tryParse(childValue);
        } else if (childValue is DateTime) {
          dateValue = childValue;
        }
        return BcDateField(
          value: dateValue,
          disabled: _isDisabled,
          placeholder: widget.placeholder,
          onValueChange: (v, m) {
            final formatted =
                '${v.year}-${v.month.toString().padLeft(2, '0')}-${v.day.toString().padLeft(2, '0')}';
            _onChildValueChanged(formatted);
          },
        );
      case 'select':
        final options = active.options ?? const <BcFieldMorphOption>[];
        final selectValue = childValue is String ? childValue : null;
        return BcSelect<String>(
          value: selectValue,
          disabled: _isDisabled,
          options: options
              .map((o) => BcSelectOption<String>(
                    value: o.value,
                    label: o.label,
                  ))
              .toList(),
          onValueChange: (v, m) => _onChildValueChanged(v),
        );
      case 'boolean':
        final boolValue = childValue is bool ? childValue : false;
        return AbsorbPointer(
          absorbing: _isReadonly,
          child: BcCheckbox(
            value: boolValue,
            disabled: _isDisabled,
            onValueChange: (v, m) => _onChildValueChanged(v),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.label!,
                    style: theme.textTheme.labelMedium),
                if (widget.required_ == true)
                  const Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: Text('*',
                        style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        if (widget.hint != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(widget.hint!,
                style: theme.textTheme.bodySmall),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTypeSelector()),
            const SizedBox(width: 8),
            Expanded(child: _buildValueControl()),
            if (_isClearable && _hasValue && !_isDisabled && !_isReadonly) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: clear,
                tooltip: 'Clear',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
        if (widget.description != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(widget.description!,
                style: theme.textTheme.bodySmall),
          ),
      ],
    );

    return Semantics(
      label: 'Field Morph',
      container: true,
      child: body,
    );
  }
}
