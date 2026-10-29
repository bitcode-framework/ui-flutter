library bc_flex;

import 'package:flutter/material.dart';

/// Flex direction (ADR-011 Phase 5c — M4 layout utility).
///
/// Mirrors TS `BcFlexDirection`.
enum BcFlexDirection {
  row,
  column,
  rowReverse,
  columnReverse,
}

/// Cross-axis alignment. Mirrors TS `BcFlexAlign`.
enum BcFlexAlign {
  start,
  center,
  end,
  stretch,
  baseline,
}

/// Main-axis distribution. Mirrors TS `BcFlexJustify`.
enum BcFlexJustify {
  start,
  center,
  end,
  between,
  around,
  evenly,
}

/// Wrap mode. Mirrors TS `BcFlexWrap`.
enum BcFlexWrap {
  nowrap,
  wrap,
  wrapReverse,
}

/// Maps the TS `gap` spacing scale (0,1,2,3,4,5,6,8,10,12) to logical
/// pixels using a 4px multiplier (matching Tailwind's gap scale).
double bcFlexGapToPixels(double gap) => gap * 4;

/// Flexible layout container (ADR-011 Phase 5c — M4 layout utility).
///
/// Mirrors TS [BcFlexContract]. Lays out children along a main axis
/// ([direction]) with cross-axis [align] and main-axis [justify]
/// distribution. [gap] inserts uniform spacing between children (mapped
/// from the TS scale via a 4px multiplier). [wrap] controls whether
/// children wrap onto subsequent lines. When [inline] is true the
/// container shrinks to its children along the main axis; otherwise it
/// expands to fill available space.
///
/// Per-child flex factors are honoured by wrapping individual children in
/// [Expanded] or [Flexible] (Flutter built-ins), or by using the
/// [BcFlexItem] convenience wrapper. Such children override their natural
/// sizing along the main axis, exactly as the contract requires.
class BcFlex extends StatelessWidget {
  final BcFlexDirection direction;
  final BcFlexAlign align;
  final BcFlexJustify justify;
  final BcFlexWrap wrap;
  final double gap;
  final bool inline;
  final List<Widget> children;

  const BcFlex({
    super.key,
    this.direction = BcFlexDirection.row,
    this.align = BcFlexAlign.stretch,
    this.justify = BcFlexJustify.start,
    this.wrap = BcFlexWrap.nowrap,
    this.gap = 0,
    this.inline = false,
    this.children = const [],
  });

  Axis get _axis {
    switch (direction) {
      case BcFlexDirection.row:
      case BcFlexDirection.rowReverse:
        return Axis.horizontal;
      case BcFlexDirection.column:
      case BcFlexDirection.columnReverse:
        return Axis.vertical;
    }
  }

  bool get _reverse =>
      direction == BcFlexDirection.rowReverse ||
      direction == BcFlexDirection.columnReverse;

  CrossAxisAlignment _mapAlign() {
    switch (align) {
      case BcFlexAlign.start:
        return CrossAxisAlignment.start;
      case BcFlexAlign.center:
        return CrossAxisAlignment.center;
      case BcFlexAlign.end:
        return CrossAxisAlignment.end;
      case BcFlexAlign.stretch:
        return CrossAxisAlignment.stretch;
      case BcFlexAlign.baseline:
        return CrossAxisAlignment.baseline;
    }
  }

  MainAxisAlignment _mapJustify() {
    switch (justify) {
      case BcFlexJustify.start:
        return MainAxisAlignment.start;
      case BcFlexJustify.center:
        return MainAxisAlignment.center;
      case BcFlexJustify.end:
        return MainAxisAlignment.end;
      case BcFlexJustify.between:
        return MainAxisAlignment.spaceBetween;
      case BcFlexJustify.around:
        return MainAxisAlignment.spaceAround;
      case BcFlexJustify.evenly:
        return MainAxisAlignment.spaceEvenly;
    }
  }

  MainAxisSize get _mainAxisSize =>
      inline ? MainAxisSize.min : MainAxisSize.max;

