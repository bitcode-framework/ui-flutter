library bc_grid_view;

import 'package:flutter/material.dart';

import '../core/bc_i18n.dart';
import '../theme/bc_theme.dart';

/// Column definition for the spreadsheet-like grid.
class BcGridViewColumn {
  final String key;
  final String label;
  final bool editable;
  final double? width;

  const BcGridViewColumn({
    required this.key,
    required this.label,
    this.editable = false,
    this.width,
  });
}

/// Spreadsheet-like editable grid (ADR-006 Adapt).
///
/// Flutter implementation uses Material DataTable with display-only rows
/// (mobile parity with RN: no inline edit on small screens). Rows are
/// display + onTap.
class BcGridView extends StatelessWidget {
  final List<BcGridViewColumn> columns;
  final List<Map<String, dynamic>> rows;
  final bool cellEditable;
  final String emptyText;
  final void Function(Map<String, dynamic> row, int index)? onRowSelect;
  final void Function(
    Map<String, dynamic> row,
    BcGridViewColumn col,
    String value,
    int rowIndex,
  )? onCellChange;

  const BcGridView({
    super.key,
    required this.columns,
    required this.rows,
    this.cellEditable = false,
    this.emptyText = 'No data',
    this.onRowSelect,
    this.onCellChange,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Container(
        key: const Key('bc-grid-view'),
        decoration: BoxDecoration(
          border: Border.all(color: BcTheme.border),
          borderRadius: BorderRadius.circular(BcTheme.radius),
        ),
        padding: const EdgeInsets.all(32),
        child: Center(
          key: const Key('bc-grid-view-empty'),
          child: Text(
            emptyText,
            style: const TextStyle(fontSize: 14, color: BcTheme.mutedForeground),
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      label: bcI18n.t('bc.gridView.ariaLabel'),
      child: Container(
        key: const Key('bc-grid-view'),
        decoration: BoxDecoration(
          border: Border.all(color: BcTheme.border),
          borderRadius: BorderRadius.circular(BcTheme.radius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Header
            Container(
              key: const Key('bc-grid-view-header'),
              color: BcTheme.muted,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: columns.map((col) {
                  return Expanded(
                    flex: 1,
                    child: Text(
                      col.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: BcTheme.mutedForeground,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Rows
            ...rows.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              return InkWell(
                key: Key('bc-grid-view-row-$index'),
                onTap: () => onRowSelect?.call(row, index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  constraints: const BoxConstraints(minHeight: 44),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: BcTheme.border, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: columns.map((col) {
                      final v = row[col.key];
                      return Expanded(
                        flex: 1,
                        child: Text(
                          v == null ? '' : v.toString(),
                          style: const TextStyle(fontSize: 14, color: BcTheme.foreground),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
