library bc_slot;

import 'package:flutter/material.dart';

/// Children passthrough / layout slot (ADR-011 Phase 5c — M1 layout).
///
/// Renders its children verbatim inside a lightweight [Column] so that
/// multiple children are accepted without requiring a wrapping list
/// widget at the call site. The slot does not inject any decoration,
/// semantics, or sizing — it is a pure composition anchor.
class BcSlot extends StatelessWidget {
  final String? name;
  final Widget? child;
  final List<Widget> children;

  const BcSlot({
    super.key,
    this.name,
    this.child,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    final all = [
      if (child != null) child!,
      ...children,
    ];

    if (all.isEmpty) {
      return const SizedBox.shrink();
    }
    if (all.length == 1) {
      return all.first;
    }
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: all,
      ),
    );
  }
}
