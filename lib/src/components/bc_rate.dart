library bc_rate;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Star rating size variants.
enum BcRateSize { sm, md, lg }

/// Star rating input with click-to-clear (ADR-011 Phase 5c — M2 forms).
///
/// Renders [count] star icons. Clicking star N sets the rating to N.
/// Clicking the same star again clears the rating to 0 (toggles off).
///
/// Controlled mode: parent provides [value]; uncontrolled: [defaultValue].
///
/// When [disabled] is true, stars are non-interactive and rendered dimmed.
/// When [readonly] is true, stars are non-interactive but rendered at full
/// brightness (presentation-only).
class BcRate extends StatefulWidget {
  final String? name;
  final int? value;
  final int? defaultValue;
  final int count;
  final bool disabled;
  final bool readonly;
  final BcRateSize size;
  final BcChangeHandler<int>? onChange;

  const BcRate({
    super.key,
    this.name,
    this.value,
    this.defaultValue,
    this.count = 5,
    this.disabled = false,
    this.readonly = false,
    this.size = BcRateSize.md,
    this.onChange,
  });

  @override
  State<BcRate> createState() => _BcRateState();
}

class _BcRateState extends State<BcRate> {
  int _internalValue = 0;

  @override
  void initState() {
    super.initState();
    _internalValue = widget.defaultValue ?? 0;
  }

  @override
  void didUpdateWidget(BcRate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.defaultValue != oldWidget.defaultValue) {
      _internalValue = widget.defaultValue ?? 0;
    }
  }

  int get _current => widget.value ?? _internalValue;

  bool get _interactive => !widget.disabled && !widget.readonly;

  double get _starSize {
    switch (widget.size) {
      case BcRateSize.sm:
        return 16;
      case BcRateSize.lg:
        return 28;
      case BcRateSize.md:
        return 20;
    }
  }

  void _pick(int index) {
    if (!_interactive) return;

    final next = index == _current ? 0 : index;
    final reason =
        next == 0 ? BcChangeReason.deselect : BcChangeReason.select;

    if (widget.value == null) {
      setState(() => _internalValue = next);
    }

    widget.onChange?.call(
      next,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ).copyWith(reason: reason),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stars = <Widget>[];
    for (var i = 1; i <= widget.count; i++) {
      final isFilled = i <= _current;
      stars.add(_buildStar(i, isFilled));
    }

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < stars.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          stars[i],
        ],
      ],
    );

    if (widget.disabled) {
      return Opacity(opacity: 0.4, child: row);
    }

    return row;
  }

  Widget _buildStar(int index, bool isFilled) {
    final color = isFilled ? BcTheme.warning : BcTheme.mutedForeground.withValues(alpha: 0.4);

    final icon = Icon(
      Icons.star,
      size: _starSize,
      color: color,
    );

    if (!_interactive) {
      return Padding(
        key: Key('bc_rate_star_$index'),
        padding: const EdgeInsets.all(2),
        child: icon,
      );
    }

    return InkWell(
      key: Key('bc_rate_star_$index'),
      onTap: () => _pick(index),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Icon(
            Icons.star,
            size: _starSize,
            color: color,
          ),
        ),
      ),
    );
  }
}

extension on BcChangeMeta {
  BcChangeMeta copyWith({BcChangeReason? reason, BcEventSource? source}) {
    return BcChangeMeta(
      reason: reason ?? this.reason,
      source: source ?? this.source,
      nativeEvent: nativeEvent,
    );
  }
}
