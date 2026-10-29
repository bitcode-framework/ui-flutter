library bc_print_area;

import 'package:flutter/material.dart';

import '../core/bc_i18n.dart';

/// Marks a printable region of the page (ADR-007 contract parity).
///
/// In the Flutter adapter, `@media print` isolation is a web-only concern
/// (printing from a Flutter app routes through the platform print dialog).
/// This widget therefore acts as a semantic landmark: it wraps children
/// in a `region` semantics node with the given [ariaLabel], and exposes
/// an [onReady] callback fired once on mount.
///
/// The `auto` prop is preserved for contract parity but has no effect on
/// Flutter (the consumer is always responsible for their own print flow
/// when invoking platform printing).
class BcPrintArea extends StatefulWidget {
  final bool auto;
  final String? ariaLabel;
  final BcPrintAreaReadyCallback? onReady;
  final Widget? child;

  const BcPrintArea({
    super.key,
    this.auto = true,
    this.ariaLabel,
    this.onReady,
    this.child,
  });

  @override
  State<BcPrintArea> createState() => _BcPrintAreaState();
}

typedef BcPrintAreaReadyCallback = void Function();

class _BcPrintAreaState extends State<BcPrintArea> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onReady?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: widget.ariaLabel ?? bcI18n.t('bc.printArea.ariaLabel'),
      child: Container(
        key: const Key('bc-print-area-root'),
        child: widget.child,
      ),
    );
  }
}
