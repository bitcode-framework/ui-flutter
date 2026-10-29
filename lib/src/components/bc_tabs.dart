library bc_tabs;

import 'package:flutter/material.dart';

/// Material-only tabs (ADR-011 Section 5).
/// Pure Material 3 — no Cupertino counterpart (use BcSegmented for adaptive).
class BcTabs extends StatefulWidget {
  final List<BcTabItem> tabs;
  final int initialIndex;
  final ValueChanged<int>? onTabChanged;
  final bool isScrollable;

  const BcTabs({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onTabChanged,
    this.isScrollable = false,
  });

  @override
  State<BcTabs> createState() => _BcTabsState();
}

class _BcTabsState extends State<BcTabs> with TickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _controller.addListener(() {
      if (!_controller.indexIsChanging) {
        widget.onTabChanged?.call(_controller.index);
      }
    });
  }

  @override
  void didUpdateWidget(BcTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabs.length != oldWidget.tabs.length) {
      _controller.dispose();
      _controller = TabController(
        length: widget.tabs.length,
        vsync: this,
        initialIndex: widget.initialIndex.clamp(0, widget.tabs.length - 1),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _controller,
          isScrollable: widget.isScrollable,
          tabs: widget.tabs
              .map((t) => Tab(
                    text: t.label,
                    icon: t.icon != null ? Icon(t.icon) : null,
                  ))
              .toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: widget.tabs.map((t) => t.child).toList(),
          ),
        ),
      ],
    );
  }
}

class BcTabItem {
  final String label;
  final IconData? icon;
  final Widget child;

  const BcTabItem({required this.label, required this.child, this.icon});
}
