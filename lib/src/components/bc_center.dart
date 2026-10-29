library bc_center;

import 'package:flutter/material.dart';

/// Centers its child both horizontally and vertically within available
/// space (ADR-011 Phase 5c — M7 misc).
///
/// Mirrors TS [BcCenterContract] ({ minHeight?, inline? }).
/// When [inline] is true, the widget does not expand to fill the parent's
/// main axis (wraps content). Otherwise it expands to fill available space
/// and centers the child within it.
class BcCenter extends StatelessWidget {
  final Widget? child;
  final double minHeight;
  final bool inline;

  const BcCenter({
    super.key,
    this.child,
    this.minHeight = 0,
    this.inline = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      key: const Key('bc_center'),
      child: child,
    );

    if (minHeight > 0) {
      content = ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: content,
      );
    }

    if (inline) {
      content = IntrinsicWidth(child: content);
    }

    return content;
  }
}
