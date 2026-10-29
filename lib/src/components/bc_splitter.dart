library bc_splitter;

import 'package:flutter/material.dart';

/// Material-only splitter/paned view (ADR-011 Section 5).
/// Pure Material 3 — no Cupertino counterpart.
class BcSplitter extends StatefulWidget {
  final Widget first;
  final Widget second;
  final Axis axis;
  final double initialFraction;
  final double minFraction;
  final double maxFraction;

  const BcSplitter({
    super.key,
    required this.first,
    required this.second,
    this.axis = Axis.horizontal,
    this.initialFraction = 0.5,
    this.minFraction = 0.1,
    this.maxFraction = 0.9,
  });

  @override
  State<BcSplitter> createState() => _BcSplitterState();
}

class _BcSplitterState extends State<BcSplitter> {
  late double _fraction;

  @override
  void initState() {
    super.initState();
    _fraction = widget.initialFraction.clamp(widget.minFraction, widget.maxFraction);
  }

  void _onDragUpdate(DragUpdateDetails details, double maxExtent) {
    if (maxExtent == 0) return;
    final delta = widget.axis == Axis.horizontal
        ? details.delta.dx / maxExtent
        : details.delta.dy / maxExtent;
    setState(() {
      _fraction = (_fraction + delta).clamp(widget.minFraction, widget.maxFraction);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isHorizontal = widget.axis == Axis.horizontal;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxExtent = isHorizontal ? constraints.maxWidth : constraints.maxHeight;
        final firstExtent = maxExtent * _fraction;
        final secondExtent = maxExtent - firstExtent - 6;

        final children = <Widget>[
          SizedBox(
            width: isHorizontal ? firstExtent : double.infinity,
            height: isHorizontal ? double.infinity : firstExtent,
            child: widget.first,
          ),
          GestureDetector(
            onHorizontalDragUpdate: isHorizontal
                ? (d) => _onDragUpdate(d, maxExtent)
                : null,
            onVerticalDragUpdate: !isHorizontal
                ? (d) => _onDragUpdate(d, maxExtent)
                : null,
            child: MouseRegion(
              cursor: isHorizontal
                  ? SystemMouseCursors.resizeColumn
                  : SystemMouseCursors.resizeRow,
              child: Container(
                width: isHorizontal ? 6 : double.infinity,
                height: isHorizontal ? double.infinity : 6,
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          SizedBox(
            width: isHorizontal ? secondExtent : double.infinity,
            height: isHorizontal ? double.infinity : secondExtent,
            child: widget.second,
          ),
        ];

        return Flex(
          direction: widget.axis,
          children: children,
        );
      },
    );
  }
}
