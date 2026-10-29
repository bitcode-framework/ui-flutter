library bc_field_duration;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/types.dart';

/// Multi-segment duration input (ADR-011 Phase 5b.2).
///
/// Mirrors the TS `BcFieldDuration` contract: a composite field composed of
/// two or three [TextFormField] segments (hours:minutes[:seconds]) with up/down
/// stepper buttons. The value is the total elapsed seconds as an int.
///
/// Controlled `value` drives the displayed segments; `defaultValue` seeds
/// uncontrolled state. [onValueChange] fires with one of:
///   * [BcChangeReason.input] — direct text entry in a segment
///   * [BcChangeReason.increment] — up button or ArrowUp on focused segment
///   * [BcChangeReason.decrement] — down button or ArrowDown on focused segment
///   * [BcChangeReason.clear] — clear button
///   * [BcChangeReason.programmatic] — external `value` prop change
///
/// Segment overflow rolls over (entering 60 in minutes rolls to 1h 0m).
/// `maxHours` caps the total value; `step` (seconds) sizes stepper deltas.
class BcFieldDuration extends StatefulWidget {
  final String? name;
  final String? label;
  final num? value;
  final num? defaultValue;
  final String? placeholder;
  final bool? disabled;
  final bool? required;
  final bool? readonly;
  final bool? showSeconds;
  final num? maxHours;
  final num? step;
  final BcComponentSize? size;
  final String? hint;
  final String? description;
  final bool? clearable;
  final String? className;
  final Map<String, dynamic>? slotProps;
  final BcChangeHandler<num>? onValueChange;
  final void Function(dynamic)? onChange;

  const BcFieldDuration({
    super.key,
    this.name,
    this.label,
    this.value,
    this.defaultValue,
    this.placeholder,
    this.disabled,
    this.required,
    this.readonly,
    this.showSeconds,
    this.maxHours,
    this.step,
    this.size,
    this.hint,
    this.description,
    this.clearable,
    this.className,
    this.slotProps,
    this.onValueChange,
    this.onChange,
  });

  @override
  State<BcFieldDuration> createState() => _BcFieldDurationState();
}

class _BcFieldDurationState extends State<BcFieldDuration> {
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;
  late final TextEditingController _secondsController;
  late final FocusNode _hoursFocus;
  late final FocusNode _minutesFocus;
  late final FocusNode _secondsFocus;

  late int _internalValue;
  bool _isControlled = false;
  int? _lastWidgetValue;

  static const String _rootKeyPrefix = 'bc-field-duration-';
  static const String _hoursKey = '${_rootKeyPrefix}hours';
  static const String _minutesKey = '${_rootKeyPrefix}minutes';
  static const String _secondsKey = '${_rootKeyPrefix}seconds';
  static const String _upKey = '${_rootKeyPrefix}up';
  static const String _downKey = '${_rootKeyPrefix}down';
  static const String _clearKey = '${_rootKeyPrefix}clear';

  @override
  void initState() {
    super.initState();
    _isControlled = widget.value != null;
    _internalValue = _coerce(widget.value ?? widget.defaultValue ?? 0);
    _lastWidgetValue = _isControlled ? _internalValue : null;
    _hoursController = TextEditingController(text: _formatSegment(_hoursOf(_internalValue), _internalValue));
    _minutesController =
        TextEditingController(text: _formatSegment(_minutesOf(_internalValue), _internalValue));
    _secondsController =
        TextEditingController(text: _formatSegment(_secondsOf(_internalValue), _internalValue));
    _hoursFocus = FocusNode(debugLabel: 'BcFieldDuration.hours');
    _minutesFocus = FocusNode(debugLabel: 'BcFieldDuration.minutes');
    _secondsFocus = FocusNode(debugLabel: 'BcFieldDuration.seconds');
  }

  @override
  void didUpdateWidget(BcFieldDuration oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasControlled = oldWidget.value != null;
    _isControlled = widget.value != null;
    if (_isControlled) {
      final next = _coerce(widget.value!);
      if (next != _lastWidgetValue) {
        _lastWidgetValue = next;
        _internalValue = next;
        _syncControllers();
        _emit(next, BcChangeReason.programmatic);
      }
    } else if (!wasControlled && widget.defaultValue != null) {
      final next = _coerce(widget.defaultValue!);
      if (next != _internalValue) {
        _internalValue = next;
        _syncControllers();
      }
    }
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    _hoursFocus.dispose();
    _minutesFocus.dispose();
    _secondsFocus.dispose();
    super.dispose();
  }

  bool get _isDisabled => widget.disabled ?? false;
  bool get _isReadonly => widget.readonly ?? false;
  bool get _showSeconds => widget.showSeconds ?? false;
  int get _step => _coerce(widget.step ?? 1);
  int get _maxSeconds =>
      widget.maxHours == null ? -1 : (widget.maxHours!.toInt() * 3600);

  int get _currentValue => _internalValue;

  int _clampValue(int value) {
    if (value < 0) return 0;
    if (_maxSeconds > 0 && value > _maxSeconds) return _maxSeconds;
    return value;
  }

  void _syncControllers() {
    final v = _internalValue;
    final h = _formatSegment(_hoursOf(v), v);
    final m = _formatSegment(_minutesOf(v), v);
    final s = _formatSegment(_secondsOf(v), v);
    if (_hoursController.text != h) _hoursController.text = h;
    if (_minutesController.text != m) _minutesController.text = m;
    if (_secondsController.text != s) _secondsController.text = s;
  }

