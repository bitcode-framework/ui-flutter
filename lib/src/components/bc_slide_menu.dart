library bc_slide_menu;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// A single menu item in a [BcSlideMenu].
///
/// Mirrors the TS `BcSlideMenuItem` interface. [key] identifies the item,
/// [label] is displayed text, [icon] is an optional leading icon, and
/// [disabled] prevents interaction.
class BcSlideMenuItem {
  final String key;
  final String label;
  final IconData? icon;
  final bool disabled;

  const BcSlideMenuItem({
    required this.key,
    required this.label,
    this.icon,
    this.disabled = false,
  });
}

/// Slide-out drawer menu with scrim overlay.
///
/// Mirrors the validation contract for BcSlideMenu: a drawer panel that
/// slides in/out from the left edge. When open, a scrim overlay fades in
/// behind the drawer. Tapping the scrim closes the drawer. The drawer can
/// be opened via a trigger button.
///
/// Each open/close transition invokes [onOpenChange] with the boolean open
/// state and a [BcChangeMeta] whose source indicates the trigger (toggle,
/// scrim, or escape).
///
/// Supports controlled ([open]) and uncontrolled ([defaultOpen]) modes.
/// When `open` is controlled, tapping the scrim or toggle fires
/// [onOpenChange] but does not change visibility until the parent updates
/// `open`.
///
/// Platform-aware: uses PlatformIconButton for the close button on iOS
/// (Cupertino), Material elsewhere.
class BcSlideMenu extends StatefulWidget {
  /// Menu items to render in the drawer.
  final List<BcSlideMenuItem> items;

  /// The main content behind the drawer.
  final Widget child;

  /// Controlled open state. When non-null, the widget is controlled.
  final bool? open;

  /// Initial open state for uncontrolled mode.
  final bool defaultOpen;

  /// Width of the drawer panel.
  final double drawerWidth;

  /// Duration of the slide animation.
  final Duration animationDuration;

  /// Called on each open/close transition.
  final BcChangeHandler<bool>? onOpenChange;

  const BcSlideMenu({
    super.key,
    this.items = const [],
    required this.child,
    this.open,
    this.defaultOpen = false,
    this.drawerWidth = 250,
    this.animationDuration = const Duration(milliseconds: 250),
    this.onOpenChange,
  });

  @override
  State<BcSlideMenu> createState() => _BcSlideMenuState();
}

class _BcSlideMenuState extends State<BcSlideMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Offset> _slideAnimation;
  bool _internalOpen = false;

  bool get _isControlled => widget.open != null;

  bool get _isOpen => _isControlled ? widget.open! : _internalOpen;

  @override
  void initState() {
    super.initState();
    _internalOpen = widget.defaultOpen;
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
      value: _internalOpen ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(_animation);
    _controller.addListener(_onControllerChanged);
    _controller.addStatusListener(_onControllerStatusChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _onControllerStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      if (mounted) setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant BcSlideMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animationDuration != oldWidget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }
    final targetOpen = _isOpen;
    if (targetOpen && _controller.value < 1.0) {
      _controller.forward();
    } else if (!targetOpen && _controller.value > 0.0) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.removeStatusListener(_onControllerStatusChanged);
    _controller.dispose();
    super.dispose();
  }

  void _setOpen(bool value, BcChangeMeta meta) {
    if (!_isControlled) {
      setState(() => _internalOpen = value);
    }
    if (value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    widget.onOpenChange?.call(value, meta);
  }

  void _toggleFromTrigger() {
    _setOpen(
      !_isOpen,
      const BcChangeMeta(
        reason: BcChangeReason.toggle,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _closeFromScrim() {
    _setOpen(
      false,
      const BcChangeMeta(
        reason: BcChangeReason.overlayClick,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _closeFromEscape() {
    _setOpen(
      false,
      const BcChangeMeta(
        reason: BcChangeReason.escape,
        source: BcEventSource.keyboard,
      ),
    );
  }

  Widget _buildTrigger() {
    if (_isControlled) return const SizedBox.shrink();

    return Positioned(
      top: 16,
      left: 16,
      child: PlatformIconButton(
        key: const Key('bc-slide-menu-trigger'),
        material: (ctx, _) => MaterialIconButtonData(
          icon: const Icon(Icons.menu, color: BcTheme.foreground),
          onPressed: _toggleFromTrigger,
        ),
        cupertino: (ctx, _) => CupertinoIconButtonData(
          icon: const Icon(Icons.menu, color: BcTheme.foreground),
          onPressed: _toggleFromTrigger,
        ),
      ),
    );
  }

  Widget _buildScrim() {
    final opacity = 0.4 * _animation.value;
    return GestureDetector(
      key: const Key('bc-slide-menu-scrim'),
      onTap: _closeFromScrim,
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: Colors.black.withValues(alpha: opacity),
        constraints: const BoxConstraints.expand(),
      ),
    );
  }

  Widget _buildDrawer() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        key: const Key('bc-slide-menu-drawer'),
        width: widget.drawerWidth,
        decoration: const BoxDecoration(
          color: BcTheme.popover,
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 8,
              offset: Offset(2, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: BcTheme.border),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PlatformIconButton(
                      material: (ctx, _) => MaterialIconButtonData(
                        icon: const Icon(
                          Icons.close,
                          color: BcTheme.foreground,
                          size: 20,
                        ),
                        onPressed: _closeFromEscape,
                      ),
                      cupertino: (ctx, _) => CupertinoIconButtonData(
                        icon: const Icon(
                          Icons.close,
                          color: BcTheme.foreground,
                          size: 20,
                        ),
                        onPressed: _closeFromEscape,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: widget.items.map(_buildMenuItem).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BcSlideMenuItem item) {
    final textColor = item.disabled
        ? BcTheme.mutedForeground.withValues(alpha: 0.5)
        : BcTheme.popoverForeground;

    final content = Container(
      key: ValueKey<String>('slide-menu-item-${item.key}'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (item.icon != null) ...[
            Icon(item.icon, size: 18, color: textColor),
            const SizedBox(width: 12),
          ],
          Text(
            item.label,
            style: TextStyle(fontSize: 14, color: textColor),
          ),
        ],
      ),
    );

    return PlatformWidget(
      material: (ctx, _) => InkWell(
        onTap: item.disabled ? null : () => _selectItem(item),
        child: content,
      ),
      cupertino: (ctx, _) => CupertinoButton(
        onPressed: item.disabled ? null : () => _selectItem(item),
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        child: content,
      ),
    );
  }

  void _selectItem(BcSlideMenuItem item) {
    _setOpen(
      false,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          widget.child,
          if (_isOpen || _controller.value > 0.01) ...[
            Positioned.fill(child: _buildScrim()),
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              width: widget.drawerWidth,
              child: _buildDrawer(),
            ),
          ],
          _buildTrigger(),
        ],
      ),
    );
  }
}
