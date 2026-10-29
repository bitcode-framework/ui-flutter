library bc_field_table_select;

import 'package:flutter/material.dart';
import '../core/types.dart';
import 'bc_data_table.dart';

/// Selectable table field (ADR-011 Phase 5b.2).
///
/// Mirrors the TS `BcFieldTableSelect` contract: a data table with
/// single or multiple row selection. Reuses the P0 [BcDataTable] internally
/// to render the rows and column headers. Supports:
///   * Controlled `value` (String single, or List<String> multiple) and
///     uncontrolled `defaultValue` seeding
///   * `multiple` toggle for multi-select (preserves selection order)
///   * `searchable` + `searchFields` (case-insensitive substring match,
///     unioned across configured fields)
///   * `pageSize` for simple pagination (prev/next controls)
///   * `titleField` to derive the emitted value from a row's display field
///   * `clearable` clear button, `disabled`, `readonly` interaction guards
///   * `reset()` / `clear()` imperative methods
///
/// `onValueChange` fires with one of:
///   * [BcChangeReason.select] — row tapped to select
///   * [BcChangeReason.deselect] — multiple mode, row tapped to deselect
///   * [BcChangeReason.clear] — clear button or `clear()` imperative method
///   * [BcChangeReason.programmatic] — external `value` prop change
class BcFieldTableSelect extends StatefulWidget {
  final String? name;
  final String? label;
  final Object? value;
  final Object? defaultValue;
  final List<BcFieldTableSelectColumn>? columns;
  final List<Map<String, dynamic>>? data;
  final String? titleField;
  final bool? disabled;
  final bool? required;
  final bool? readonly;
  final bool? multiple;
  final num? pageSize;
  final bool? searchable;
  final List<String>? searchFields;
  final String? hint;
  final String? description;
  final bool? clearable;
  final String? emptyText;
  final String? className;
  final Map<String, dynamic>? slotProps;
  final BcChangeHandler<Object>? onValueChange;
  final void Function(Object)? onChange;

  const BcFieldTableSelect({
    super.key,
    this.name,
    this.label,
    this.value,
    this.defaultValue,
    this.columns,
    this.data,
    this.titleField,
    this.disabled,
    this.required,
    this.readonly,
    this.multiple,
    this.pageSize,
    this.searchable,
    this.searchFields,
    this.hint,
    this.description,
    this.clearable,
    this.emptyText,
    this.className,
    this.slotProps,
    this.onValueChange,
    this.onChange,
  });

  @override
  State<BcFieldTableSelect> createState() => BcFieldTableSelectState();
}

class BcFieldTableSelectState extends State<BcFieldTableSelect> {
  static const String _rootKeyPrefix = 'bc-field-table-select-';
  static const String _searchKey = '${_rootKeyPrefix}search';
  static const String _clearKey = '${_rootKeyPrefix}clear';
  static const String _prevKey = '${_rootKeyPrefix}prev';
  static const String _nextKey = '${_rootKeyPrefix}next';
  static const String _pageInfoKey = '${_rootKeyPrefix}page-info';
  static const String _rootSemanticsKey = '${_rootKeyPrefix}root';

