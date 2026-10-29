library bc_affix;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Affix wrapper that pins content past a scroll threshold.
///
/// Mirrors the TS `BcAffix` contract: wraps a [child] widget and, when a
/// scrollable ancestor scrolls past [offsetTop], pins the child in a fixed
/// position at the top of the viewport. When [offsetBottom] is provided,
/// the pin releases before the child's bottom would exceed that boundary
/// relative to the scroll container. The pinned/unpinned transition fires
/// [onAffixChange] with the boolean state and a [BcChangeMeta].
///
/// When no scrollable ancestor exists the widget renders normally and never
/// emits a state change.
class BcAffix extends StatefulWidget {
  final Widget child;
  final double offsetTop;
  final double? offsetBottom;
  final BcChangeHandler<bool>? onAffixChange;

  const BcAffix({
    super.key,
    required this.child,
    this.offsetTop = 0,
    this.offsetBottom,
    this.onAffixChange,
  });

  @override
  State<BcAffix> createState() => _BcAffixState();
}

class _BcAffixState extends State<BcAffix> {
  bool _isPinned = false;
  ScrollableState? _scrollable;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newScrollable = context.findAncestorStateOfType<ScrollableState>();
    if (newScrollable != _scrollable) {
      _removeListener();
      _scrollable = newScrollable;
      _addListener();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _evaluatePinnedState();
    });
  }

  void _addListener() {
    if (_scrollable != null) {
      _scrollable!.position.addListener(_evaluatePinnedState);
    }
  }

  void _removeListener() {
    if (_scrollable != null) {
      _scrollable!.position.removeListener(_evaluatePinnedState);
    }
  }

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }

  void _evaluatePinnedState() {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;

    final affixOrigin = renderObject.localToGlobal(Offset.zero);
    final affixTop = affixOrigin.dy;

    bool shouldPin = affixTop <= widget.offsetTop;

    if (widget.offsetBottom != null && _scrollable != null) {
      final position = _scrollable!.position;
      final remainingScroll =
          position.maxScrollExtent - position.pixels;
      if (remainingScroll <= widget.offsetBottom!) {
        shouldPin = false;
      }
    }

    if (shouldPin != _isPinned) {
      setState(() => _isPinned = shouldPin);
      widget.onAffixChange?.call(
        shouldPin,
        const BcChangeMeta(
          reason: BcChangeReason.valueChange,
          source: BcEventSource.external,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AffixContent(
      isPinned: _isPinned,
      child: widget.child,
    );
  }
}

class _AffixContent extends StatelessWidget {
  final bool isPinned;
  final Widget child;

  const _AffixContent({
    required this.isPinned,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPinned) {
      return child;
    }
    return Container(
      decoration: const BoxDecoration(
        color: BcTheme.background,
        border: Border(
          bottom: BorderSide(color: BcTheme.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
