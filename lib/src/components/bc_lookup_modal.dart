library bc_lookup_modal;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/types.dart';
import 'bc_data_table.dart';

class BcLookupModal extends StatefulWidget {
  final bool? open;
  final bool? defaultOpen;
  final String? title;
  final String? model;
  final List<BcLookupModalColumn>? columns;
  final List<Map<String, dynamic>>? data;
  final bool? searchable;
  final List<String>? searchFields;
  final num? pageSize;
  final bool? multiple;
  final Object? value;
  final Object? defaultValue;
  final bool? closeable;
  final bool? closeOnOverlay;
  final Object? source;
  final String? className;
  final Map<String, dynamic>? slotProps;
  final BcChangeHandler<Object>? onValueChange;
  final BcChangeHandler<bool>? onOpenChange;
  final void Function(Object)? onChange;

  const BcLookupModal({
    super.key,
    this.open,
    this.defaultOpen,
    this.title,
    this.model,
    this.columns,
    this.data,
    this.searchable,
    this.searchFields,
    this.pageSize,
    this.multiple,
    this.value,
    this.defaultValue,
    this.closeable,
    this.closeOnOverlay,
    this.source,
    this.className,
    this.slotProps,
    this.onValueChange,
    this.onOpenChange,
    this.onChange,
  });

  @override
  State<BcLookupModal> createState() => BcLookupModalState();
}

class BcLookupModalState extends State<BcLookupModal> {
  static const int _defaultPageSize = 10;

  bool _internalOpen = false;
  bool _isControlledOpen = false;
  bool? _lastOpenProp;

  String _internalSingle = '';
  List<String> _internalMultiple = <String>[];
  bool _isControlledValue = false;
  Object? _lastValueProp;

  late final TextEditingController _searchController;
  String _searchQuery = '';
  int _currentPage = 0;

  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _isControlledOpen = widget.open != null;
    _lastOpenProp = widget.open;
    _internalOpen = widget.open ?? widget.defaultOpen ?? false;

    _isControlledValue = widget.value != null;
    _lastValueProp = widget.value;
    _initializeSelection(widget.value ?? widget.defaultValue);

