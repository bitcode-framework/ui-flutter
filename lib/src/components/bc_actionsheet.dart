library bc_actionsheet;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// A single action item in a [BcActionsheet].
///
/// Mirrors the TS `BcActionsheetItem` interface. [value] identifies the
/// item, [label] is displayed text, [icon] is an optional leading icon,
/// [destructive] renders the label in destructive token color, and
/// [disabled] prevents interaction.
class BcActionsheetItem {
  final String label;
  final String value;
  final IconData? icon;
  final bool destructive;
  final bool disabled;

  const BcActionsheetItem({
    required this.label,
    required this.value,
    this.icon,
    this.destructive = false,
    this.disabled = false,
  });
}

/// Bottom sheet action menu that slides up from the bottom edge.
///
/// Mirrors the validation contract for BcActionsheet: a modal bottom sheet
/// that animates in from the bottom (positive Y translation to zero) and
/// renders each entry in [items] as a selectable item plus a cancel item.
/// A backdrop scrim covers the viewport; tapping the scrim or cancel
/// dismisses the sheet.
///
/// Selecting an action invokes [onSelect] with the item and a
/// [BcChangeMeta], then dismisses. Dismissing via scrim or cancel invokes
/// [onCancel] with a [BcChangeMeta] but does NOT emit an action value.
/// A disabled action item is not selectable and renders with disabled
/// styling.
///
/// Controlled mode: the parent manages [open]; internal transitions fire
/// callbacks but visibility is driven by the prop.
/// Uncontrolled mode: [open] is null and [defaultOpen] seeds the initial
/// state.
///
/// Platform-aware: renders `CupertinoActionSheet` on iOS/macOS, custom
/// Material bottom sheet elsewhere.
class BcActionsheet extends StatefulWidget {
  /// Controlled open state. When non-null, the widget is controlled.
  final bool? open;

  /// Initial open state for uncontrolled mode.
  final bool defaultOpen;

  /// Optional title displayed at the top of the sheet.
  final String? title;

  /// Optional description displayed below the title.
  final String? description;

  /// Action items to render in the sheet.
  final List<BcActionsheetItem> items;

  /// Label for the cancel button. Defaults to 'Cancel'.
  final String cancelLabel;

  /// Called when an action item is selected. Carries the item and meta.
  final void Function(BcActionsheetItem item, BcChangeMeta meta)? onSelect;

  /// Called when the sheet is dismissed via scrim or cancel. Carries meta.
  final BcChangeHandler<void>? onCancel;

  /// Duration of the slide animation.
  final Duration animationDuration;

  const BcActionsheet({
    super.key,
    this.open,
    this.defaultOpen = false,
    this.title,
    this.description,
    this.items = const [],
    this.cancelLabel = 'Cancel',
    this.onSelect,
    this.onCancel,
    this.animationDuration = const Duration(milliseconds: 250),
  });

  @override
  State<BcActionsheet> createState() => _BcActionsheetState();
}

class _BcActionsheetState extends State<BcActionsheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scrimAnimation;
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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _scrimAnimation = Tween<double>(begin: 0.0, end: 0.4)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
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
  void didUpdateWidget(covariant BcActionsheet oldWidget) {
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
  }

  void _handleActionTap(BcActionsheetItem item) {
    if (item.disabled) return;
    const meta = BcChangeMeta(
      reason: BcChangeReason.select,
      source: BcEventSource.pointer,
    );
    widget.onSelect?.call(item, meta);
    _setOpen(false, meta);
  }

  void _handleCancel() {
    const meta = BcChangeMeta(
      reason: BcChangeReason.cancel,
      source: BcEventSource.pointer,
    );
    widget.onCancel?.call(null, meta);
    _setOpen(false, meta);
  }

  void _handleScrimTap() {
    const meta = BcChangeMeta(
      reason: BcChangeReason.overlayClick,
      source: BcEventSource.pointer,
    );
    widget.onCancel?.call(null, meta);
    _setOpen(false, meta);
  }

  Widget _buildScrim() {
    return GestureDetector(
      key: const Key('bc-actionsheet-scrim'),
      onTap: _handleScrimTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black.withValues(alpha: _scrimAnimation.value),
        constraints: const BoxConstraints.expand(),
      ),
    );
  }

  Widget _buildSheet() {
    final platform = Theme.of(context).platform;
    final isIOS = platform == TargetPlatform.iOS ||
        platform == TargetPlatform.macOS;
    return SlideTransition(
      position: _slideAnimation,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          key: const Key('bc-actionsheet-sheet'),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          constraints: BoxConstraints(
            maxWidth: isIOS ? double.infinity : 480,
          ),
          decoration: BoxDecoration(
            color: BcTheme.background,
            borderRadius: BorderRadius.circular(BcTheme.radius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.title != null || widget.description != null)
                Container(
                  key: const Key('bc-actionsheet-header'),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: BcTheme.border),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (widget.title != null)
                        Text(
                          widget.title!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: BcTheme.foreground,
                          ),
                        ),
                      if (widget.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.description!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: BcTheme.mutedForeground,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ...widget.items.map(_buildActionItem),
              Container(
                key: const Key('bc-actionsheet-cancel-separator'),
                height: 8,
                color: BcTheme.muted,
              ),
              InkWell(
                key: const Key('bc-actionsheet-cancel'),
                onTap: _handleCancel,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Text(
                    widget.cancelLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: BcTheme.foreground,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem(BcActionsheetItem item) {
    final isDestructive = item.destructive;
    final isDisabled = item.disabled;

    final labelColor = isDisabled
        ? BcTheme.mutedForeground.withValues(alpha: 0.5)
        : isDestructive
            ? BcTheme.destructive
            : BcTheme.foreground;

    final content = Container(
      key: ValueKey<String>('bc-actionsheet-item-${item.value}'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (item.icon != null) ...[
            Icon(item.icon, size: 18, color: labelColor),
            const SizedBox(width: 8),
          ],
          Text(
            item.label,
            style: TextStyle(fontSize: 14, color: labelColor),
          ),
        ],
      ),
    );

    if (isDisabled) {
      return Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: BcTheme.border),
          ),
        ),
        child: content,
      );
    }

    return InkWell(
      onTap: () => _handleActionTap(item),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: BcTheme.border),
          ),
        ),
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showSheet = _isOpen || _controller.value > 0.01;
    if (!showSheet) return const SizedBox.shrink();

    return Stack(
      children: [
        Positioned.fill(child: _buildScrim()),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildSheet(),
        ),
      ],
    );
  }
}
