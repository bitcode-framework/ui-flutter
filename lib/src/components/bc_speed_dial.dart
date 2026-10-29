library bc_speed_dial;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Placement of the speed dial on the viewport.
///
/// Mirrors TS `BcSpeedDialPlacement`.
enum BcSpeedDialPlacement {
  bottomRight,
  bottomLeft,
  topRight,
  topLeft,
}

/// Direction in which sub-actions expand relative to the FAB.
///
/// Mirrors TS `BcSpeedDialDirection`.
enum BcSpeedDialDirection { up, down }

/// A single sub-action in a [BcSpeedDial].
///
/// Mirrors the TS `BcSpeedDialAction` interface. [key] identifies the
/// action, [label] is displayed text, [icon] is an optional leading icon,
/// and [disabled] prevents interaction.
class BcSpeedDialAction {
  final String key;
  final String label;
  final IconData? icon;
  final bool disabled;

  const BcSpeedDialAction({
    required this.key,
    required this.label,
    this.icon,
    this.disabled = false,
  });
}

/// Floating action button that expands into a list of sub-actions.
///
/// Mirrors the validation contract for BcSpeedDial: in its collapsed state
/// it renders a single floating action button (FAB). Activating it expands
/// the dial to reveal each entry in [actions] as a sub-action. A second
/// activation collapses the dial back to the resting FAB.
///
/// Selecting a sub-action invokes [onSelect] with the action and a
/// [BcChangeMeta], then collapses the dial. Non-selected actions are not
/// emitted.
///
/// Controlled mode: the parent manages [expanded]; toggling via the UI
/// calls [onExpandedChange] with a [BcChangeMeta] but does not mutate
/// internal state until the parent updates [expanded]. This provides a
/// single source of truth.
///
/// Uncontrolled mode: [expanded] is null and [defaultExpanded] seeds the
/// initial state; tapping the FAB toggles internal state.
class BcSpeedDial extends StatefulWidget {
  /// Primary FAB label (used for accessibility).
  final String label;

  /// Primary FAB icon.
  final IconData icon;

  /// Expanded list of sub-actions.
  final List<BcSpeedDialAction> actions;

  /// Controlled expanded state. When non-null, the widget is controlled.
  final bool? expanded;

  /// Initial expanded state for uncontrolled mode.
  final bool defaultExpanded;

  /// Placement of the speed dial on the viewport.
  final BcSpeedDialPlacement placement;

  /// Direction in which sub-actions expand relative to the FAB.
  final BcSpeedDialDirection direction;

  /// Called when the FAB is toggled (expand/collapse). Carries the new
  /// expanded state and a [BcChangeMeta].
  final BcChangeHandler<bool>? onExpandedChange;

  /// Called when a sub-action is selected. Carries the action and a
  /// [BcChangeMeta].
  final void Function(BcSpeedDialAction action, BcChangeMeta meta)? onSelect;

  const BcSpeedDial({
    super.key,
    this.label = 'Menu',
    this.icon = Icons.add,
    this.actions = const [],
    this.expanded,
    this.defaultExpanded = false,
    this.placement = BcSpeedDialPlacement.bottomRight,
    this.direction = BcSpeedDialDirection.up,
    this.onExpandedChange,
    this.onSelect,
  });

  @override
  State<BcSpeedDial> createState() => _BcSpeedDialState();
}

class _BcSpeedDialState extends State<BcSpeedDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;
  late Animation<double> _itemsAnimation;
  bool _internalExpanded = false;

  bool get _isControlled => widget.expanded != null;

  bool get _isExpanded => _isControlled ? widget.expanded! : _internalExpanded;

  @override
  void initState() {
    super.initState();
    _internalExpanded = widget.defaultExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: _internalExpanded ? 1.0 : 0.0,
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _itemsAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant BcSpeedDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    final targetExpanded = _isExpanded;
    if (targetExpanded && _controller.value < 1.0) {
      _controller.forward();
    } else if (!targetExpanded && _controller.value > 0.0) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _setExpanded(bool value, BcChangeMeta meta) {
    if (!_isControlled) {
      setState(() => _internalExpanded = value);
    }
    if (value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    widget.onExpandedChange?.call(value, meta);
  }

  void _handleFabTap() {
    _setExpanded(
      !_isExpanded,
      const BcChangeMeta(
        reason: BcChangeReason.toggle,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _handleActionTap(BcSpeedDialAction action) {
    if (action.disabled) return;
    const meta = BcChangeMeta(
      reason: BcChangeReason.select,
      source: BcEventSource.pointer,
    );
    widget.onSelect?.call(action, meta);
    _setExpanded(false, meta);
  }

  Alignment _placementAlignment() {
    switch (widget.placement) {
      case BcSpeedDialPlacement.bottomRight:
        return Alignment.bottomRight;
      case BcSpeedDialPlacement.bottomLeft:
        return Alignment.bottomLeft;
      case BcSpeedDialPlacement.topRight:
        return Alignment.topRight;
      case BcSpeedDialPlacement.topLeft:
        return Alignment.topLeft;
    }
  }

  Widget _buildActionLabel(BcSpeedDialAction action, int index) {
    final isDisabled = action.disabled;

    final labelColor = isDisabled
        ? BcTheme.mutedForeground.withValues(alpha: 0.5)
        : BcTheme.secondaryForeground;

    final pill = Container(
      key: ValueKey<String>('bc-speed-dial-action-${action.key}'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: BcTheme.secondary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (action.icon != null) ...[
            Icon(action.icon, size: 16, color: labelColor),
            const SizedBox(width: 6),
          ],
          Text(
            action.label,
            style: TextStyle(fontSize: 12, color: labelColor),
          ),
        ],
      ),
    );

    final opacity = Curves.easeOut.transform(
      (_itemsAnimation.value - index * 0.1).clamp(0.0, 1.0),
    );
    final slideOffset = (1.0 - (_itemsAnimation.value * 0.5 + 0.5)) * 20;

    final positionedLabel = Transform.translate(
      offset: Offset(0, widget.direction == BcSpeedDialDirection.up
          ? slideOffset
          : -slideOffset),
      child: Opacity(
        opacity: opacity,
        child: isDisabled
            ? pill
            : GestureDetector(
                onTap: () => _handleActionTap(action),
                child: pill,
              ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: positionedLabel,
    );
  }

  Widget _buildActions() {
    if (!_isExpanded || widget.actions.isEmpty) {
      return const SizedBox.shrink();
    }

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      key: const Key('bc-speed-dial-actions'),
      children: widget.actions.asMap().entries.map((entry) {
        return _buildActionLabel(entry.value, entry.key);
      }).toList(),
    );

    if (widget.direction == BcSpeedDialDirection.down) {
      return column;
    }

    return column;
  }

  Widget _buildFab() {
    return Container(
      key: const Key('bc-speed-dial-fab'),
      decoration: const BoxDecoration(
        color: BcTheme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('bc-speed-dial-trigger'),
          customBorder: const CircleBorder(),
          onTap: _handleFabTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: RotationTransition(
                turns: _rotateAnimation,
                child: Icon(
                  widget.icon,
                  color: BcTheme.primaryForeground,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions = _buildActions();
    final fab = _buildFab();

    final column = widget.direction == BcSpeedDialDirection.up
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [actions, const SizedBox(height: 12), fab],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [fab, const SizedBox(height: 12), actions],
          );

    return Align(
      alignment: _placementAlignment(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: column,
      ),
    );
  }
}