    _searchController = TextEditingController();
    _focusNode = FocusNode(debugLabel: 'BcLookupModal');
  }

  void _initializeSelection(Object? value) {
    if (_isMultiple) {
      _internalMultiple = _coerceList(value);
    } else {
      _internalSingle = _coerceString(value);
    }
  }

  @override
  void didUpdateWidget(BcLookupModal oldWidget) {
    super.didUpdateWidget(oldWidget);

    final wasControlledOpen = oldWidget.open != null;
    _isControlledOpen = widget.open != null;

    if (_isControlledOpen) {
      if (widget.open != _lastOpenProp) {
        final wasOpen = _lastOpenProp ?? false;
        final nowOpen = widget.open!;
        _lastOpenProp = widget.open;
        if (nowOpen != wasOpen) {
          _applyOpen(nowOpen, BcChangeReason.toggle);
        }
      }
    } else if (!wasControlledOpen) {
      _internalOpen = widget.defaultOpen ?? false;
    }

    _isControlledValue = widget.value != null;
    if (_isControlledValue && widget.value != _lastValueProp) {
      _lastValueProp = widget.value;
      _initializeSelection(widget.value);
    }

    if ((oldWidget.multiple ?? false) != (widget.multiple ?? false)) {
      _initializeSelection(
          _isControlledValue ? widget.value : widget.defaultValue);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _isMultiple => widget.multiple ?? false;
  bool get _isSearchable => widget.searchable ?? false;
  bool get _isCloseable => widget.closeable ?? true;
  bool get _closeOnOverlay => widget.closeOnOverlay ?? false;
  int get _pageSize => widget.pageSize?.toInt() ?? _defaultPageSize;
  List<String> get _searchFields => widget.searchFields ?? const <String>[];

  bool get _isOpen =>
      _isControlledOpen ? (widget.open ?? false) : _internalOpen;

  bool get _hasSelection => _isMultiple
      ? _internalMultiple.isNotEmpty
      : _internalSingle.isNotEmpty;

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
      _currentPage = 0;
    }
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, data.length);
    return data.sublist(start, end);
  }

  int get _totalPages {
    final data = _effectiveData;
    if (data.isEmpty) return 1;
    return (data.length / _pageSize).ceil();
  }

  bool get _showPagination => _effectiveData.length > _pageSize;

  String _rowId(Map<String, dynamic> row) {
    return row['id']?.toString() ?? '';
  }

  bool _isRowSelected(Map<String, dynamic> row) {
    final id = _rowId(row);
    if (_isMultiple) return _internalMultiple.contains(id);
    return _internalSingle == id;
  }

  void _applyOpen(bool open, BcChangeReason reason) {
    if (!_isControlledOpen) {
      _internalOpen = open;
    }
    widget.onOpenChange?.call(
      open,
      BcChangeMeta(reason: reason, source: BcEventSource.programmatic),
    );
    if (mounted) setState(() {});
  }

  void _handleRowTap(Map<String, dynamic> row) {
    final id = _rowId(row);
    if (_isMultiple) {
      final next = List<String>.from(_internalMultiple);
      if (next.contains(id)) {
        next.remove(id);
      } else {
        next.add(id);
      }
      _internalMultiple = next;
      final reason =
          next.isEmpty ? BcChangeReason.clear : BcChangeReason.select;
      _emit(List<String>.from(next), reason);
    } else {
      _internalSingle = id;
      _emit(id, BcChangeReason.select);
    }
  }

  void _emit(Object value, BcChangeReason reason,
      {BcEventSource source = BcEventSource.pointer}) {
    widget.onValueChange?.call(
      value,
      BcChangeMeta(reason: reason, source: source),
    );
    widget.onChange?.call(value);
    if (mounted) setState(() {});
  }

  void _handleConfirm() {
    if (!_hasSelection) return;
    final value = _isMultiple
        ? List<String>.from(_internalMultiple)
        : _internalSingle;
    widget.onValueChange?.call(
      value,
      const BcChangeMeta(
          reason: BcChangeReason.confirm, source: BcEventSource.pointer),
    );
    widget.onChange?.call(value);
    _applyOpen(false, BcChangeReason.confirm);
  }

  void _handleCancel() {
    _applyOpen(false, BcChangeReason.cancel);
  }

  void _handleClose() {
    _applyOpen(false, BcChangeReason.cancel);
  }

  void _handleOverlayTap() {
    if (_closeOnOverlay) {
      _applyOpen(false, BcChangeReason.overlayClick);
    }
  }

  void _handleSearchChanged(String text) {
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

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _applyOpen(false, BcChangeReason.escape);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void open() {
    _applyOpen(true, BcChangeReason.programmatic);
  }

  void close() {
    _applyOpen(false, BcChangeReason.programmatic);
  }

  void reset() {
    if (_isMultiple) {
      _internalMultiple = <String>[];
      _emit(<String>[], BcChangeReason.programmatic,
          source: BcEventSource.programmatic);
    } else {
      _internalSingle = '';
      _emit('', BcChangeReason.programmatic,
          source: BcEventSource.programmatic);
    }
    _searchQuery = '';
    _searchController.clear();
    _currentPage = 0;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOpen) return const SizedBox.shrink();
    return _buildDialog(context);
  }

  Widget _buildDialog(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: GestureDetector(
              onTap: _handleOverlayTap,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black54),
            ),
          ),
          Center(
            child: AlertDialog(
              title: _buildHeader(context),
              content: _buildContent(context),
              actions: _buildActions(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildHeader(BuildContext context) {
    if (widget.title == null && !_isCloseable) return null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.title != null) Text(widget.title!),
        const Spacer(),
        if (_isCloseable)
          IconButton(
            key: const ValueKey<String>('closeButton'),
            icon: const Icon(Icons.close),
            onPressed: _handleClose,
            iconSize: 20,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveData = _pagedData;

    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (_isSearchable)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                key: const ValueKey<String>('searchInput'),
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                onChanged: _handleSearchChanged,
              ),
            ),
          if (effectiveData.isEmpty)
            const Padding(
              key: ValueKey<String>('empty'),
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('No records found')),
            )
          else
            Flexible(
              fit: FlexFit.loose,
              child: BcDataTable<Map<String, dynamic>>(
                columns: _buildDataColumns(theme),
                rows: effectiveData,
                onRowTap: _isMultiple ? null : _handleRowTap,
                showCheckboxColumn: false,
              ),
            ),
          if (_showPagination) _buildPagination(theme),
        ],
      ),
    );
  }

  List<BcDataColumn<Map<String, dynamic>>> _buildDataColumns(
      ThemeData theme) {
    final cols = <BcDataColumn<Map<String, dynamic>>>[];

    if (_isMultiple) {
      cols.add(BcDataColumn<Map<String, dynamic>>(
        label: '',
        cellBuilder: (context, row) => Checkbox(
          value: _isRowSelected(row),
          onChanged: (_) => _handleRowTap(row),
        ),
      ));
    }

    final userCols = widget.columns ?? const <BcLookupModalColumn>[];
    for (final col in userCols) {
      final isFirstUserCol = cols.length == (_isMultiple ? 1 : 0);
      cols.add(BcDataColumn<Map<String, dynamic>>(
        label: col.label,
        cellBuilder: (context, row) {
          final selected = _isRowSelected(row);
          final id = _rowId(row);
          final cellText = _cellText(row, col.key);
          if (isFirstUserCol && selected && !_isMultiple) {
            return Container(
              key: ValueKey<String>('row-selected-$id'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.check, size: 16, color: theme.primaryColor),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      cellText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Text(cellText);
        },
      ));
    }

    return cols;
  }

  Widget _buildPagination(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          IconButton(
            key: const ValueKey<String>('prevButton'),
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed:
                _currentPage > 0 ? () => _goToPage(_currentPage - 1) : null,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          Text(
            key: const ValueKey<String>('pageInfo'),
            '${_currentPage + 1} / $_totalPages',
            style: theme.textTheme.bodySmall,
          ),
          IconButton(
            key: const ValueKey<String>('nextButton'),
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
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return <Widget>[
      TextButton(
        key: const ValueKey<String>('cancelButton'),
        onPressed: _handleCancel,
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        key: const ValueKey<String>('confirmButton'),
        onPressed: _hasSelection ? _handleConfirm : null,
        child: const Text('Confirm'),
      ),
    ];
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
