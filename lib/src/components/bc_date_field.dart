library bc_date_field;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';

/// Adaptive date picker field (ADR-011 Section 5).
/// Material: showDatePicker. Cupertino: showCupertinoModalPopup with CupertinoDatePicker.
class BcDateField extends StatefulWidget {
  final String? name;
  final DateTime? value;
  final DateTime? defaultValue;
  final BcChangeHandler<DateTime>? onValueChange;
  final bool disabled;
  final String? label;
  final String? placeholder;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const BcDateField({
    super.key,
    this.name,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.disabled = false,
    this.label,
    this.placeholder,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<BcDateField> createState() => _BcDateFieldState();
}

class _BcDateFieldState extends State<BcDateField> {
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.value ?? widget.defaultValue;
  }

  @override
  void didUpdateWidget(BcDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _selected = widget.value;
    }
  }

  String get _text {
    if (_selected == null) return widget.placeholder ?? '';
    return '${_selected!.year}-${_selected!.month.toString().padLeft(2, '0')}-${_selected!.day.toString().padLeft(2, '0')}';
  }

  void _emit(DateTime date) {
    setState(() => _selected = date);
    widget.onValueChange?.call(
      date,
      const BcChangeMeta(reason: BcChangeReason.select),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => InkWell(
        onTap: widget.disabled ? null : () => _showMaterialPicker(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.placeholder,
            border: const OutlineInputBorder(),
          ),
          child: Text(_text),
        ),
      ),
      cupertino: (context, platform) => GestureDetector(
        onTap: widget.disabled ? null : () => _showCupertinoPicker(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.separator),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(_text,
              style: TextStyle(
                  color: _selected != null
                      ? CupertinoColors.label
                      : CupertinoColors.placeholderText)),
        ),
      ),
    );
  }

  Future<void> _showMaterialPicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
    );
    if (picked != null) _emit(picked);
  }

  void _showCupertinoPicker(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: _selected ?? DateTime.now(),
          minimumDate: widget.firstDate,
          maximumDate: widget.lastDate,
          onDateTimeChanged: (date) => _emit(date),
        ),
      ),
    );
  }
}
