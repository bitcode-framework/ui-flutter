library bc_detail_view;

import 'package:flutter/material.dart';

import '../core/bc_i18n.dart';
import '../theme/bc_theme.dart';

/// A single field row in the descriptions-style grid.
class BcDetailViewField {
  final String label;
  final Object? value;
  final String? type;

  const BcDetailViewField({
    required this.label,
    this.value,
    this.type,
  });
}

/// A header action button.
class BcDetailViewAction {
  final String label;
  final VoidCallback? onClick;
  final BcDetailViewActionVariant variant;

  const BcDetailViewAction({
    required this.label,
    this.onClick,
    this.variant = BcDetailViewActionVariant.secondary,
  });
}

enum BcDetailViewActionVariant { primary, secondary, outline, destructive }

/// Master-detail record renderer.
///
/// Reads a flat field schema and composes either a descriptions-style
/// field grid or a simple card body. Pure (no data fetching).
class BcDetailView extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<BcDetailViewField>? fields;
  final List<Widget>? tabs;
  final List<BcDetailViewAction>? actions;
  final String emptyText;
  final bool loading;

  const BcDetailView({
    super.key,
    this.title,
    this.subtitle,
    this.fields,
    this.tabs,
    this.actions,
    this.emptyText = 'No data',
    this.loading = false,
  });

  String _formatValue(BcDetailViewField field) {
    final v = field.value;
    if (v == null) return '\u2014';
    switch (field.type) {
      case 'boolean':
        return v == true ? 'Yes' : 'No';
      case 'date':
        if (v is DateTime) return _formatDate(v);
        return v.toString();
      case 'currency':
        if (v is num) return '\$${v.toStringAsFixed(2)}';
        return v.toString();
      default:
        return v.toString();
    }
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Color _variantColor(BcDetailViewActionVariant variant) {
    switch (variant) {
      case BcDetailViewActionVariant.primary:
        return BcTheme.primary;
      case BcDetailViewActionVariant.secondary:
        return BcTheme.secondary;
      case BcDetailViewActionVariant.outline:
        return BcTheme.background;
      case BcDetailViewActionVariant.destructive:
        return BcTheme.destructive;
    }
  }

  Color _variantForeground(BcDetailViewActionVariant variant) {
    switch (variant) {
      case BcDetailViewActionVariant.primary:
        return BcTheme.primaryForeground;
      case BcDetailViewActionVariant.secondary:
        return BcTheme.secondaryForeground;
      case BcDetailViewActionVariant.outline:
        return BcTheme.foreground;
      case BcDetailViewActionVariant.destructive:
        return BcTheme.destructiveForeground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFields = fields != null && fields!.isNotEmpty;
    final hasTabs = tabs != null && tabs!.isNotEmpty;
    final isEmpty = !hasFields && !hasTabs;
    final hasHeader = title != null || subtitle != null || (actions != null && actions!.isNotEmpty);

    return Semantics(
      container: true,
      label: title ?? bcI18n.t('bc.detailView.ariaLabel'),
      child: Container(
        key: const Key('bc-detail-view'),
        decoration: BoxDecoration(
          color: BcTheme.card,
          borderRadius: BorderRadius.circular(BcTheme.radius),
          border: Border.all(color: BcTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasHeader) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null)
                            Text(
                              title!,
                              key: const Key('bc-detail-view-title'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: BcTheme.cardForeground,
                              ),
                            ),
                          if (subtitle != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                subtitle!,
                                key: const Key('bc-detail-view-subtitle'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: BcTheme.mutedForeground,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (actions != null && actions!.isNotEmpty)
                      Row(
                        key: const Key('bc-detail-view-actions'),
                        children: actions!.map((action) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: TextButton(
                              key: Key('bc-detail-view-action-${action.label}'),
                              style: TextButton.styleFrom(
                                minimumSize: const Size(44, 36),
                                backgroundColor: _variantColor(action.variant),
                                foregroundColor: _variantForeground(action.variant),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: action.onClick,
                              child: Text(action.label),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
            ],
            if (loading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  key: Key('bc-detail-view-loading'),
                  child: Text(
                    'Loading...',
                    style: TextStyle(fontSize: 14, color: BcTheme.mutedForeground),
                  ),
                ),
              )
            else if (isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  key: const Key('bc-detail-view-empty'),
                  child: Text(
                    emptyText,
                    style: const TextStyle(fontSize: 14, color: BcTheme.mutedForeground),
                  ),
                ),
              )
            else if (hasFields)
              Padding(
                key: const Key('bc-detail-view-fields'),
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  children: fields!.map((field) {
                    return SizedBox(
                      width: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            field.label.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: BcTheme.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatValue(field),
                            style: const TextStyle(
                              fontSize: 14,
                              color: BcTheme.foreground,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
            else if (hasTabs)
              Padding(
                key: const Key('bc-detail-view-tabs'),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: tabs!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
