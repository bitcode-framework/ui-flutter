library bc_time_field;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';

/// Adaptive time picker field (ADR-011 Section 5).
/// Material: showTimePicker. Cupertino: showCupertinoModalPopup with CupertinoDatePicker(mode: time).
class BcTimeField extends StatefulWidget {
  final String? name;
  final TimeOfDay? value;
  final TimeOfDay? defaultValue;
  final BcChangeHandler<TimeOfDay>? onValueChange;
  final bool disabled;
  final String? label;
  final String? placeholder;

  const BcTimeField({
    super.key,
    this.name,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.disabled = false,
    this.label,
    this.placeholder,
  });

  @override
  State<BcTimeField> createState() => _BcTimeFieldState();
}

class _BcTimeFieldState extends State<BcTimeField> {
  TimeOfDay? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.value ?? widget.defaultValue;
  }

  @override
  void didUpdateWidget(BcTimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _selected = widget.value;
    }
  }

  String get _text {
    if (_selected == null) return widget.placeholder ?? '';
    final h = _selected!.hour.toString().padLeft(2, '0');
    final m = _selected!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _emit(TimeOfDay time) {
    setState(() => _selected = time);
    widget.onValueChange?.call(
      time,
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
    final picked = await showTimePicker(
      context: context,
      initialTime: _selected ?? TimeOfDay.now(),
    );
    if (picked != null) _emit(picked);
  }

  void _showCupertinoPicker(BuildContext context) {
    final now = DateTime.now();
    final initial = _selected != null
        ? DateTime(now.year, now.month, now.day, _selected!.hour, _selected!.minute)
        : now;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          initialDateTime: initial,
          onDateTimeChanged: (dt) => _emit(TimeOfDay(hour: dt.hour, minute: dt.minute)),
        ),
      ),
    );
  }
}
