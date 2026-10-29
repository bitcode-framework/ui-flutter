library bc_pivot;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/bc_theme.dart';

/// Aggregation function for a pivot value field.
///
/// Mirrors TS `BcPivotAggFunc`.
enum BcPivotAggFunc {
  sum,
  count,
  avg,
  min,
  max;

  String get id {
    switch (this) {
      case BcPivotAggFunc.sum:
        return 'sum';
      case BcPivotAggFunc.count:
        return 'count';
      case BcPivotAggFunc.avg:
        return 'avg';
      case BcPivotAggFunc.min:
        return 'min';
      case BcPivotAggFunc.max:
        return 'max';
    }
  }

  static BcPivotAggFunc fromString(String s) {
    switch (s) {
      case 'sum':
        return BcPivotAggFunc.sum;
      case 'count':
        return BcPivotAggFunc.count;
      case 'avg':
        return BcPivotAggFunc.avg;
      case 'min':
        return BcPivotAggFunc.min;
      case 'max':
        return BcPivotAggFunc.max;
      default:
        return BcPivotAggFunc.sum;
    }
  }
}

/// A single measure (field + aggregation) in the pivot.
///
/// Mirrors TS `BcPivotValueField`.
class BcPivotValueField {
  final String field;
  final BcPivotAggFunc agg;
  final String? alias;

  const BcPivotValueField({
    required this.field,
    this.agg = BcPivotAggFunc.sum,
    this.alias,
  });

  String get label => alias ?? '${agg.id}_$field';

  Map<String, dynamic> toJson() => {
        'field': field,
        'agg': agg.id,
        if (alias != null) 'alias': alias,
      };
}

/// The computed pivot matrix returned by the engine.
///
/// Mirrors TS `BcPivotResult`. Cells is indexed [rowIndex][colIndex][valueIndex].
class BcPivotResult {
  final List<String> rowHeaders;
  final List<String> colHeaders;
  final List<List<List<double>>> cells;
  final List<List<double>> rowTotals;
  final List<List<double>> colTotals;
  final List<double> grandTotal;
  final List<BcPivotValueField> valueFields;

  const BcPivotResult({
    required this.rowHeaders,
    required this.colHeaders,
    required this.cells,
    required this.rowTotals,
    required this.colTotals,
    required this.grandTotal,
    required this.valueFields,
  });

  bool get isEmpty => rowHeaders.isEmpty;

