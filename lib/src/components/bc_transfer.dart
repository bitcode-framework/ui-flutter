library bc_transfer;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Single item in a [BcTransfer] dual-list selector.
///
/// Mirrors TS `BcTransferItem`.
class BcTransferItem {
  final String key;
  final String label;
  final bool disabled;

  const BcTransferItem({
    required this.key,
    required this.label,
    this.disabled = false,
  });
}

/// Dual-list transfer selector (ADR-011 Phase 5c — M1).
///
/// Renders two side-by-side panels: a source list (left) and a target list
/// (right), with arrow buttons that move checked items between them.
///
/// Controlled via [targetKeys] — the parent owns the set of keys on the
/// right side. [onValueChange] fires with the full updated target-key list
/// and a [BcChangeMeta] on every move operation.
///
/// When [searchable] is true, a search field appears in each panel header
/// to filter the displayed items. When [disabled] is true, all interaction
/// is blocked.
class BcTransfer extends StatefulWidget {
  final List<BcTransferItem> items;
  final List<String> targetKeys;
  final List<String> titles;
  final bool searchable;
  final bool disabled;
  final BcChangeHandler<List<String>>? onValueChange;

  const BcTransfer({
    super.key,
    this.items = const [],
    this.targetKeys = const [],
    this.titles = const ['Source', 'Target'],
    this.searchable = false,
    this.disabled = false,
    this.onValueChange,
  });

  @override
  State<BcTransfer> createState() => _BcTransferState();
}

class _BcTransferState extends State<BcTransfer> {
  Set<String> _checkedSource = {};
  Set<String> _checkedTarget = {};
  String _searchSource = '';
  String _searchTarget = '';

  Set<String> get _targetSet => widget.targetKeys.toSet();

  List<BcTransferItem> get _sourceItems {
    final ts = _targetSet;
    final q = _searchSource.toLowerCase();
    return widget.items.where((it) {
      if (ts.contains(it.key)) return false;
      if (q.isNotEmpty && !it.label.toLowerCase().contains(q)) return false;
      return true;
    }).toList();
  }

  List<BcTransferItem> get _targetItems {
    final ts = _targetSet;
    final q = _searchTarget.toLowerCase();
    return widget.items.where((it) {
      if (!ts.contains(it.key)) return false;
      if (q.isNotEmpty && !it.label.toLowerCase().contains(q)) return false;
      return true;
    }).toList();
  }

  void _toggleSourceCheck(String key, bool? itemDisabled) {
    if (widget.disabled || (itemDisabled ?? false)) return;
    setState(() {
      if (_checkedSource.contains(key)) {
        _checkedSource = _checkedSource.where((k) => k != key).toSet();
      } else {
        _checkedSource = {..._checkedSource, key};
      }
    });
  }

  void _toggleTargetCheck(String key, bool? itemDisabled) {
    if (widget.disabled || (itemDisabled ?? false)) return;
    setState(() {
      if (_checkedTarget.contains(key)) {
        _checkedTarget = _checkedTarget.where((k) => k != key).toSet();
      } else {
        _checkedTarget = {..._checkedTarget, key};
      }
    });
  }

  void _moveToTarget() {
    if (widget.disabled || _checkedSource.isEmpty) return;
    final next = [...widget.targetKeys, ..._checkedSource];
    setState(() {
      _checkedSource = {};
    });
    widget.onValueChange?.call(
      next,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _moveToSource() {
    if (widget.disabled || _checkedTarget.isEmpty) return;
    final remove = _checkedTarget;
    final next = widget.targetKeys.where((k) => !remove.contains(k)).toList();
    setState(() {
      _checkedTarget = {};
    });
    widget.onValueChange?.call(
      next,
      const BcChangeMeta(
        reason: BcChangeReason.deselect,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const buttonColumnWidth = 52.0;
        final panelWidth =
            (constraints.maxWidth - buttonColumnWidth) / 2;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: panelWidth,
              child: _buildPanel(
                title: widget.titles.isNotEmpty
                    ? widget.titles[0]
                    : 'Source',
                items: _sourceItems,
                checked: _checkedSource,
                side: 'source',
                searchValue: _searchSource,
                onSearch: widget.searchable
                    ? (v) => setState(() => _searchSource = v)
                    : null,
                onToggle: _toggleSourceCheck,
              ),
            ),
            SizedBox(
              width: buttonColumnWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMoveButton(
                    key: const ValueKey('transfer_move_right'),
                    icon: Icons.chevron_right,
                    onPressed: !widget.disabled &&
                            _checkedSource.isNotEmpty
                        ? _moveToTarget
                        : null,
                  ),
                  const SizedBox(height: 8),
                  _buildMoveButton(
                    key: const ValueKey('transfer_move_left'),
                    icon: Icons.chevron_left,
                    onPressed: !widget.disabled &&
                            _checkedTarget.isNotEmpty
                        ? _moveToSource
                        : null,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: panelWidth,
              child: _buildPanel(
                title: widget.titles.length > 1
                    ? widget.titles[1]
                    : 'Target',
                items: _targetItems,
                checked: _checkedTarget,
                side: 'target',
                searchValue: _searchTarget,
                onSearch: widget.searchable
                    ? (v) => setState(() => _searchTarget = v)
                    : null,
                onToggle: _toggleTargetCheck,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMoveButton({
    required Key key,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        key: key,
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          foregroundColor: BcTheme.foreground,
          disabledForegroundColor: BcTheme.mutedForeground,
        ),
      ),
    );
  }

  Widget _buildPanel({
    required String title,
    required List<BcTransferItem> items,
    required Set<String> checked,
    required String side,
    required String searchValue,
    required ValueChanged<String>? onSearch,
    required void Function(String key, bool? disabled) onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: BcTheme.border),
        borderRadius: BorderRadius.circular(BcTheme.radius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: BcTheme.border),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: BcTheme.foreground,
                  ),
                ),
                Text(
                  '${items.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: BcTheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          if (onSearch != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                height: 32,
                child: TextField(
                  key: ValueKey('transfer_search_$side'),
                  onChanged: onSearch,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 16),
                    prefixIconConstraints: const BoxConstraints(
                      maxWidth: 28,
                      maxHeight: 28,
                    ),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: BcTheme.border),
                    ),
                  ),
                ),
              ),
            ),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 4),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isChecked = checked.contains(item.key);
                  final isDisabled =
                      widget.disabled || item.disabled;

                  return InkWell(
                    onTap: isDisabled
                        ? null
                        : () => onToggle(item.key, item.disabled),
                    borderRadius: BorderRadius.circular(4),
                    child: Opacity(
                      opacity: isDisabled ? 0.5 : 1.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                key: ValueKey(
                                    'transfer_${side}_check_${item.key}'),
                                value: isChecked,
                                onChanged: isDisabled
                                    ? null
                                    : (v) =>
                                        onToggle(item.key, item.disabled),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                item.label,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: BcTheme.foreground,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
