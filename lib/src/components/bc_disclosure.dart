library bc_disclosure;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/types.dart';

/// Collapsible disclosure panel (ADR-011 Phase 5b.2).
///
/// Mirrors the TS `BcDisclosure` contract: a collapsible panel with
/// controlled (`open`) and uncontrolled (`defaultOpen`) open state. Tapping
/// the trigger, or pressing Enter/Space while focused on it, toggles the
/// open state and fires [onOpenChange] with [BcChangeReason.toggle].
/// External (controlled) prop changes fire [onOpenChange] with
/// [BcChangeReason.programmatic]. The simpler [onChange] callback fires
/// with the boolean open state for either interaction type.
class BcDisclosure extends StatefulWidget {
  final bool? open;
  final bool? defaultOpen;
  final String? title;
  final bool? disabled;
  final String? className;
  final Map<String, dynamic>? slotProps;
  final BcChangeHandler<bool>? onOpenChange;
  final void Function(bool)? onChange;
  final Widget? child;

  const BcDisclosure({
    super.key,
    this.open,
    this.defaultOpen,
    this.title,
    this.disabled,
    this.className,
    this.slotProps,
    this.onOpenChange,
    this.onChange,
    this.child,
  });

  @override
  State<BcDisclosure> createState() => _BcDisclosureState();
}

class _BcDisclosureState extends State<BcDisclosure>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _expandAnimation;
  late final FocusNode _focusNode;
  bool _internalOpen = false;
  bool _isControlled = false;

  @override
  void initState() {
    super.initState();
    _isControlled = widget.open != null;
    _internalOpen = widget.defaultOpen ?? false;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: _isOpen ? 1.0 : 0.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(BcDisclosure oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasControlled = oldWidget.open != null;
    _isControlled = widget.open != null;

    if (_isControlled) {
      final oldOpen = oldWidget.open!;
      final next = widget.open!;
      if (next != oldOpen) {
        _syncAnimation(next);
        _emitOpenChange(next, BcChangeReason.programmatic);
      }
    } else if (!wasControlled) {
      // Remaining uncontrolled — no programmatic emission.
      _syncAnimation(_internalOpen);
    }
  }

  bool get _isOpen => _isControlled ? widget.open! : _internalOpen;

  bool get _isDisabled => widget.disabled ?? false;

  void _syncAnimation(bool open) {
    if (open) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _emitOpenChange(bool next, BcChangeReason reason) {
    final source = reason == BcChangeReason.programmatic
        ? BcEventSource.programmatic
        : BcEventSource.pointer;
    widget.onOpenChange?.call(
      next,
      BcChangeMeta(reason: reason, source: source),
    );
    widget.onChange?.call(next);
  }

  void _toggle({required BcChangeReason reason}) {
    if (_isDisabled) return;
    final next = !_isOpen;
    if (!_isControlled) {
      setState(() {
        _internalOpen = next;
      });
    }
    _syncAnimation(next);
    _emitOpenChange(next, reason);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (_isDisabled) return KeyEventResult.ignored;
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      _toggle(reason: BcChangeReason.toggle);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = _isDisabled;
    final open = _isOpen;

    final header = _DisclosureHeader(
      title: widget.title,
      open: open,
      disabled: disabled,
      focusNode: _focusNode,
      onTap: disabled ? null : () => _toggle(reason: BcChangeReason.toggle),
      onKeyEvent: _handleKeyEvent,
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        header,
        if (open)
          _DisclosurePanel(
            child: widget.child ?? const SizedBox.shrink(),
          ),
      ],
    );

    return Semantics(
      container: true,
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) => child!,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(6),
            color: theme.colorScheme.surface,
          ),
          clipBehavior: Clip.antiAlias,
          child: body,
        ),
      ),
    );
  }
}

class _DisclosureHeader extends StatelessWidget {
  final String? title;
  final bool open;
  final bool disabled;
  final FocusNode focusNode;
  final VoidCallback? onTap;
  final KeyEventResult Function(FocusNode, KeyEvent) onKeyEvent;

  const _DisclosureHeader({
    required this.title,
    required this.open,
    required this.disabled,
    required this.focusNode,
    required this.onTap,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Focus(
      focusNode: focusNode,
      onKeyEvent: onKeyEvent,
      child: Semantics(
        button: true,
        enabled: !disabled,
        expanded: open,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title ?? '',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: disabled
                          ? theme.disabledColor
                          : theme.textTheme.titleSmall?.color,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: open ? 0.25 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: disabled
                        ? theme.disabledColor
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DisclosurePanel extends StatelessWidget {
  final Widget child;

  const _DisclosurePanel({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: DefaultTextStyle(
          style: theme.textTheme.bodyMedium!,
          child: child,
        ),
      ),
    );
  }
}
