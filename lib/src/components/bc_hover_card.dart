library bc_hover_card;

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Placement of the hover card relative to the trigger.
///
/// Mirrors TS `BcHoverCardPlacement` ('top' | 'bottom' | 'left' | 'right').
enum BcHoverCardPlacement { top, bottom, left, right }

/// Hover-reveal card popover.
///
/// Mirrors the TS `BcHoverCardContract`: wraps a [child] trigger and reveals
/// a [content] card when the pointer enters the trigger region. The card
/// stays open while the pointer hovers over either the trigger or the card,
/// and closes after [closeDelay] once the pointer leaves both.
///
/// Controlled mode: the parent manages [open]; hover events still fire
/// [onOpenChange] but the card visibility is driven by the prop.
/// Uncontrolled mode: [open] is null and [defaultOpen] seeds the initial
/// state; hover events toggle the internal state.
///
/// When [disabled] is true, pointer enter never reveals the card and the
/// trigger renders with disabled token styling.
class BcHoverCard extends StatefulWidget {
  /// The trigger widget that reveals the card on hover.
  final Widget child;

  /// The card body shown when revealed.
  final Widget content;

  /// Controlled open state. When non-null, the widget is controlled.
  final bool? open;

  /// Initial open state for uncontrolled mode.
  final bool defaultOpen;

  /// Delay before the card appears after pointer enter.
  final Duration openDelay;

  /// Delay before the card hides after pointer leaves trigger and card.
  final Duration closeDelay;

  /// Placement of the card relative to the trigger.
  final BcHoverCardPlacement placement;

  /// When true, pointer enter never reveals the card.
  final bool disabled;

  /// Card width in logical pixels.
  final double cardWidth;

  /// Gap between trigger and card in logical pixels.
  final double gap;

  /// Called on each open/close transition.
  final BcChangeHandler<bool>? onOpenChange;

  const BcHoverCard({
    super.key,
    required this.child,
    required this.content,
    this.open,
    this.defaultOpen = false,
    this.openDelay = const Duration(milliseconds: 300),
    this.closeDelay = const Duration(milliseconds: 150),
    this.placement = BcHoverCardPlacement.bottom,
    this.disabled = false,
    this.cardWidth = 256,
    this.gap = 8,
    this.onOpenChange,
  });

  @override
  State<BcHoverCard> createState() => _BcHoverCardState();
}

class _BcHoverCardState extends State<BcHoverCard> {
  bool _internalOpen = false;
  Timer? _openTimer;
  Timer? _closeTimer;
  bool _isOverTrigger = false;
  bool _isOverCard = false;

  bool get _isControlled => widget.open != null;

  bool get _isOpen => _isControlled ? widget.open! : _internalOpen;

  @override
  void initState() {
    super.initState();
    _internalOpen = widget.defaultOpen;
  }

  @override
  void didUpdateWidget(covariant BcHoverCard old) {
    super.didUpdateWidget(old);
    if (_isControlled && widget.open != old.open) {
      _internalOpen = widget.open!;
    }
    if (widget.disabled && !old.disabled) {
      _cancelTimers();
    }
  }

  void _cancelTimers() {
    _openTimer?.cancel();
    _openTimer = null;
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  void _setOpen(bool value, BcChangeMeta meta) {
    if (!_isControlled) {
      setState(() => _internalOpen = value);
    }
    widget.onOpenChange?.call(value, meta);
  }

  void _startOpenTimer() {
    _openTimer?.cancel();
    _openTimer = Timer(widget.openDelay, () {
      _setOpen(
        true,
        const BcChangeMeta(
          reason: BcChangeReason.toggle,
          source: BcEventSource.pointer,
        ),
      );
    });
  }

  void _startCloseTimer() {
    _closeTimer?.cancel();
    _closeTimer = Timer(widget.closeDelay, () {
      _setOpen(
        false,
        const BcChangeMeta(
          reason: BcChangeReason.toggle,
          source: BcEventSource.pointer,
        ),
      );
    });
  }

  void _onTriggerEnter(PointerEnterEvent _) {
    if (widget.disabled) return;
    _isOverTrigger = true;
    _closeTimer?.cancel();
    _closeTimer = null;
    if (!_isOpen) {
      _startOpenTimer();
    }
  }

  void _onTriggerExit(PointerExitEvent _) {
    _isOverTrigger = false;
    if (!_isOverCard) {
      _openTimer?.cancel();
      _openTimer = null;
      if (_isOpen) {
        _startCloseTimer();
      }
    }
  }

  void _onCardEnter(PointerEnterEvent _) {
    _isOverCard = true;
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  void _onCardExit(PointerExitEvent _) {
    _isOverCard = false;
    if (!_isOverTrigger) {
      if (_isOpen) {
        _startCloseTimer();
      }
    }
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  Widget _buildCard() {
    return MouseRegion(
      onEnter: _onCardEnter,
      onExit: _onCardExit,
      child: Container(
        key: const Key('bc-hover-card-content'),
        width: widget.cardWidth,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: BcTheme.popover,
          borderRadius: BorderRadius.circular(BcTheme.radius),
          border: Border.all(color: BcTheme.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(
            fontSize: 14,
            color: BcTheme.popoverForeground,
          ),
          child: widget.content,
        ),
      ),
    );
  }

  Widget _buildDisabledTrigger(Widget child) {
    return Opacity(
      opacity: 0.5,
      child: MouseRegion(
        cursor: SystemMouseCursors.forbidden,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final triggerWidget = widget.disabled
        ? _buildDisabledTrigger(widget.child)
        : MouseRegion(
            onEnter: _onTriggerEnter,
            onExit: _onTriggerExit,
            child: widget.child,
          );

    final cardWidget = _buildCard();
    final gapWidget = SizedBox(
      width: widget.placement == BcHoverCardPlacement.left ||
              widget.placement == BcHoverCardPlacement.right
          ? widget.gap
          : 0,
      height: widget.placement == BcHoverCardPlacement.top ||
              widget.placement == BcHoverCardPlacement.bottom
          ? widget.gap
          : 0,
    );

    switch (widget.placement) {
      case BcHoverCardPlacement.bottom:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            triggerWidget,
            if (_isOpen) gapWidget,
            if (_isOpen) cardWidget,
          ],
        );
      case BcHoverCardPlacement.top:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isOpen) cardWidget,
            if (_isOpen) gapWidget,
            triggerWidget,
          ],
        );
      case BcHoverCardPlacement.right:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            triggerWidget,
            if (_isOpen) gapWidget,
            if (_isOpen) cardWidget,
          ],
        );
      case BcHoverCardPlacement.left:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isOpen) cardWidget,
            if (_isOpen) gapWidget,
            triggerWidget,
          ],
        );
    }
  }
}