  late final TextEditingController _searchController;
  String _searchQuery = '';
  int _currentPage = 0;
  bool _isControlled = false;
  Object? _lastWidgetValue;
  List<String> _internalSelection = <String>[];
  String _internalSingle = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _isControlled = widget.value != null;
    _initializeFromValue(widget.value ?? widget.defaultValue);
    _lastWidgetValue = _isControlled ? widget.value : null;
  }

  void _initializeFromValue(Object? value) {
    if (widget.multiple ?? false) {
      _internalSelection = _coerceList(value);
    } else {
      _internalSingle = _coerceString(value);
    }
  }

  @override
  void didUpdateWidget(BcFieldTableSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasControlled = oldWidget.value != null;
    _isControlled = widget.value != null;

    if (_isControlled) {
      final next = widget.value;
      if (next != _lastWidgetValue) {
        _lastWidgetValue = next;
        _initializeFromValue(next);
        // Controlled value updates do not fire onValueChange (per VAL-TS-021
        // and VAL-TS-026: programmatic source is implied but not emitted).
        if (mounted) setState(() {});
      }
    } else if (!wasControlled && widget.defaultValue != null) {
      _initializeFromValue(widget.defaultValue);
    }

    // Multiple mode toggled: re-seed internal state from current value.
    if ((oldWidget.multiple ?? false) != (widget.multiple ?? false)) {
      _initializeFromValue(_isControlled ? widget.value : widget.defaultValue);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isDisabled => widget.disabled ?? false;
  bool get _isReadonly => widget.readonly ?? false;
  bool get _isMultiple => widget.multiple ?? false;
  int get _pageSize => widget.pageSize?.toInt() ?? 0;
  bool get _isSearchable => widget.searchable ?? false;
  bool get _isClearable => widget.clearable ?? false;
  List<String> get _searchFields => widget.searchFields ?? const <String>[];

  bool get _hasSelection =>
      _isMultiple ? _internalSelection.isNotEmpty : _internalSingle.isNotEmpty;

  List<Map<String, dynamic>> get _effectiveData {
    final data = widget.data ?? const <Map<String, dynamic>>[];
    if (!_isSearchable || _searchQuery.isEmpty || _searchFields.isEmpty) {
      return data;
    }
    final query = _searchQuery.toLowerCase();
    return data.where((row) {
      for (final field in _searchFields) {
        final cellValue = row[field];
        if (cellValue != null &&
            cellValue.toString().toLowerCase().contains(query)) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  List<Map<String, dynamic>> get _pagedData {
    final data = _effectiveData;
    if (_pageSize <= 0 || data.length <= _pageSize) {
      return data;
    }
    if (_currentPage * _pageSize >= data.length) {
      _currentPage = (data.length / _pageSize).ceil() - 1;
      if (_currentPage < 0) _currentPage = 0;
    }
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, data.length);
    return data.sublist(start, end);
  }

  int get _totalPages {
    if (_pageSize <= 0) return 1;
    final data = _effectiveData;
    if (data.isEmpty) return 1;
    return (data.length / _pageSize).ceil();
  }

  String _rowTitle(Map<String, dynamic> row) {
    final titleField = widget.titleField;
    if (titleField != null && row[titleField] != null) {
      return row[titleField].toString();
    }
    return row['id']?.toString() ?? '';
  }

  bool _isRowSelected(Map<String, dynamic> row) {
    final title = _rowTitle(row);
    if (_isMultiple) {
      return _internalSelection.contains(title);
    }
    return _internalSingle == title;
  }

  void _handleRowTap(Map<String, dynamic> row) {
    if (_isDisabled || _isReadonly) return;
    final title = _rowTitle(row);
    if (_isMultiple) {
      final next = List<String>.from(_internalSelection);
      BcChangeReason reason;
      if (next.contains(title)) {
        next.remove(title);
        reason = BcChangeReason.deselect;
      } else {
        next.add(title);
        reason = BcChangeReason.select;
      }
      _internalSelection = next;
      _emit(List<String>.from(next), reason, source: BcEventSource.pointer);
    } else {
      _internalSingle = title;
      _emit(title, BcChangeReason.select, source: BcEventSource.pointer);
    }
  }

  void _handleClear() {
    if (_isDisabled || _isReadonly) return;
    if (_isMultiple) {
      _internalSelection = <String>[];
      _emit(<String>[], BcChangeReason.clear, source: BcEventSource.pointer);
    } else {
      _internalSingle = '';
      _emit('', BcChangeReason.clear, source: BcEventSource.pointer);
    }
  }

  void _handleSearchChanged(String text) {
    if (_isDisabled || _isReadonly) return;
    setState(() {
      _searchQuery = text;
      _currentPage = 0;
    });
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page.clamp(0, _totalPages - 1);
    });
  }

  void _emit(Object value, BcChangeReason reason,
      {BcEventSource source = BcEventSource.programmatic}) {
    _lastWidgetValue = value;
    widget.onValueChange?.call(value, BcChangeMeta(reason: reason, source: source));
    widget.onChange?.call(value);
    if (mounted) setState(() {});
  }

  /// Imperative reset: clears selection without firing [onValueChange].
  void reset() {
    setState(() {
      _internalSelection = <String>[];
      _internalSingle = '';
      _searchQuery = '';
      _searchController.clear();
      _currentPage = 0;
    });
  }

  /// Imperative clear: clears selection and fires [onValueChange] with
  /// [BcChangeReason.clear].
  void clear() {
    if (_isMultiple) {
      _internalSelection = <String>[];
      _emit(<String>[], BcChangeReason.clear, source: BcEventSource.programmatic);
    } else {
      _internalSingle = '';
      _emit('', BcChangeReason.clear, source: BcEventSource.programmatic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final columns = widget.columns ?? const <BcFieldTableSelectColumn>[];
    final effectiveData = _pagedData;

    final List<BcDataColumn<Map<String, dynamic>>> dataColumns = columns
        .map((col) => BcDataColumn<Map<String, dynamic>>(
              label: col.label,
              cellBuilder: (context, row) => Text(_cellText(row, col.key)),
            ))
        .toList();

    final Widget tableArea;
    if (effectiveData.isEmpty) {
      final emptyText = widget.emptyText ?? 'No data';
      tableArea = Semantics(
        container: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Center(child: Text(emptyText)),
        ),
      );
    } else {
      tableArea = BcDataTable<Map<String, dynamic>>(
        columns: dataColumns,
        rows: effectiveData,
        onRowTap: _handleRowTap,
        showCheckboxColumn: _isMultiple && !_isDisabled && !_isReadonly,
        selectedIndices: _selectedIndicesFor(effectiveData),
      );
    }

    final List<Widget> headerItems = <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      widget.label!,
                      style: theme.textTheme.labelMedium,
                    ),
                    if (widget.required ?? false)
                      const Padding(
                        padding: EdgeInsets.only(left: 2),
                        child: Text('*', style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
            if (widget.hint != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  widget.hint!,
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
      if (_isClearable && _hasSelection)
        IconButton(
          key: const ValueKey<String>(_clearKey),
          icon: const Icon(Icons.close, size: 18),
          onPressed: (_isDisabled || _isReadonly) ? null : _handleClear,
          tooltip: 'Clear',
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: EdgeInsets.zero,
        ),
    ];

    final Widget? searchField = _isSearchable
        ? Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextField(
              key: const ValueKey<String>(_searchKey),
              controller: _searchController,
              enabled: !_isDisabled && !_isReadonly,
              readOnly: _isReadonly,
              decoration: const InputDecoration(
                hintText: 'Search...',
                isDense: true,
                prefixIcon: Icon(Icons.search, size: 18),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              onChanged: _handleSearchChanged,
            ),
          )
        : null;

    final Widget? paginationControls = _pageSize > 0 &&
            _effectiveData.length > _pageSize
        ? Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  key: const ValueKey<String>(_prevKey),
                  icon: const Icon(Icons.chevron_left, size: 20),
                  onPressed: _currentPage > 0 ? () => _goToPage(_currentPage - 1) : null,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
                Text(
                  key: const ValueKey<String>(_pageInfoKey),
                  '${_currentPage + 1} / $_totalPages',
                  style: theme.textTheme.bodySmall,
                ),
                IconButton(
                  key: const ValueKey<String>(_nextKey),
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed: _currentPage < _totalPages - 1
                      ? () => _goToPage(_currentPage + 1)
                      : null,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          )
        : null;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: headerItems,
          ),
        ),
        if (searchField != null) searchField,
        Flexible(
          fit: FlexFit.loose,
          child: tableArea,
        ),
        if (paginationControls != null) paginationControls,
        if (widget.description != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              widget.description!,
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );

    return Semantics(
      key: const ValueKey<String>(_rootSemanticsKey),
      container: true,
      label: 'grid',
      child: Semantics(
        container: true,
        child: Opacity(
          opacity: _isDisabled ? 0.5 : 1.0,
          child: AbsorbPointer(
            absorbing: _isDisabled,
            child: body,
          ),
        ),
      ),
    );
  }

  Set<int> _selectedIndicesFor(List<Map<String, dynamic>> rows) {
    final result = <int>{};
    for (var i = 0; i < rows.length; i++) {
      if (_isRowSelected(rows[i])) {
        result.add(i);
      }
    }
    return result;
  }

  String _cellText(Map<String, dynamic> row, String key) {
    final value = row[key];
    return value?.toString() ?? '';
  }
}

List<String> _coerceList(Object? value) {
  if (value == null) return <String>[];
  if (value is List<String>) return List<String>.from(value);
  if (value is List) {
    return value.map((e) => e?.toString() ?? '').toList();
  }
  if (value is String && value.isNotEmpty) {
    return <String>[value];
  }
  return <String>[];
}

String _coerceString(Object? value) {
  if (value == null) return '';
  return value.toString();
}
