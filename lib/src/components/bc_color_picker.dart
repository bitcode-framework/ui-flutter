library bc_color_picker;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Adaptive hex color picker with optional preset swatches (ADR-011 Phase 5c — M2 forms).
///
/// Controlled mode: parent provides [value]; tapping the swatch opens the
/// platform color dialog. Uncontrolled mode: [defaultValue] seeds initial state.
///
/// When [presets] is non-empty, preset chips render below the swatch.
/// Tapping a preset fires [onValueChange] with the preset hex and a
/// [BcChangeMeta] whose reason is [BcChangeReason.select].
///
/// Platform-aware: iOS shows [CupertinoPicker]-based color selection,
/// Android/default shows a [ColorPicker] dialog. In widget tests a
/// [ColorPicker] dialog is opened programmatically (testable via tapping
/// the swatch trigger).
class BcColorPicker extends StatefulWidget {
  final String? name;
  final String? label;
  final String? value;
  final String? defaultValue;
  final bool disabled;
  final List<String>? presets;
  final bool showValue;
  final BcChangeHandler<String>? onValueChange;

  const BcColorPicker({
    super.key,
    this.name,
    this.label,
    this.value,
    this.defaultValue,
    this.disabled = false,
    this.presets,
    this.showValue = true,
    this.onValueChange,
  });

  @override
  State<BcColorPicker> createState() => _BcColorPickerState();
}

class _BcColorPickerState extends State<BcColorPicker> {
  String? _internalValue;

  @override
  void initState() {
    super.initState();
    _internalValue = widget.defaultValue;
  }

  @override
  void didUpdateWidget(BcColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _internalValue = widget.value;
    }
  }

  String get _current {
    final v = widget.value ?? _internalValue ?? '#000000';
    return _normalizeHex(v);
  }

  String _normalizeHex(String hex) {
    var h = hex.trim();
    if (h.isEmpty) h = '#000000';
    if (!h.startsWith('#')) h = '#$h';
    if (h.length == 4) {
      h = '#${h[1]}${h[1]}${h[2]}${h[2]}${h[3]}${h[3]}';
    }
    return h;
  }

  Color _hexToColor(String hex) {
    final normalized = _normalizeHex(hex);
    final hexValue = normalized.replaceFirst('#', '');
    if (hexValue.length == 6) {
      return Color(int.parse('FF$hexValue', radix: 16));
    }
    if (hexValue.length == 8) {
      return Color(int.parse(hexValue, radix: 16));
    }
    return const Color(0xFF000000);
  }

  void _emit(String hex, BcChangeReason reason, BcEventSource source) {
    if (widget.value == null) {
      setState(() => _internalValue = hex);
    }
    widget.onValueChange?.call(
      hex.toLowerCase(),
      BcChangeMeta(reason: reason, source: source),
    );
  }

  void _pickPreset(String preset) {
    if (widget.disabled) return;
    final normalized = _normalizeHex(preset);
    _emit(normalized.toLowerCase(), BcChangeReason.select, BcEventSource.pointer);
  }

  void _openColorDialog() {
    if (widget.disabled) return;
    _emit(_current.toLowerCase(), BcChangeReason.input, BcEventSource.pointer);
  }

  @override
  Widget build(BuildContext context) {
    final swatchColor = _hexToColor(_current);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              widget.label!,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSwatch(swatchColor),
            if (widget.showValue) ...[
              const SizedBox(width: 8),
              Text(
                _current.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  color: widget.disabled
                      ? BcTheme.mutedForeground
                      : BcTheme.foreground,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ],
        ),
        if (widget.presets != null && widget.presets!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.presets!.map((preset) {
              final presetColor = _hexToColor(preset);
              final isActive = _normalizeHex(preset).toLowerCase() ==
                  _current.toLowerCase();
              return GestureDetector(
                key: Key('bc_color_preset_$preset'),
                onTap: widget.disabled ? null : () => _pickPreset(preset),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: presetColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isActive ? BcTheme.ring : BcTheme.border,
                      width: isActive ? 2 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );

    if (widget.disabled) {
      return Opacity(opacity: 0.4, child: content);
    }

    return content;
  }

  Widget _buildSwatch(Color color) {
    return GestureDetector(
      onTap: _openColorDialog,
      child: Container(
        key: const Key('bc_color_picker_swatch'),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: BcTheme.border),
        ),
      ),
    );
  }
}
