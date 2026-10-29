library bc_aspect_ratio;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Aspect ratio container (ADR-011 Phase 5c — M4 layout utility).
///
/// Mirrors TS [BcAspectRatioContract]. Given a [ratio] expressed as
/// width/height, the widget lays out its child so that the rendered
/// height equals `width / ratio` (i.e. `width * (h / w)`). The child
/// is constrained to exactly fill the computed box and content that
/// overflows is clipped via [Clip.hardEdge].
///
/// Ratio updates (a new [ratio] passed to the parent) propagate to the
/// child box on the next layout pass without overflow, because the
/// child is always constrained to the freshly computed dimensions.
class BcAspectRatio extends StatelessWidget {
  /// Aspect ratio as width/height. `1` = square, `16/9 ≈ 1.778` = wide.
  /// Must be > 0. Defaults to `1` (square), matching the TS default.
  final double ratio;

  /// The child constrained to the aspect-ratio box.
  final Widget? child;

  const BcAspectRatio({
    super.key,
    this.ratio = 1,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final r = ratio > 0 ? ratio : 1.0;
    return _AspectRatioBox(ratio: r, child: child);
  }
}

/// A [SingleChildRenderObjectWidget] that performs aspect-ratio layout and
/// clips its child to the computed box.
///
/// We use a custom [RenderBox] rather than Flutter's built-in [AspectRatio]
/// because the contract requires the child to be hard-clipped to the box
/// (content painted outside is not visible) and to be constrained to the
/// exact computed size (tight constraints), which guarantees ratio updates
/// propagate without overflow artifacts.
class _AspectRatioBox extends SingleChildRenderObjectWidget {
  final double ratio;

  const _AspectRatioBox({required this.ratio, super.child});

  @override
  _RenderAspectRatioBox createRenderObject(BuildContext context) {
    return _RenderAspectRatioBox(ratio: ratio);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderAspectRatioBox renderObject,
  ) {
    renderObject.ratio = ratio;
  }
}

class _RenderAspectRatioBox extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  _RenderAspectRatioBox({required double ratio}) : _ratio = ratio > 0 ? ratio : 1.0;

  double _ratio;

  set ratio(double value) {
    final next = value > 0 ? value : 1.0;
    if (_ratio == next) return;
    _ratio = next;
    markNeedsLayout();
  }

  /// Given a width, compute the height that satisfies the aspect ratio.
  double _heightForWidth(double width) => width / _ratio;

  @override
  double computeMinIntrinsicWidth(double height) {
    if (child != null) {
      // The child fills the box tightly, so its intrinsic width at the
      // ratio-derived height is the best estimate.
      final double h = height.isFinite ? height : 0.0;
      return child!.getMinIntrinsicWidth(h);
    }
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (child != null) {
      final double h = height.isFinite ? height : 0.0;
      return child!.getMaxIntrinsicWidth(h);
    }
    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (width.isFinite && width > 0) return _heightForWidth(width);
    if (child != null) return child!.getMinIntrinsicHeight(width);
    return 0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (width.isFinite && width > 0) return _heightForWidth(width);
    if (child != null) return child!.getMaxIntrinsicHeight(width);
    return 0;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeSize(constraints);
  }

  Size _computeSize(BoxConstraints constraints) {
    final width = constraints.constrainWidth();
    if (!width.isFinite || width <= 0) {
      // No finite width: fall back to child size if any, else zero.
      if (child != null) {
        return child!.getDryLayout(constraints);
      }
      return constraints.smallest;
    }
    final height = _heightForWidth(width);
    final clamped = constraints.constrain(Size(width, height));
    return clamped;
  }

  @override
  void performLayout() {
    final computed = _computeSize(constraints);
    // Set our own size.
    size = computed;

    if (child != null) {
      // Tight constraints so the child fills the box exactly.
      child!.layout(
        BoxConstraints.tight(computed),
        parentUsesSize: false,
      );
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (child == null) return false;
    return child!.hitTest(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    // Clip the child to our size so overflow content is not visible.
    context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      (context, offset) {
        child!.paint(context, offset);
      },
      clipBehavior: Clip.hardEdge,
    );
  }
}
