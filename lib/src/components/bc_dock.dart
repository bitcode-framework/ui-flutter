library bc_dock;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Dockable panel with a dock/detach toggle.
///
/// Mirrors the validation contract for BcDock: wraps [child] content in a
/// panel that can be toggled between docked and detached states. The toggle
/// control at the top-right of the panel reflects the current mode and
/// invokes [onDockChange] with the boolean docked state and a
/// [BcChangeMeta] on each transition.
///
/// Supports controlled ([docked]) and uncontrolled ([defaultDocked]) modes.
/// When `docked` is controlled, tapping the toggle does not change the
/// visible state until the parent updates `docked`; `onDockChange` still
/// fires with meta.
///
/// When [disabled] is true, the toggle is non-interactive but the panel
/// content remains fully interactive.
///
/// Platform-aware: uses PlatformIconButton on iOS (Cupertino), Material
/// IconButton elsewhere.
class BcDock extends StatefulWidget {
  /// The panel content.
  final Widget child;

  /// Controlled docked state. When non-null, the widget is controlled.
  final bool? docked;

  /// Initial docked state for uncontrolled mode.
  final bool defaultDocked;

  /// Whether the toggle is disabled (content remains interactive).
  final bool disabled;

  /// Called on each dock/detach transition.
  final BcChangeHandler<bool>? onDockChange;

  const BcDock({
    super.key,
    required this.child,
    this.docked,
    this.defaultDocked = false,
    this.disabled = false,
    this.onDockChange,
  });

  @override
  State<BcDock> createState() => _BcDockState();
}

class _BcDockState extends State<BcDock> {
  bool _internalDocked = false;

  bool get _isControlled => widget.docked != null;

  bool get _isDocked => _isControlled ? widget.docked! : _internalDocked;

  @override
  void initState() {
    super.initState();
    _internalDocked = widget.defaultDocked;
  }

  void _toggle() {
    if (widget.disabled) return;

    final newValue = !_isDocked;

    if (!_isControlled) {
      setState(() => _internalDocked = newValue);
    }

    widget.onDockChange?.call(
      newValue,
      const BcChangeMeta(
        reason: BcChangeReason.toggle,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: BcTheme.border),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: BcTheme.card,
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: BcTheme.border),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildToggle(),
                ],
              ),
            ),
            Flexible(child: widget.child),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle() {
    final icon = _isDocked ? Icons.dock : Icons.dock_outlined;
    final label = _isDocked ? 'Detach' : 'Dock';
    final iconColor = widget.disabled
        ? BcTheme.mutedForeground.withValues(alpha: 0.5)
        : BcTheme.primary;

    return PlatformWidget(
      material: (ctx, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: widget.disabled
                  ? BcTheme.mutedForeground.withValues(alpha: 0.5)
                  : BcTheme.mutedForeground,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            key: const Key('bc-dock-toggle'),
            onPressed: widget.disabled ? null : _toggle,
            icon: Icon(icon, color: iconColor),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          ),
        ],
      ),
      cupertino: (ctx, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: widget.disabled
                  ? BcTheme.mutedForeground.withValues(alpha: 0.5)
                  : BcTheme.mutedForeground,
            ),
          ),
          const SizedBox(width: 4),
          CupertinoButton(
            key: const Key('bc-dock-toggle'),
            onPressed: widget.disabled ? null : _toggle,
            padding: EdgeInsets.zero,
            minimumSize: const Size(36, 36),
            child: Icon(icon, color: iconColor),
          ),
        ],
      ),
    );
  }
}