  /// Inserts gap spacers between non-flex children. Children wrapped in
  /// [Expanded]/[Flexible]/[BcFlexItem] are left untouched so their flex
  /// factors continue to control main-axis sizing; the gap is instead
  /// absorbed because flex children expand to fill space.
  List<Widget> _withGaps(List<Widget> input) {
    final gapPx = bcFlexGapToPixels(gap);
    if (input.isEmpty || gapPx == 0) return input;
    final result = <Widget>[];
    for (var i = 0; i < input.length; i++) {
      if (i > 0) {
        result.add(_Gap(axis: _axis, size: gapPx));
      }
      result.add(input[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final gapPx = bcFlexGapToPixels(gap);
    final spacedChildren = gapPx == 0 ? children : _withGaps(children);

    if (wrap == BcFlexWrap.nowrap) {
      // For row direction, the main-axis order is reversed via
      // [textDirection] (rtl lays children right-to-left). For column
      // direction, the main-axis order is reversed via [verticalDirection]
      // (up lays children bottom-to-top). Using the correct axis-specific
      // direction flag ensures rowReverse and columnReverse actually
      // reverse child order along the main axis.
      final isHorizontal =
          direction == BcFlexDirection.row ||
          direction == BcFlexDirection.rowReverse;
      return Flex(
        direction: _axis,
        mainAxisAlignment: _mapJustify(),
        crossAxisAlignment: _mapAlign(),
        mainAxisSize: _mainAxisSize,
        textDirection:
            isHorizontal && _reverse ? TextDirection.rtl : TextDirection.ltr,
        verticalDirection:
            !isHorizontal && _reverse
                ? VerticalDirection.up
                : VerticalDirection.down,
        children: spacedChildren,
      );
    }

    // Wrap mode: use Wrap with spacing. Flex-factor children do not
    // apply inside Wrap (it is not a flex container), but this matches
    // the TS contract where `wrap` is an independent layout mode.
    return Wrap(
      direction: _axis,
      alignment: _mapWrapAlignment(),
      spacing: gapPx,
      runSpacing: gapPx,
      verticalDirection:
          wrap == BcFlexWrap.wrapReverse ? VerticalDirection.up : VerticalDirection.down,
      children: children,
    );
  }

  WrapAlignment _mapWrapAlignment() {
    switch (justify) {
      case BcFlexJustify.start:
        return WrapAlignment.start;
      case BcFlexJustify.center:
        return WrapAlignment.center;
      case BcFlexJustify.end:
        return WrapAlignment.end;
      case BcFlexJustify.between:
        return WrapAlignment.spaceBetween;
      case BcFlexJustify.around:
        return WrapAlignment.spaceAround;
      case BcFlexJustify.evenly:
        return WrapAlignment.spaceEvenly;
    }
  }
}

/// A zero-size spacer used to realise [BcFlex.gap] between children.
class _Gap extends StatelessWidget {
  final Axis axis;
  final double size;

  const _Gap({required this.axis, required this.size});

  @override
  Widget build(BuildContext context) {
    return axis == Axis.horizontal
        ? SizedBox(width: size)
        : SizedBox(height: size);
  }
}

/// Convenience wrapper that applies a flex factor to a child, mirroring
/// the TS `flex-grow`/`flex-shrink` utilities.
///
/// [BcFlexItem] with [flex] > 0 renders as an [Expanded] (fills remaining
/// space and overrides the child's natural main-axis size). With
/// [flex] == 0 it renders the child untouched (its natural size). Use
/// [fit] `FlexFit.loose` to allow the child to be smaller than the
/// allocated space.
class BcFlexItem extends StatelessWidget {
  final int flex;
  final FlexFit fit;
  final Widget child;

  const BcFlexItem({
    super.key,
    this.flex = 1,
    this.fit = FlexFit.tight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (flex <= 0) return child;
    return Flexible(flex: flex, fit: fit, child: child);
  }
}
