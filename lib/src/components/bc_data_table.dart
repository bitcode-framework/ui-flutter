library bc_data_table;

import 'package:flutter/material.dart';

/// Material-only data table (ADR-011 Section 5).
/// Pure Material 3 — no Cupertino counterpart.
class BcDataTable<T> extends StatefulWidget {
  final List<BcDataColumn<T>> columns;
  final List<T> rows;
  final bool sortable;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending)? onSort;
  final void Function(T row)? onRowTap;
  final Widget? emptyState;
  final bool showCheckboxColumn;
  final Set<int>? selectedIndices;
  final void Function(Set<int>)? onSelectionChanged;

  const BcDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.sortable = false,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.onRowTap,
    this.emptyState,
    this.showCheckboxColumn = false,
    this.selectedIndices,
    this.onSelectionChanged,
  });

  @override
  State<BcDataTable<T>> createState() => _BcDataTableState<T>();
}

class _BcDataTableState<T> extends State<BcDataTable<T>> {
  late Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<int>.from(widget.selectedIndices ?? {});
  }

  void _toggleRow(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else {
        _selected.add(index);
      }
    });
    widget.onSelectionChanged?.call(Set<int>.from(_selected));
  }

  void _toggleAll() {
    setState(() {
      if (_selected.length == widget.rows.length) {
        _selected.clear();
      } else {
        _selected = Set<int>.from(List.generate(widget.rows.length, (i) => i));
      }
    });
    widget.onSelectionChanged?.call(Set<int>.from(_selected));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rows.isEmpty && widget.emptyState != null) {
      return widget.emptyState!;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          sortColumnIndex: widget.sortColumnIndex,
          sortAscending: widget.sortAscending,
          showCheckboxColumn: widget.showCheckboxColumn,
          onSelectAll: widget.showCheckboxColumn ? (_) => _toggleAll() : null,
          columns: [
            // No manual checkbox column — Material DataTable renders it
            // automatically when showCheckboxColumn=true + onSelectChanged.
            ...widget.columns.map((col) => DataColumn(
                  label: Text(col.label),
                  numeric: col.numeric,
                  onSort: widget.sortable && col.sortable
                      ? (colIndex, ascending) {
                          final adjusted = colIndex -
                              (widget.showCheckboxColumn ? 1 : 0);
                          widget.onSort?.call(adjusted, ascending);
                        }
                      : null,
                )),
          ],
          rows: List.generate(widget.rows.length, (index) {
            final row = widget.rows[index];
            return DataRow(
              selected: _selected.contains(index),
              onSelectChanged: widget.showCheckboxColumn
                  ? (_) => _toggleRow(index)
                  : null,
              cells: [
                // No manual checkbox cell — Material DataTable renders it
                // automatically when showCheckboxColumn=true.
                ...widget.columns.map((col) => DataCell(
                      col.cellBuilder(context, row),
                      onTap: widget.onRowTap != null
                          ? () => widget.onRowTap!(row)
                          : null,
                    )),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class BcDataColumn<T> {
  final String label;
  final bool numeric;
  final bool sortable;
  final Widget Function(BuildContext context, T row) cellBuilder;

  const BcDataColumn({
    required this.label,
    required this.cellBuilder,
    this.numeric = false,
    this.sortable = true,
  });
}
