library bc_field_dyn_link;

import 'dart:async';

import 'package:flutter/material.dart';
import '../core/types.dart';

class BcFieldDynLink extends StatefulWidget {
  final String? name;
  final String? label;
  final BcDynLinkValue? value;
  final BcDynLinkValue? defaultValue;
  final List<BcDynLinkModel>? models;
  final Future<List<BcDynLinkRecord>> Function(String, String)? dataFetcher;
  final bool? disabled;
  final bool? required_;
  final bool? readonly;
  final String? placeholder;
  final bool? clearable;
  final String? hint;
  final String? description;
  final String? className;
  final Map<String, dynamic>? slotProps;
  final BcChangeHandler<BcDynLinkValue>? onValueChange;
  final void Function(dynamic)? onChange;

  const BcFieldDynLink({
    super.key,
    this.name,
    this.label,
    this.value,
    this.defaultValue,
    this.models,
    this.dataFetcher,
    this.disabled,
    this.required_,
    this.readonly,
    this.placeholder,
    this.clearable,
    this.hint,
    this.description,
    this.className,
    this.slotProps,
    this.onValueChange,
    this.onChange,
  });

  @override
  State<BcFieldDynLink> createState() => BcFieldDynLinkState();
}

class BcFieldDynLinkState extends State<BcFieldDynLink> {
  late BcDynLinkValue _internalValue;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  bool _isLoading = false;
  bool _dropdownOpen = false;
  List<BcDynLinkRecord> _results = const [];
  String? _errorMessage;

  Timer? _debounceTimer;
  Future<void>? _activeFetch;

  static const Duration _debounceDuration = Duration(milliseconds: 300);

  BcDynLinkValue get currentValue => _internalValue;

  bool get _isControlled => widget.value != null;

  bool get _isDisabled => widget.disabled == true;

  bool get _isReadonly => widget.readonly == true;

  bool get _isClearable => widget.clearable == true;

  bool get _isInteractive => !_isDisabled && !_isReadonly;

  List<BcDynLinkModel> get _models => widget.models ?? const [];

  String get _selectedModel => _internalValue.model;

