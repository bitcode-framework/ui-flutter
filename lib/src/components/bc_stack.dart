library bc_stack;

import 'package:flutter/material.dart';

/// Z-axis stack positioning container (ADR-011 Phase 5c — M1 layout).
///
/// Mirrors TS [BcStackContract] with Flutter's [Stack]. Children are
/// positioned via [alignment] and sized via [stackFit]. Later children
/// paint above earlier ones (standard Stack paint order).
class BcStack extends StatelessWidget {
  final AlignmentGeometry alignment;
  final StackFit stackFit;
  final TextDirection? textDirection;
  final List<Widget> children;

  const BcStack({
    super.key,
    this.alignment = AlignmentDirectional.topStart,
    this.stackFit = StackFit.loose,
    this.textDirection,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: alignment,
      fit: stackFit,
      textDirection: textDirection,
      children: children,
    );
  }
}
