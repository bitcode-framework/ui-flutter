library bc_steps;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Orientation of the stepper.
enum BcStepsOrientation { horizontal, vertical }

/// Stepper / wizard navigation (ADR-011 Phase 5c — M1 display).
///
/// Renders a sequence of step nodes connected by a progress line. The
/// [current] index marks the active step (highlighted). Steps before
/// [current] render as completed (check icon). When [clickable] is true,
/// each step header is tappable and fires [onStepChange] with the index
/// and a [BcChangeMeta] whose source is [BcEventSource.pointer].
///
/// Controlled mode: the parent provides [current]; tapping a step fires
/// the callback but does not change the displayed step until the parent
/// updates the prop. Uncontrolled mode: [current] is null and
/// [defaultCurrent] seeds the initial state; tapping updates internally.
///
/// Steps listed in [disabledSteps] are non-interactive and render at
/// reduced opacity.
class BcSteps extends StatefulWidget {
  final List<String> steps;
  final int? current;
  final int? defaultCurrent;
  final BcStepsOrientation orientation;
  final bool clickable;
  final List<int> disabledSteps;
  final void Function(int index, BcChangeMeta meta)? onStepChange;

  const BcSteps({
    super.key,
    required this.steps,
    this.current,
    this.defaultCurrent,
    this.orientation = BcStepsOrientation.horizontal,
    this.clickable = false,
    this.disabledSteps = const [],
    this.onStepChange,
  });

  @override
  State<BcSteps> createState() => _BcStepsState();
}

class _BcStepsState extends State<BcSteps> {
  int? _internalCurrent;

  @override
  void initState() {
    super.initState();
    if (widget.current == null) {
      _internalCurrent = widget.defaultCurrent ?? 0;
    }
  }

  @override
  void didUpdateWidget(BcSteps oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.current == null && oldWidget.current != null) {
      _internalCurrent = widget.defaultCurrent ?? 0;
    }
  }

  int get _current {
    final c = widget.current ?? _internalCurrent ?? 0;
    if (c < 0) return 0;
    if (c >= widget.steps.length) return widget.steps.length - 1;
    return c;
  }

  bool _isDisabled(int index) => widget.disabledSteps.contains(index);

  void _handleTap(int index) {
    if (_isDisabled(index)) return;

    const meta = BcChangeMeta(
      reason: BcChangeReason.select,
      source: BcEventSource.pointer,
    );

    widget.onStepChange?.call(index, meta);

    if (widget.current == null) {
      setState(() {
        _internalCurrent = index;
      });
    }
  }

  Color _circleColor(int index, int current) {
    if (_isDisabled(index)) {
      return BcTheme.muted;
    }
    if (index < current) {
      return BcTheme.primary;
    }
    if (index == current) {
      return BcTheme.primary;
    }
    return BcTheme.muted;
  }

  Color _circleTextColor(int index, int current) {
    if (index <= current && !_isDisabled(index)) {
      return BcTheme.primaryForeground;
    }
    return BcTheme.mutedForeground;
  }

  Widget _buildCircle(int index, int current) {
    final isCompleted = index < current;
    final isCurrent = index == current;

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: _circleColor(index, current),
        shape: BoxShape.circle,
        border: isCurrent && !_isDisabled(index)
            ? Border.all(color: BcTheme.ring, width: 2)
            : null,
      ),
      child: Center(
        child: isCompleted && !_isDisabled(index)
            ? const Icon(Icons.check, size: 16, color: BcTheme.primaryForeground)
            : Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _circleTextColor(index, current),
                ),
              ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, int index, int current) {
    final isActive = index == current && !_isDisabled(index);
    return Text(
      widget.steps[index],
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: _isDisabled(index)
                ? BcTheme.mutedForeground
                : isActive
                    ? BcTheme.foreground
                    : BcTheme.mutedForeground,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
    );
  }

  Widget _buildConnector(bool active) {
    return Container(
      height: 2,
      color: active ? BcTheme.primary : BcTheme.border,
    );
  }

  Widget _buildStepHeader(BuildContext context, int index, int current) {
    final circle = _buildCircle(index, current);
    final label = _buildLabel(context, index, current);

    final content = widget.orientation == BcStepsOrientation.horizontal
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              circle,
              const SizedBox(height: 4),
              label,
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              circle,
              const SizedBox(width: 8),
              label,
            ],
          );

    if (widget.clickable && !_isDisabled(index)) {
      return InkWell(
        onTap: () => _handleTap(index),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: content,
        ),
      );
    }

    return Opacity(
      opacity: _isDisabled(index) ? 0.5 : 1.0,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) {
      return const SizedBox.shrink();
    }

    final current = _current;

    if (widget.orientation == BcStepsOrientation.vertical) {
      final children = <Widget>[];
      for (var i = 0; i < widget.steps.length; i++) {
        children.add(_buildStepHeader(context, i, current));
        if (i < widget.steps.length - 1) {
          children.add(
            Padding(
              padding: const EdgeInsets.only(left: 13, top: 4, bottom: 4),
              child: Container(
                width: 2,
                height: 24,
                color: i < current ? BcTheme.primary : BcTheme.border,
              ),
            ),
          );
        }
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }

    final rowChildren = <Widget>[];
    for (var i = 0; i < widget.steps.length; i++) {
      rowChildren.add(_buildStepHeader(context, i, current));
      if (i < widget.steps.length - 1) {
        final connectorActive = i < current;
        rowChildren.add(
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 14, left: 4, right: 4),
              child: _buildConnector(connectorActive),
            ),
          ),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rowChildren,
    );
  }
}
