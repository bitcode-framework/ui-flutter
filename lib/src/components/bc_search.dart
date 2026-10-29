library bc_search;

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Search result item for [BcSearch].
class BcSearchResult {
  final String id;
  final String label;
  final String? category;
  final String? href;

  const BcSearchResult({
    required this.id,
    required this.label,
    this.category,
    this.href,
  });

  @override
  String toString() =>
      'BcSearchResult(id: $id, label: $label, category: $category)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcSearchResult &&
          id == other.id &&
          label == other.label &&
          category == other.category &&
          href == other.href;

  @override
  int get hashCode => Object.hash(id, label, category, href);
}

/// Search input with icon and results dropdown (ADR-011 Phase 5c — M7 misc).
///
/// Mirrors TS [BcSearchContract] ({ value?, results?, placeholder?,
/// loading?, emptyText?, ariaLabel?, onChange?, onSelect? }).
///
/// Renders a text input with a search icon. Typing text invokes [onSearch]
/// with the query string and [BcChangeMeta]. A clear button resets the input
/// and invokes [onSearch] with an empty string. Selecting a result invokes
/// [onSelect] with the [BcSearchResult].
class BcSearch extends StatefulWidget {
  final String? value;
  final List<BcSearchResult> results;
  final String? placeholder;
  final bool loading;
  final String? emptyText;
  final String? ariaLabel;
  final BcChangeHandler<String>? onSearch;
  final BcChangeHandler<BcSearchResult>? onSelect;

  const BcSearch({
    super.key,
    this.value,
    this.results = const [],
    this.placeholder,
    this.loading = false,
    this.emptyText,
    this.ariaLabel,
    this.onSearch,
    this.onSelect,
  });

  @override
  State<BcSearch> createState() => _BcSearchState();
}

class _BcSearchState extends State<BcSearch> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String _internalQuery = '';
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _internalQuery = widget.value ?? '';
    _controller = TextEditingController(text: _internalQuery);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(BcSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controlled = widget.value;
    if (controlled != null && controlled != _controller.text) {
      _internalQuery = controlled;
      _controller.text = controlled;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      setState(() => _showResults = false);
    }
  }

  String get _currentQuery => widget.value ?? _internalQuery;

  void _onChanged(String text) {
    if (widget.value == null) {
      setState(() {
        _internalQuery = text;
        _showResults = true;
      });
    } else {
      setState(() => _showResults = true);
    }

    widget.onSearch?.call(
      text,
      const BcChangeMeta(
        reason: BcChangeReason.input,
        source: BcEventSource.keyboard,
      ),
    );
  }

  void _onSubmitted(String text) {
    if (text.isNotEmpty) {
      widget.onSearch?.call(
        text,
        const BcChangeMeta(
          reason: BcChangeReason.submit,
          source: BcEventSource.keyboard,
        ),
      );
    }
    setState(() => _showResults = false);
  }

  void _clear() {
    if (widget.value == null) {
      _controller.clear();
      setState(() {
        _internalQuery = '';
        _showResults = false;
      });
    }

    widget.onSearch?.call(
      '',
      const BcChangeMeta(
        reason: BcChangeReason.clear,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _selectResult(BcSearchResult result) {
    setState(() => _showResults = false);
    _focusNode.unfocus();

    widget.onSelect?.call(
      result,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInput(),
        if (_showResults && widget.results.isNotEmpty)
          _buildResultsDropdown(),
      ],
    );
  }

  Widget _buildInput() {
    return Container(
      key: const Key('bc_search'),
      decoration: BoxDecoration(
        color: BcTheme.background,
        borderRadius: BorderRadius.circular(BcTheme.radius),
        border: Border.all(color: BcTheme.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(
            Icons.search,
            size: 20,
            color: BcTheme.mutedForeground,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: PlatformWidget(
              material: (ctx, _) => TextField(
                key: const Key('bc_search_input'),
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: widget.placeholder ?? 'Search...',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(color: BcTheme.foreground),
                onChanged: _onChanged,
                onSubmitted: _onSubmitted,
              ),
              cupertino: (ctx, _) => _buildCupertinoField(),
            ),
          ),
          if (widget.loading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_currentQuery.isNotEmpty)
            GestureDetector(
              key: const Key('bc_search_clear'),
              onTap: _clear,
              child: const MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: BcTheme.mutedForeground,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildCupertinoField() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        _currentQuery,
        style: const TextStyle(color: BcTheme.foreground),
      ),
    );
  }

  Widget _buildResultsDropdown() {
    return Container(
      key: const Key('bc_search_results'),
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: BcTheme.popover,
        borderRadius: BorderRadius.circular(BcTheme.radius),
        border: Border.all(color: BcTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: widget.results.isEmpty && widget.emptyText != null
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.emptyText!,
                style: const TextStyle(
                  color: BcTheme.mutedForeground,
                  fontSize: 14,
                ),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: widget.results.length,
              itemBuilder: (context, index) {
                final result = widget.results[index];
                return InkWell(
                  key: Key('bc_search_result_${result.id}'),
                  onTap: () => _selectResult(result),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          result.label,
                          style: const TextStyle(color: BcTheme.foreground),
                        ),
                        if (result.category != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              result.category!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: BcTheme.mutedForeground,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
