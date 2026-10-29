library bc_color_swatch;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Grid of selectable color chips (ADR-011 Phase 5c — M7 misc).
///
/// Mirrors TS [BcColorSwatchContract] ({ color?, label?, selected?,
/// disabled?, onSelect? }).
///
/// Renders N color chips from [colors]. Tapping a chip selects it and
/// invokes [onValueChange] with the tapped color string and [BcChangeMeta].
/// The selected chip has a distinct visual state (checkmark or ring).
/// When [disabled] is true, tapping any chip does not invoke the callback
/// and chips render muted.
class BcColorSwatch extends StatefulWidget {
  final List<String> colors;
  final String? value;
  final String? defaultValue;
  final int crossAxisCount;
  final double spacing;
  final double chipSize;
  final bool disabled;
  final BcChangeHandler<String>? onValueChange;

  const BcColorSwatch({
    super.key,
    required this.colors,
    this.value,
    this.defaultValue,
    this.crossAxisCount = 6,
    this.spacing = 8,
    this.chipSize = 36,
    this.disabled = false,
    this.onValueChange,
  });

  @override
  State<BcColorSwatch> createState() => _BcColorSwatchState();
}

class _BcColorSwatchState extends State<BcColorSwatch> {
  String? _internal;

  @override
  void initState() {
    super.initState();
    _internal = widget.defaultValue;
  }

  @override
  void didUpdateWidget(BcColorSwatch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.defaultValue != oldWidget.defaultValue) {
      _internal = widget.defaultValue;
    }
  }

  String? get _current => widget.value ?? _internal;

  void _select(String color, int index) {
    if (widget.disabled) return;

    if (widget.value == null) {
      setState(() => _internal = color);
    }

    widget.onValueChange?.call(
      color,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
  }

  Color _parseColor(String hex) {
    var h = hex.replaceAll('#', '');
    if (h.length == 6) {
      h = 'FF$h';
    }
    try {
      return Color(int.parse(h, radix: 16));
    } catch (_) {
      return BcTheme.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.disabled) {
      return Opacity(
        opacity: 0.4,
        child: _buildGrid(),
      );
    }
    return _buildGrid();
  }

  Widget _buildGrid() {
    return Wrap(
      key: const Key('bc_color_swatch'),
      spacing: widget.spacing,
      runSpacing: widget.spacing,
      children: List.generate(widget.colors.length, (i) {
        final color = widget.colors[i];
        final isSelected = color == _current;
        return _buildChip(color, i, isSelected);
      }),
    );
  }

  Widget _buildChip(String colorStr, int index, bool isSelected) {
    final color = _parseColor(colorStr);

    return GestureDetector(
      key: Key('bc_color_swatch_chip_$index'),
      onTap: widget.disabled ? null : () => _select(colorStr, index),
      child: MouseRegion(
        cursor: widget.disabled
            ? MouseCursor.defer
            : SystemMouseCursors.click,
        child: Container(
          width: widget.chipSize,
          height: widget.chipSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? BcTheme.primary : BcTheme.border,
              width: isSelected ? 3 : 1,
            ),
          ),
          child: isSelected
              ? Icon(
                  Icons.check,
                  size: widget.chipSize * 0.5,
                  color: _contrastColor(color),
                )
              : null,
        ),
      ),
    );
  }

  Color _contrastColor(Color bg) {
    return bg.computeLuminance() > 0.5
        ? BcTheme.foreground
        : BcTheme.background;
  }
}
