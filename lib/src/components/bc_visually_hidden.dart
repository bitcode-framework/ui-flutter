library bc_visually_hidden;

import 'package:flutter/material.dart';

/// Screen-reader-only content container (ADR-011 Phase 5c — M1 foundation).
///
/// Renders [child] so that it remains in the semantics tree (accessible to
/// assistive technology) but is positioned off-screen so it is not visually
/// painted and does not consume layout space. This mirrors the CSS pattern
/// `.visually-hidden { position: absolute; left: -9999px; width: 1px;
/// height: 1px; overflow: hidden; }`.
///
/// Unlike [ExcludeSemantics], the child's semantic information is preserved
/// — only the visual rendering is hidden.
class BcVisuallyHidden extends StatelessWidget {
  final Widget? child;

  const BcVisuallyHidden({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: 0,
      height: 0,
      child: OverflowBox(
        minWidth: 0,
        minHeight: 0,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: Transform.translate(
          offset: const Offset(-99999, -99999),
          child: child,
        ),
      ),
    );
  }
}