  factory BcPivotResult.fromJson(Map<String, dynamic> json) {
    return BcPivotResult(
      rowHeaders: (json['rowHeaders'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      colHeaders: (json['colHeaders'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      cells: (json['cells'] as List<dynamic>?)
              ?.map((row) => (row as List<dynamic>)
                  .map((cell) => (cell as List<dynamic>)
                      .map((v) => (v as num).toDouble())
                      .toList())
                  .toList())
              .toList() ??
          [],
      rowTotals: (json['rowTotals'] as List<dynamic>?)
              ?.map((row) => (row as List<dynamic>)
                  .map((v) => (v as num).toDouble())
                  .toList())
              .toList() ??
          [],
      colTotals: (json['colTotals'] as List<dynamic>?)
              ?.map((col) => (col as List<dynamic>)
                  .map((v) => (v as num).toDouble())
                  .toList())
              .toList() ??
          [],
      grandTotal: (json['grandTotal'] as List<dynamic>?)
              ?.map((v) => (v as num).toDouble())
              .toList() ??
          [],
      valueFields: (json['valueFields'] as List<dynamic>?)
              ?.map((vf) => BcPivotValueField(
                    field: vf['field'] as String,
                    agg: BcPivotAggFunc.fromString(vf['agg'] as String),
                    alias: vf['alias'] as String?,
                  ))
              .toList() ??
          [],
    );
  }
}

/// Declarative data source for server-side pivot computation.
///
/// Mirrors TS `BcPivotDataSource`.
class BcPivotDataSource {
  final String? endpoint;
  final String? model;

  const BcPivotDataSource({this.endpoint, this.model});
}

/// A pivot table widget that renders a 2D OLAP matrix with row/column
/// totals, grand total, expandable rows, and no-data state.
///
/// Mirrors TS `BcPivotContract`. Platform-aware: Material uses a
/// DataTable-based grid; Cupertino uses a Cupertino-styled card.
///
/// ADR-014 additions: [rows], [cols], [values], [filter], [dataSource] enable
/// declarative server-side pivots. When [result] is provided directly, it
/// renders without a fetch. [showTotals] / [showGrandTotal] control the total
/// rows/columns.
class BcPivot extends StatefulWidget {
  /// Row dimension field names.
  final List<String> rows;

  /// Column dimension field names.
  final List<String> cols;

  /// Value field measures to aggregate.
  final List<BcPivotValueField> values;

  /// Optional filter applied before aggregation.
  final Map<String, dynamic>? filter;

  /// Server-side pivot endpoint for declarative data loading.
  final BcPivotDataSource? dataSource;

  /// Pre-computed result. When set, the widget renders without fetching.
  final BcPivotResult? result;

  /// Whether to show row/column totals.
  final bool showTotals;

  /// Whether to show the grand total row.
  final bool showGrandTotal;

  /// Optional title displayed above the table.
  final String? title;

  /// No-data placeholder text.
  final String noDataText;

  /// Label for total header.
  final String totalLabel;

  /// Label for grand total row.
  final String grandTotalLabel;

  /// Loading placeholder text.
  final String loadingText;

  const BcPivot({
    super.key,
    this.rows = const [],
    this.cols = const [],
    this.values = const [],
    this.filter,
    this.dataSource,
    this.result,
    this.showTotals = true,
    this.showGrandTotal = true,
    this.title,
    this.noDataText = 'No data to display',
    this.totalLabel = 'Total',
    this.grandTotalLabel = 'Grand Total',
    this.loadingText = 'Loading pivot data...',
  });

  @override
  State<BcPivot> createState() => _BcPivotState();
}

class _BcPivotState extends State<BcPivot> {
  BcPivotResult? _loadedResult;
  bool _loading = false;
  String? _error;
  final Set<String> _collapsedRows = {};

  BcPivotResult? get _effectiveResult => widget.result ?? _loadedResult;

  bool get _isLoading => _loading;

  bool get _hasError => _error != null;

  bool _isExpanded(String rowKey) => !_collapsedRows.contains(rowKey);

  void _toggleRow(String rowKey) {
    setState(() {
      if (_collapsedRows.contains(rowKey)) {
        _collapsedRows.remove(rowKey);
      } else {
        _collapsedRows.add(rowKey);
      }
    });
  }

  String _formatCell(double value) {
    if (value.isNaN || value.isInfinite) return '-';
    final rounded = (value * 100).round() / 100;
    if (rounded == rounded.roundToDouble()) {
      return rounded.toInt().toString();
    }
    return rounded.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isCupertino =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    // The web adapter renders `bc-pivot-container` as an `overflow-auto` block
    // with no fixed height: it grows with its content and scrolls only when a
    // parent constrains it. Mirror that here. `Expanded` requires a bounded
    // height, so using it unconditionally crashes as soon as a consumer places
    // the pivot in a vertical scroll view.
    return LayoutBuilder(
      builder: (context, constraints) {
        final fillHeight = constraints.hasBoundedHeight;
        if (isCupertino) {
          return _buildCupertino(context, fillHeight: fillHeight);
        }
        return _buildMaterial(context, fillHeight: fillHeight);
      },
    );
  }

  Widget _buildMaterial(BuildContext context, {required bool fillHeight}) {
    return Container(
      key: const Key('bc-pivot-container'),
      decoration: BoxDecoration(
        color: BcTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BcTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                widget.title!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: BcTheme.foreground,
                ),
              ),
            ),
          if (fillHeight)
            Expanded(child: _buildBody(context))
          else
            _buildBody(context),
        ],
      ),
    );
  }

