library bc_backtop;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Floating back-to-top button that appears after scrolling past a threshold.
///
/// Mirrors the TS `BcBackTop` contract: a floating action button that
/// monitors a scrollable. When the scroll offset exceeds
/// [visibilityHeight], the button becomes visible. Tapping it scrolls the
/// scrollable to offset 0 and fires [onClick] with a [BcChangeMeta].
///
/// The scrollable can be specified via [scrollController]. When no
/// controller is provided, the widget searches for a [ScrollableState]
/// ancestor.
///
/// The button automatically hides again once the scroll offset drops below
/// the threshold (which happens after scrolling to top). When [disabled] is
/// true, the button renders (if visible) but does not invoke [onClick] and
/// shows a disabled visual state.
///
/// Platform-aware: renders CupertinoButton on iOS, FloatingActionButton
/// (Material) elsewhere.
class BcBackTop extends StatefulWidget {
  /// Scroll distance (px) before the button appears.
  final double visibilityHeight;

  /// Accessible label for the button.
  final String ariaLabel;

  /// Whether the button is disabled (non-interactive when visible).
  final bool disabled;

  /// Explicit scroll controller to monitor. When null, the widget searches
  /// for a [ScrollableState] ancestor.
  final ScrollController? scrollController;

  /// Called when the button is tapped, after scroll-to-top is initiated.
  final void Function(BcChangeMeta meta)? onClick;

  const BcBackTop({
    super.key,
    this.visibilityHeight = 400,
    this.ariaLabel = 'Back to top',
    this.disabled = false,
    this.scrollController,
    this.onClick,
  });

  @override
  State<BcBackTop> createState() => _BcBackTopState();
}

class _BcBackTopState extends State<BcBackTop> {
  bool _visible = false;
  ScrollableState? _scrollable;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController != null) {
      widget.scrollController!.addListener(_evaluateVisibility);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.scrollController == null) {
      final newScrollable = context.findAncestorStateOfType<ScrollableState>();
      if (newScrollable != _scrollable) {
        _removeScrollableListener();
        _scrollable = newScrollable;
        _addScrollableListener();
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _evaluateVisibility();
    });
  }

  @override
  void didUpdateWidget(covariant BcBackTop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController != oldWidget.scrollController) {
      if (oldWidget.scrollController != null) {
        oldWidget.scrollController!.removeListener(_evaluateVisibility);
      }
      _removeScrollableListener();
      _scrollable = null;
      if (widget.scrollController != null) {
        widget.scrollController!.addListener(_evaluateVisibility);
      } else {
        final newScrollable =
            context.findAncestorStateOfType<ScrollableState>();
        _scrollable = newScrollable;
        _addScrollableListener();
      }
    }
  }

  void _addScrollableListener() {
    if (_scrollable != null) {
      _scrollable!.position.addListener(_evaluateVisibility);
    }
  }

  void _removeScrollableListener() {
    if (_scrollable != null) {
      _scrollable!.position.removeListener(_evaluateVisibility);
    }
  }

  @override
  void dispose() {
    if (widget.scrollController != null) {
      widget.scrollController!.removeListener(_evaluateVisibility);
    }
    _removeScrollableListener();
    super.dispose();
  }

  void _evaluateVisibility() {
    double? pixels;

    if (widget.scrollController != null && widget.scrollController!.hasClients) {
      pixels = widget.scrollController!.position.pixels;
    } else if (_scrollable != null && _scrollable!.position.hasContentDimensions) {
      pixels = _scrollable!.position.pixels;
    }

    if (pixels == null) return;

    final shouldShow = pixels > widget.visibilityHeight;
    if (shouldShow != _visible) {
      setState(() => _visible = shouldShow);
    }
  }

  void _handleClick() {
    if (widget.disabled) return;

    if (widget.scrollController != null && widget.scrollController!.hasClients) {
      widget.scrollController!.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else if (_scrollable != null) {
      _scrollable!.position.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    widget.onClick?.call(
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return PlatformWidget(
      material: (ctx, _) => FloatingActionButton(
        key: const Key('bc-backtop-button'),
        onPressed: widget.disabled ? null : _handleClick,
        backgroundColor: BcTheme.background,
        foregroundColor: BcTheme.foreground,
        mini: true,
        child: Icon(
          Icons.arrow_upward,
          color: widget.disabled
              ? BcTheme.mutedForeground
              : BcTheme.foreground,
        ),
      ),
      cupertino: (ctx, _) => CupertinoButton(
        key: const Key('bc-backtop-button'),
        onPressed: widget.disabled ? null : _handleClick,
        color: BcTheme.background,
        minimumSize: const Size(40, 40),
        padding: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(20),
        child: Icon(
          Icons.arrow_upward,
          color: widget.disabled
              ? BcTheme.mutedForeground
              : BcTheme.foreground,
        ),
      ),
    );
  }
}