  void _emit(int value, BcChangeReason reason) {
    final clamped = _clampValue(value);
    _lastWidgetValue = clamped;
    _internalValue = clamped;
    _syncControllers();
    final source = reason == BcChangeReason.programmatic
        ? BcEventSource.programmatic
        : reason == BcChangeReason.input
            ? BcEventSource.pointer
            : BcEventSource.pointer;
    widget.onValueChange?.call(
      clamped,
      BcChangeMeta(reason: reason, source: source),
    );
    widget.onChange?.call(clamped);
  }

  void _handleHoursChanged(String text) {
    final hours = _parseInt(text);
    final remaining = _currentValue - _hoursOf(_currentValue) * 3600;
    _emit(_clampValue(hours * 3600 + remaining), BcChangeReason.input);
  }

  void _handleMinutesChanged(String text) {
    final minutes = _parseInt(text);
    final base = _currentValue - _minutesOf(_currentValue) * 60;
    _emit(_clampValue(base + minutes * 60), BcChangeReason.input);
  }

  void _handleSecondsChanged(String text) {
    final seconds = _parseInt(text);
    final base = _currentValue - _secondsOf(_currentValue);
    _emit(_clampValue(base + seconds), BcChangeReason.input);
  }

  void _increment() {
    _emit(_currentValue + _step, BcChangeReason.increment);
  }

  void _decrement() {
    _emit(_currentValue - _step, BcChangeReason.decrement);
  }

  void _clear() {
    _emit(0, BcChangeReason.clear);
  }

  void _adjustFocusedSegment(int direction) {
    final reason = direction > 0
        ? BcChangeReason.increment
        : BcChangeReason.decrement;
    int delta = 0;
    if (_hoursFocus.hasFocus) {
      delta = direction * 3600;
    } else if (_minutesFocus.hasFocus) {
      delta = direction * 60;
    } else if (_secondsFocus.hasFocus) {
      delta = direction;
    } else {
      delta = direction * _step;
    }
    _emit(_currentValue + delta, reason);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (_isDisabled || _isReadonly) return KeyEventResult.ignored;
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp) {
      _adjustFocusedSegment(1);
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _adjustFocusedSegment(-1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  InputDecoration _segmentDecoration(String label) {
    final placeholder = widget.placeholder ?? '';
    return InputDecoration(
      hintText: placeholder.isEmpty ? null : placeholder,
      labelText: label,
      isDense: widget.size == BcComponentSize.sm,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      border: const OutlineInputBorder(),
    );
  }

  Widget _segment({
    required Key key,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required ValueChanged<String> onChanged,
  }) {
    return Focus(
      focusNode: focusNode,
      onKeyEvent: _handleKeyEvent,
      child: SizedBox(
        width: widget.size == BcComponentSize.sm ? 48 : 64,
        child: TextField(
          key: key,
          controller: controller,
          enabled: !_isDisabled,
          readOnly: _isReadonly,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: _segmentDecoration(label),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _stepperButton({
    required Key key,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      key: key,
      icon: Icon(icon, size: 18),
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool showClear =
        (widget.clearable ?? false) && _currentValue > 0 && !_isDisabled;

    final segments = <Widget>[
      _segment(
        key: const ValueKey<String>(_hoursKey),
        controller: _hoursController,
        focusNode: _hoursFocus,
        label: 'HH',
        onChanged: _handleHoursChanged,
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: Center(child: Text(':')),
      ),
      _segment(
        key: const ValueKey<String>(_minutesKey),
        controller: _minutesController,
        focusNode: _minutesFocus,
        label: 'MM',
        onChanged: _handleMinutesChanged,
      ),
    ];
    if (_showSeconds) {
      segments.add(const Padding(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: Center(child: Text(':')),
      ));
      segments.add(_segment(
        key: const ValueKey<String>(_secondsKey),
        controller: _secondsController,
        focusNode: _secondsFocus,
        label: 'SS',
        onChanged: _handleSecondsChanged,
      ));
    }

    final stepperEnabled = !_isDisabled && !_isReadonly;
    final controlRow = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ...segments,
        const SizedBox(width: 4),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _stepperButton(
              key: const ValueKey<String>(_upKey),
              icon: Icons.arrow_drop_up,
              onPressed: stepperEnabled ? _increment : null,
            ),
            _stepperButton(
              key: const ValueKey<String>(_downKey),
              icon: Icons.arrow_drop_down,
              onPressed: stepperEnabled ? _decrement : null,
            ),
          ],
        ),
        if (showClear)
          _stepperButton(
            key: const ValueKey<String>(_clearKey),
            icon: Icons.close,
            onPressed: _clear,
          ),
      ],
    );

    final fieldKey = ValueKey<String>('$_rootKeyPrefix${widget.name ?? ''}');

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget.label!,
                  style: theme.textTheme.labelMedium,
                ),
                if (widget.required ?? false)
                  const Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: Text('*', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        KeyedSubtree(key: fieldKey, child: controlRow),
        if (widget.description != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              widget.description!,
              style: theme.textTheme.bodySmall,
            ),
          ),
        if (widget.hint != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              widget.hint!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
      ],
    );

    return Semantics(
      container: true,
      child: body,
    );
  }
}

int _coerce(num n) => n.toInt();

int _parseInt(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return 0;
  return int.tryParse(trimmed) ?? 0;
}

int _hoursOf(int total) => total ~/ 3600;

int _minutesOf(int total) => (total % 3600) ~/ 60;

int _secondsOf(int total) => total % 60;

String _formatSegment(int n, int total) {
  if (n == 0 && total == 0) return '';
  return n.toString();
}
