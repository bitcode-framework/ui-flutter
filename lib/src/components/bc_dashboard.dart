library bc_dashboard;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../core/bc_i18n.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// The kind of widget rendered in the dashboard card.
enum BcDashboardWidgetKind { stat, chart, table, list, custom }

/// A single dashboard widget configuration.
class BcDashboardWidget {
  final String id;
  final String? title;
  final int span;
  final BcDashboardWidgetKind kind;
  final Map<String, dynamic>? props;

  const BcDashboardWidget({
    required this.id,
    required this.kind,
    this.title,
    this.span = 1,
    this.props,
  });
}

/// Grid of widgets with configurable layout (ADR-003 P0 view).
///
/// Renders a grid of widget cards. The actual widget rendering is
/// delegated to a `renderWidget` callback (defaults to a placeholder
/// showing the kind + title).
class BcDashboard extends StatelessWidget {
  final List<BcDashboardWidget> widgets;
  final int columns;
  final double gap;
  final bool loading;
  final String emptyText;
  final Widget Function(BcDashboardWidget widget)? renderWidget;
  final void Function(BcDashboardWidget widget, BcChangeMeta meta)? onWidgetClick;

  const BcDashboard({
    super.key,
    required this.widgets,
    this.columns = 3,
    this.gap = 16,
    this.loading = false,
    this.emptyText = 'No widgets',
    this.renderWidget,
    this.onWidgetClick,
  });

  String _kindLabel(BcDashboardWidgetKind kind) {
    switch (kind) {
      case BcDashboardWidgetKind.stat: return 'stat';
      case BcDashboardWidgetKind.chart: return 'chart';
      case BcDashboardWidgetKind.table: return 'table';
      case BcDashboardWidgetKind.list: return 'list';
      case BcDashboardWidgetKind.custom: return 'custom';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: bcI18n.t('bc.dashboard.ariaLabel'),
      child: Container(
        key: const Key('bc-dashboard'),
        child: loading
            ? const Center(
                key: Key('bc-dashboard-loading'),
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Loading...',
                    style: TextStyle(fontSize: 14, color: BcTheme.mutedForeground),
                  ),
                ),
              )
            : widgets.isEmpty
                ? Center(
                    key: const Key('bc-dashboard-empty'),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        emptyText,
                        style: const TextStyle(fontSize: 14, color: BcTheme.mutedForeground),
                      ),
                    ),
                  )
                : GridView.builder(
                    key: const Key('bc-dashboard-grid'),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns.clamp(1, 12),
                      crossAxisSpacing: gap,
                      mainAxisSpacing: gap,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: widgets.length,
                    itemBuilder: (context, index) {
                      final widget = widgets[index];
                      return _buildWidgetCard(widget);
                    },
                  ),
      ),
    );
  }

  Widget _buildWidgetCard(BcDashboardWidget widget) {
    return GestureDetector(
      key: Key('bc-dashboard-widget-${widget.id}'),
      onTap: () => onWidgetClick?.call(
        widget,
        const BcChangeMeta(reason: BcChangeReason.select, source: BcEventSource.pointer),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: BcTheme.card,
          borderRadius: BorderRadius.circular(BcTheme.radius),
          border: Border.all(color: BcTheme.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title!,
                        key: Key('bc-dashboard-widget-title-${widget.id}'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: BcTheme.cardForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: renderWidget != null
                  ? renderWidget!(widget)
                  : Center(
                      key: Key('bc-dashboard-widget-body-${widget.id}'),
                      child: Text(
                        '[${_kindLabel(widget.kind)}] ${widget.title ?? ''}'.trim(),
                        style: const TextStyle(fontSize: 14, color: BcTheme.mutedForeground),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
