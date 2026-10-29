library bc_ystack;

import 'package:flutter/material.dart';

/// Cross-axis alignment for [BcYStack], mirroring TS [BcStackAlign].
enum BcYStackAlign {
  start,
  center,
  end,
  stretch,
  baseline,
}

/// Main-axis size policy for [BcYStack].
enum BcYStackMainAxisSize {
  min,
  max,
}

/// Vertical stack (Column) shorthand (ADR-011 Phase 5c — M1 layout).
///
/// Mirrors TS [BcYStackContract] which is a thin pass-through to
/// `BcStack direction="column"`. The [gap] prop maps to TS BcStackGap
/// and is converted to logical pixels via a 4px multiplier.
class BcYStack extends StatelessWidget {
  final double gap;
  final BcYStackAlign crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final BcYStackMainAxisSize mainAxisSize;
  final bool reverse;
  final WrapAlignment? wrap;
  final Widget? child;
  final List<Widget> children;

  const BcYStack({
    super.key,
    this.gap = 2,
    this.crossAxisAlignment = BcYStackAlign.stretch,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = BcYStackMainAxisSize.min,
    this.reverse = false,
    this.wrap,
    this.child,
    this.children = const [],
  });

  CrossAxisAlignment _mapAlign(BcYStackAlign a) {
    switch (a) {
      case BcYStackAlign.start:
        return CrossAxisAlignment.start;
      case BcYStackAlign.center:
        return CrossAxisAlignment.center;
      case BcYStackAlign.end:
        return CrossAxisAlignment.end;
      case BcYStackAlign.stretch:
        return CrossAxisAlignment.stretch;
      case BcYStackAlign.baseline:
        return CrossAxisAlignment.baseline;
    }
  }

  double get _gapPx => gap;

  List<Widget> get _all {
    return [
      if (child != null) child!,
      ...children,
    ];
  }

  List<Widget> get _spaced {
    final all = _all;
    if (all.isEmpty || _gapPx == 0) return all;
    return [
      for (var i = 0; i < all.length; i++) ...[
        if (i > 0) SizedBox(height: _gapPx),
        all[i],
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final column = Column(
      crossAxisAlignment: _mapAlign(crossAxisAlignment),
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize == BcYStackMainAxisSize.min
          ? MainAxisSize.min
          : MainAxisSize.max,
      verticalDirection:
          reverse ? VerticalDirection.up : VerticalDirection.down,
      children: _spaced,
    );

    if (wrap != null) {
      return Wrap(
        direction: Axis.vertical,
        spacing: _gapPx,
        runSpacing: _gapPx,
        alignment: wrap!,
        verticalDirection:
            reverse ? VerticalDirection.up : VerticalDirection.down,
        children: _all,
      );
    }
    return column;
  }
}
