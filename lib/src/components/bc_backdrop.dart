library bc_backdrop;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Overlay scrim / dimmable background (ADR-011 Phase 5c — M1 foundation).
///
/// Renders a full-coverage dim layer over the content beneath it. When
/// [visible] is true (or [defaultVisible] in uncontrolled mode), the scrim
/// paints with [opacity] alpha over the [BcTheme.foreground] color. Tapping
/// the scrim fires [onDismiss] (when [dismissible] is true) and toggles the
/// visibility callback [onVisibleChange] in uncontrolled mode.
///
/// Controlled mode: the parent manages [visible]; the widget does not
/// self-hide on tap but emits callbacks so the parent can decide.
/// Uncontrolled mode: [visible] is null and [defaultVisible] seeds the
/// initial state; tapping dismisses internally and emits via
/// [onVisibleChange].
class BcBackdrop extends StatefulWidget {
  final bool? visible;
  final bool? defaultVisible;
  final double opacity;
  final bool dismissible;
  final Color? color;
  final Widget? child;
  final void Function(BcChangeMeta meta)? onDismiss;
  final BcChangeHandler<bool>? onVisibleChange;

  const BcBackdrop({
    super.key,
    this.visible,
    this.defaultVisible,
    this.opacity = 0.5,
    this.dismissible = true,
    this.color,
    this.child,
    this.onDismiss,
    this.onVisibleChange,
  });

  @override
  State<BcBackdrop> createState() => _BcBackdropState();
}

class _BcBackdropState extends State<BcBackdrop> {
  bool? _internalVisible;

  @override
  void initState() {
    super.initState();
    if (widget.visible == null) {
      _internalVisible = widget.defaultVisible ?? false;
    }
  }

  @override
  void didUpdateWidget(BcBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == null && oldWidget.visible != null) {
      _internalVisible = widget.defaultVisible ?? false;
    }
  }

  bool get _isVisible {
    if (widget.visible != null) return widget.visible!;
    return _internalVisible ?? false;
  }

  void _handleTap() {
    if (!widget.dismissible) return;

    const meta = BcChangeMeta(
      reason: BcChangeReason.overlayClick,
      source: BcEventSource.pointer,
    );

    widget.onDismiss?.call(meta);

    if (widget.visible == null) {
      setState(() {
        _internalVisible = false;
      });
      widget.onVisibleChange?.call(false, meta);
    } else {
      widget.onVisibleChange?.call(false, meta);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    final scrimColor = widget.color ?? BcTheme.foreground;

    return Positioned.fill(
      child: GestureDetector(
        onTap: _handleTap,
        child: Opacity(
          opacity: widget.opacity.clamp(0.0, 1.0),
          child: ColoredBox(
            color: scrimColor,
            child: widget.child ?? const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