  bool get _hasValue =>
      _internalValue.id.isNotEmpty && _internalValue.display.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _internalValue = (widget.value ?? widget.defaultValue) ??
        const BcDynLinkValue(model: '', id: '', display: '');
    _searchController = TextEditingController(text: _internalValue.display);
    _searchFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(BcFieldDynLink oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isControlled) {
      final newValue = widget.value!;
      if (newValue != _internalValue) {
        _internalValue = newValue;
        _searchController.text = newValue.display;
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _emit(
    BcDynLinkValue val, {
    BcChangeReason reason = BcChangeReason.select,
    BcEventSource source = BcEventSource.programmatic,
  }) {
    if (!_isControlled) {
      setState(() => _internalValue = val);
    }
    widget.onValueChange?.call(
      val,
      BcChangeMeta(reason: reason, source: source),
    );
    widget.onChange?.call(val);
  }

  void _onModelSelected(String? modelValue) {
    if (modelValue == null || modelValue == _selectedModel) return;

    setState(() {
      _searchController.clear();
      _results = const [];
      _dropdownOpen = false;
      _errorMessage = null;
      _isLoading = false;
    });
    _debounceTimer?.cancel();

    _emit(
      BcDynLinkValue(model: modelValue, id: '', display: ''),
      reason: BcChangeReason.modelChange,
      source: BcEventSource.pointer,
    );
  }

  void _onSearchChanged(String query) {
    if (!_isInteractive) return;
    if (_selectedModel.isEmpty) return;

    setState(() {
      _dropdownOpen = true;
      _errorMessage = null;
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (_selectedModel.isEmpty || widget.dataFetcher == null) return;

    _debounceTimer?.cancel();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _dropdownOpen = true;
    });

    final fetch = widget.dataFetcher!(_selectedModel, query);
    _activeFetch = fetch;

    try {
      final results = await fetch;
      if (!mounted) return;

      if (_activeFetch != fetch) return;

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (_activeFetch != fetch) return;

      setState(() {
        _results = const [];
        _isLoading = false;
        _errorMessage = 'Search failed';
      });
    }
  }

  void _onRecordSelected(BcDynLinkRecord record) {
    setState(() {
      _searchController.text = record.label;
      _dropdownOpen = false;
      _results = const [];
      _errorMessage = null;
    });
    _debounceTimer?.cancel();

    _emit(
      BcDynLinkValue(
        model: _selectedModel,
        id: record.id,
        display: record.label,
      ),
      reason: BcChangeReason.select,
      source: BcEventSource.pointer,
    );
  }

  void _clearSelection() {
    setState(() {
      _searchController.clear();
      _results = const [];
      _dropdownOpen = false;
      _errorMessage = null;
    });
    _debounceTimer?.cancel();

    _emit(
      const BcDynLinkValue(model: '', id: '', display: ''),
      reason: BcChangeReason.clear,
      source: BcEventSource.pointer,
    );
  }

  void reset() {
    _debounceTimer?.cancel();
    setState(() {
      _internalValue =
          const BcDynLinkValue(model: '', id: '', display: '');
      _searchController.clear();
      _results = const [];
      _isLoading = false;
      _dropdownOpen = false;
      _errorMessage = null;
    });
  }

  void clear() {
    setState(() {
      _searchController.clear();
      _results = const [];
      _isLoading = false;
      _dropdownOpen = false;
      _errorMessage = null;
    });
    _debounceTimer?.cancel();

    _emit(
      const BcDynLinkValue(model: '', id: '', display: ''),
      reason: BcChangeReason.clear,
      source: BcEventSource.programmatic,
    );
  }

  Widget _buildModelSelector() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedModel.isEmpty ? null : _selectedModel,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      hint: const Text('Select model'),
      items: _models
          .map((m) => DropdownMenuItem<String>(
                value: m.model,
                child: Text(m.label),
              ))
          .toList(),
      onChanged: _isInteractive ? _onModelSelected : null,
    );
  }

  Widget _buildSearchField() {
    return TextField(
      key: const ValueKey('dynLinkSearch'),
      controller: _searchController,
      focusNode: _searchFocusNode,
      enabled: !_isDisabled,
      readOnly: _isReadonly,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        hintText: _hasValue ? null : (widget.placeholder ?? 'Search records'),
      ),
      onChanged: _onSearchChanged,
      onTap: () {
        if (_isInteractive && _selectedModel.isNotEmpty && _results.isNotEmpty) {
          setState(() => _dropdownOpen = true);
        }
      },
      onSubmitted: (_) {
        setState(() => _dropdownOpen = false);
      },
    );
  }

  Widget _buildDropdownOverlay() {
    if (!_dropdownOpen || _selectedModel.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return Material(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Material(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return Material(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: const Text('No results found'),
        ),
      );
    }

    return Material(
      elevation: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _results
            .map((record) => InkWell(
                  onTap: () => _onRecordSelected(record),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Text(record.label),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildDropdownArea() {
    if (!_dropdownOpen || _selectedModel.isEmpty) {
      return const SizedBox.shrink();
    }
    return _buildDropdownOverlay();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.label!, style: theme.textTheme.labelMedium),
                if (widget.required_ == true)
                  const Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: Text('*',
                        style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        if (widget.hint != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(widget.hint!, style: theme.textTheme.bodySmall),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildModelSelector()),
            const SizedBox(width: 8),
            Expanded(child: _buildSearchField()),
            if (_isClearable && _hasValue && _isInteractive) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: _clearSelection,
                tooltip: 'Clear',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
        _buildDropdownArea(),
        if (widget.description != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(widget.description!,
                style: theme.textTheme.bodySmall),
          ),
      ],
    );

    return Semantics(
      label: 'Dynamic Link',
      container: true,
      child: body,
    );
  }
}
