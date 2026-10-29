library bc_square;

import 'package:flutter/material.dart';
import '../theme/bc_theme.dart';

/// Constrains its child to a square shape (equal width and height)
/// (ADR-011 Phase 5c — M7 misc).
///
/// Mirrors TS [BcSquareContract] ({ size?, rounded? }).
/// When [size] is provided, the widget is exactly [size] x [size].
/// When [size] is null, it uses [AspectRatio] with ratio 1.0 to fill
/// available width and match the height.
/// When [rounded] is true, clips the child with a rounded rectangle.
class BcSquare extends StatelessWidget {
  final Widget? child;
  final double? size;
  final bool rounded;

  const BcSquare({
    super.key,
    this.child,
    this.size,
    this.rounded = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = rounded ? BcTheme.radius : 0.0;

    if (size != null) {
      Widget content = SizedBox(
        key: const Key('bc_square'),
        width: size,
        height: size,
        child: child,
      );

      if (rounded) {
        content = ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: child,
        );
      }

      return content;
    }

    Widget content = AspectRatio(
      key: const Key('bc_square'),
      aspectRatio: 1.0,
      child: child,
    );

    if (rounded) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: content,
      );
    }

    return content;
  }
}