  Widget _buildCupertino(BuildContext context, {required bool fillHeight}) {
    return Container(
      key: const Key('bc-pivot-container'),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BcTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                widget.title!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: BcTheme.foreground,
                ),
              ),
            ),
          if (fillHeight)
            Expanded(child: _buildBody(context))
          else
            _buildBody(context),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 8),
            Text(
              widget.loadingText,
              style: TextStyle(color: BcTheme.mutedForeground, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _error!,
            style: TextStyle(color: BcTheme.destructive, fontSize: 13),
          ),
        ),
      );
    }

    final result = _effectiveResult;
    if (result == null || result.isEmpty) {
      return Center(
        child: Text(
          widget.noDataText,
          style: TextStyle(color: BcTheme.mutedForeground, fontSize: 13),
        ),
      );
    }

    return _buildTable(context, result);
  }

  Widget _buildTable(BuildContext context, BcPivotResult result) {
    final nValues = result.valueFields.isNotEmpty
        ? result.valueFields.length
        : 1;
    final nCols = result.colHeaders.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          key: const Key('bc-pivot-table'),
          headingRowColor: WidgetStateProperty.all(BcTheme.muted),
          dataRowColor: WidgetStateProperty.all(BcTheme.background),
          columnSpacing: 16,
          horizontalMargin: 12,
          columns: _buildColumns(result, nCols, nValues),
          rows: _buildRows(result, nCols, nValues),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns(
      BcPivotResult result, int nCols, int nValues) {
    final cols = <DataColumn>[];

    cols.add(DataColumn(
      label: Text(
        widget.rows.join(' / '),
        style: TextStyle(fontWeight: FontWeight.w600, color: BcTheme.foreground),
      ),
    ));

    for (final colHeader in result.colHeaders) {
      cols.add(DataColumn(
        label: Text(
          colHeader,
          style: TextStyle(fontWeight: FontWeight.w600, color: BcTheme.foreground),
        ),
      ));
    }

    if (widget.showTotals) {
      cols.add(DataColumn(
        label: Text(
          widget.totalLabel,
          style: TextStyle(fontWeight: FontWeight.bold, color: BcTheme.foreground),
        ),
      ));
    }

    return cols;
  }

  List<DataRow> _buildRows(
      BcPivotResult result, int nCols, int nValues) {
    final rows = <DataRow>[];

    for (int ri = 0; ri < result.rowHeaders.length; ri++) {
      final rowHeader = result.rowHeaders[ri];
      final expanded = _isExpanded(rowHeader);

      final cells = <DataCell>[];

      cells.add(DataCell(
        InkWell(
          onTap: () => _toggleRow(rowHeader),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                expanded ? Icons.expand_more : Icons.chevron_right,
                size: 16,
                color: BcTheme.mutedForeground,
              ),
              const SizedBox(width: 4),
              Text(
                rowHeader,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: BcTheme.foreground,
                ),
              ),
            ],
          ),
        ),
      ));

      for (int ci = 0; ci < nCols; ci++) {
        if (expanded) {
          final cellValues = result.cells[ri][ci];
          final parts = <String>[];
          for (int vi = 0; vi < cellValues.length; vi++) {
            parts.add(_formatCell(cellValues[vi]));
          }
          cells.add(DataCell(Text(
            parts.join(', '),
            style: TextStyle(
              fontFeatures: const [FontFeature.tabularFigures()],
              color: BcTheme.foreground,
            ),
          )));
        } else {
          cells.add(DataCell(Text(
            '···',
            style: TextStyle(color: BcTheme.mutedForeground),
          )));
        }
      }

      if (widget.showTotals) {
        if (expanded) {
          final rowTotal = result.rowTotals[ri];
          final parts = <String>[];
          for (int vi = 0; vi < rowTotal.length; vi++) {
            parts.add(_formatCell(rowTotal[vi]));
          }
          cells.add(DataCell(Text(
            parts.join(', '),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: BcTheme.foreground,
            ),
          )));
        } else {
          cells.add(DataCell(Text(
            '···',
            style: TextStyle(color: BcTheme.mutedForeground),
          )));
        }
      }

      rows.add(DataRow(
        key: ValueKey('bc-pivot-row-$ri'),
        cells: cells,
      ));
    }

    if (widget.showGrandTotal) {
      final grandCells = <DataCell>[];

      grandCells.add(DataCell(Text(
        widget.grandTotalLabel,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: BcTheme.foreground,
        ),
      )));

      for (int ci = 0; ci < nCols; ci++) {
        final colTotal = result.colTotals[ci];
        final parts = <String>[];
        for (int vi = 0; vi < colTotal.length; vi++) {
          parts.add(_formatCell(colTotal[vi]));
        }
        grandCells.add(DataCell(Text(
          parts.join(', '),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: BcTheme.foreground,
          ),
        )));
      }

      if (widget.showTotals) {
        final parts = <String>[];
        for (int vi = 0; vi < result.grandTotal.length; vi++) {
          parts.add(_formatCell(result.grandTotal[vi]));
        }
        grandCells.add(DataCell(Text(
          parts.join(', '),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: BcTheme.foreground,
          ),
        )));
      }

      rows.add(DataRow(
        key: const ValueKey('bc-pivot-grand-total'),
        color: WidgetStateProperty.all(BcTheme.muted),
        cells: grandCells,
      ));
    }

    return rows;
  }
}
