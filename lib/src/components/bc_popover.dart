library bc_popover;

import 'package:flutter/material.dart';

/// Material-only popover (ADR-011 Section 5).
/// Pure Material 3 — uses PopupMenuButton or showDialog overlay.
class BcPopover extends StatefulWidget {
  final Widget trigger;
  final Widget child;
  final String? title;
  final double width;

  const BcPopover({
    super.key,
    required this.trigger,
    required this.child,
    this.title,
    this.width = 250,
  });

  @override
  State<BcPopover> createState() => _BcPopoverState();
}

class _BcPopoverState extends State<BcPopover> {
  final GlobalKey _key = GlobalKey();
  OverlayEntry? _overlayEntry;

  void _showPopover() {
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _hidePopover,
            child: SizedBox(
              width: overlay.size.width,
              height: overlay.size.height,
            ),
          ),
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height + 4,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: widget.width,
                padding: const EdgeInsets.all(12),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hidePopover() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onTap: _showPopover,
      child: widget.trigger,
    );
  }
}
