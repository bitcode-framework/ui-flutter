library bc_circle;

import 'package:flutter/material.dart';

/// Constrains its child to circular bounds (ADR-011 Phase 5c — M7 misc).
///
/// Mirrors TS [BcCircleContract] ({ size?, label? }).
/// When [size] is provided, the widget is exactly [size] x [size].
/// When [size] is null, it uses [AspectRatio] with ratio 1.0 to fill
/// available width. Content exceeding the circular bounds is clipped via
/// [ClipOval].
class BcCircle extends StatelessWidget {
  final Widget? child;
  final double? size;
  final String? label;

  const BcCircle({
    super.key,
    this.child,
    this.size,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = ClipOval(
      key: const Key('bc_circle'),
      child: child,
    );

    if (size != null) {
      content = SizedBox(
        width: size,
        height: size,
        child: content,
      );
    } else {
      content = AspectRatio(
        aspectRatio: 1.0,
        child: content,
      );
    }

    if (label != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          const SizedBox(height: 4),
          Text(label!),
        ],
      );
    }

    return content;
  }
}
