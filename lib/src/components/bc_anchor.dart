library bc_anchor;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// A single anchor link in a [BcAnchor] navigation list.
///
/// [target] is matched against the [Key] value of a target section widget
/// within the scrollable body. A widget with `key: Key(target)` (or
/// `key: ValueKey(target)`) is considered a match.
class BcAnchorLink {
  final String label;
  final String target;
  final bool disabled;

  const BcAnchorLink({
    required this.label,
    required this.target,
    this.disabled = false,
  });
}

/// Anchor navigation that scrolls to target sections and highlights the
/// active link.
///
/// Mirrors the TS `BcAnchor` contract: renders a vertical list of
/// [BcAnchorLink]s. Tapping a link whose [target] resolves to a widget
/// inside the scrollable ancestor scrolls the view so the target is
/// centered, and fires [onSelected] with the target id and a
/// [BcChangeMeta]. As the scroll position changes, the link whose target
/// section is closest to the top of the viewport receives the active
/// visual state and fires [onActiveChange]. Tapping a link whose target
/// does not resolve is a silent no-op.
///
/// Platform-aware: Cupertino tap affordance on iOS, Material InkWell
/// elsewhere.
class BcAnchor extends StatefulWidget {
  final List<BcAnchorLink> anchors;
  final String? selected;
  final BcChangeHandler<String>? onSelected;
  final BcChangeHandler<String?>? onActiveChange;

  const BcAnchor({
    super.key,
    this.anchors = const [],
    this.selected,
    this.onSelected,
    this.onActiveChange,
  });

  @override
  State<BcAnchor> createState() => _BcAnchorState();
}

class _BcAnchorState extends State<BcAnchor> {
  String? _activeTarget;
  ScrollableState? _monitoredScrollable;

  bool get _isControlled => widget.selected != null;
  String? get _currentActive => _isControlled ? widget.selected : _activeTarget;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachScrollListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _attachScrollListener();
        _updateActiveOnScroll();
      }
    });
  }

  void _attachScrollListener() {
    final scrollable = _findContentScrollable();
    if (scrollable == _monitoredScrollable) return;

    if (_monitoredScrollable != null) {
      _monitoredScrollable!.position.removeListener(_updateActiveOnScroll);
    }
    _monitoredScrollable = scrollable;
    if (_monitoredScrollable != null) {
      _monitoredScrollable!.position.addListener(_updateActiveOnScroll);
    }
  }

  ScrollableState? _findContentScrollable() {
    for (final anchor in widget.anchors) {
      final element = _findTargetElement(anchor.target);
      if (element == null) continue;
      final scrollable = _findScrollableForElement(element);
      if (scrollable != null) return scrollable;
    }
    return null;
  }

  /// Searches the subtree for an [Element] whose widget key matches
  /// [target]. Returns `null` if no match is found.
  Element? _findTargetElement(String target) {
    final rootElement = _rootElement;
    if (rootElement == null) return null;

    Element? result;
    void visitor(Element element) {
      if (result != null) return;
      final widget = element.widget;
      if (_keyMatches(widget.key, target)) {
        result = element;
        return;
      }
      element.visitChildren(visitor);
    }

    rootElement.visitChildren(visitor);
    return result;
  }

  RenderBox? _findTargetRenderBox(String target) {
    final element = _findTargetElement(target);
    if (element == null) return null;
    final ro = element.findRenderObject();
    if (ro is RenderBox && ro.attached) return ro;
    return null;
  }

  Element? get _rootElement {
    Element? root;
    context.visitAncestorElements((element) {
      root = element;
      return true;
    });
    return root;
  }

  bool _keyMatches(Key? key, String target) {
    if (key is ValueKey<String>) {
      if (key.value.startsWith('anchor-link-')) return false;
      return key.value == target;
    }
    return key == Key(target);
  }

  /// Finds the nearest [ScrollableState] ancestor of [targetElement].
  ScrollableState? _findScrollableForElement(Element targetElement) {
    ScrollableState? result;
    targetElement.visitAncestorElements((element) {
      final widget = element.widget;
      if (widget is Scrollable) {
        result = (element as StatefulElement).state as ScrollableState;
        return false;
      }
      return true;
    });
    return result;
  }

  void _scrollToTarget(String target) {
    final targetElement = _findTargetElement(target);
    if (targetElement == null) return;

    final scrollableState = _findScrollableForElement(targetElement);
    if (scrollableState == null) return;

    final renderBox = _findTargetRenderBox(target);
    if (renderBox == null) return;

    final scrollableRender = scrollableState.context.findRenderObject();
    if (scrollableRender is! RenderBox) return;

    final targetPosition =
        renderBox.localToGlobal(Offset.zero, ancestor: scrollableRender);

    final viewportHeight = scrollableRender.size.height;
    final targetHeight = renderBox.size.height;

    final offset = scrollableState.position.pixels +
        targetPosition.dy -
        (viewportHeight - targetHeight) / 2;

    final clampedOffset = offset.clamp(
      scrollableState.position.minScrollExtent,
      scrollableState.position.maxScrollExtent,
    );

    scrollableState.position.animateTo(
      clampedOffset.toDouble(),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _tap(BcAnchorLink link) {
    if (link.disabled) return;
    if (_findTargetRenderBox(link.target) == null) return;

    widget.onSelected?.call(
      link.target,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToTarget(link.target);
    });
  }

  void _updateActiveOnScroll() {
    String? bestTarget;
    double bestDistance = double.infinity;

    for (final anchor in widget.anchors) {
      if (anchor.disabled) continue;
      final targetElement = _findTargetElement(anchor.target);
      if (targetElement == null) continue;
      final renderBox = _findTargetRenderBox(anchor.target);
      if (renderBox == null) continue;

      final scrollableState = _findScrollableForElement(targetElement);
      if (scrollableState == null) continue;
      final scrollableRender = scrollableState.context.findRenderObject();
      if (scrollableRender is! RenderBox) continue;

      final pos =
          renderBox.localToGlobal(Offset.zero, ancestor: scrollableRender);
      final distance = pos.dy.abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        bestTarget = anchor.target;
      }
    }

    if (bestTarget != _activeTarget) {
      setState(() => _activeTarget = bestTarget);
      widget.onActiveChange?.call(
        bestTarget,
        const BcChangeMeta(
          reason: BcChangeReason.valueChange,
          source: BcEventSource.external,
        ),
      );
    }
  }

  @override
  void dispose() {
    _monitoredScrollable?.position.removeListener(_updateActiveOnScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.anchors.map((anchor) {
          return _buildLink(anchor);
        }).toList(),
      ),
    );
  }

  Widget _buildLink(BcAnchorLink link) {
    final isActive = _currentActive == link.target;
    final isDisabled = link.disabled;

    final color = isDisabled
        ? BcTheme.mutedForeground.withValues(alpha: 0.5)
        : isActive
            ? BcTheme.primary
            : BcTheme.foreground;

    final labelWidget = Container(
      key: ValueKey<String>('anchor-link-${link.target}'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: isActive
            ? const Border(
                left: BorderSide(color: BcTheme.primary, width: 3),
              )
            : null,
        color: isActive ? BcTheme.accent : Colors.transparent,
      ),
      child: Text(
        link.label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          color: color,
        ),
      ),
    );

    return PlatformWidget(
      material: (ctx, _) => InkWell(
        onTap: isDisabled ? null : () => _tap(link),
        child: labelWidget,
      ),
      cupertino: (ctx, _) => CupertinoButton(
        onPressed: isDisabled ? null : () => _tap(link),
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        child: labelWidget,
      ),
    );
  }
}
