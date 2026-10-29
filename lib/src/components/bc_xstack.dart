library bc_xstack;

import 'package:flutter/material.dart';

/// Cross-axis alignment for [BcXStack], mirroring TS [BcStackAlign].
enum BcXStackAlign {
  start,
  center,
  end,
  stretch,
  baseline,
}

/// Main-axis size policy for [BcXStack].
enum BcXStackMainAxisSize {
  min,
  max,
}

/// Horizontal stack (Row) shorthand (ADR-011 Phase 5c — M1 layout).
///
/// Mirrors TS [BcXStackContract] which is a thin pass-through to
/// `BcStack direction="row"`. The [gap] prop maps to TS BcStackGap
/// (0,1,2,3,4,5,6,8,10,12) and is converted to logical pixels via
/// a 4px multiplier (matching Tailwind's gap scale).
class BcXStack extends StatelessWidget {
  final double gap;
  final BcXStackAlign crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final BcXStackMainAxisSize mainAxisSize;
  final WrapAlignment? wrap;
  final Widget? child;
  final List<Widget> children;

  const BcXStack({
    super.key,
    this.gap = 2,
    this.crossAxisAlignment = BcXStackAlign.stretch,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = BcXStackMainAxisSize.max,
    this.wrap,
    this.child,
    this.children = const [],
  });

  CrossAxisAlignment _mapAlign(BcXStackAlign a) {
    switch (a) {
      case BcXStackAlign.start:
        return CrossAxisAlignment.start;
      case BcXStackAlign.center:
        return CrossAxisAlignment.center;
      case BcXStackAlign.end:
        return CrossAxisAlignment.end;
      case BcXStackAlign.stretch:
        return CrossAxisAlignment.stretch;
      case BcXStackAlign.baseline:
        return CrossAxisAlignment.baseline;
    }
  }

  double get _gapPx => gap;

  List<Widget> get _spaced {
    final all = [
      if (child != null) child!,
      ...children,
    ];
    if (all.isEmpty || _gapPx == 0) return all;
    return [
      for (var i = 0; i < all.length; i++) ...[
        if (i > 0) SizedBox(width: _gapPx),
        all[i],
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: _mapAlign(crossAxisAlignment),
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize == BcXStackMainAxisSize.min
          ? MainAxisSize.min
          : MainAxisSize.max,
      children: _spaced,
    );

    if (wrap != null) {
      return Wrap(
        direction: Axis.horizontal,
        spacing: _gapPx,
        runSpacing: _gapPx,
        alignment: wrap!,
        children: [
          if (child != null) child!,
          ...children,
        ],
      );
    }
    return row;
  }
}
