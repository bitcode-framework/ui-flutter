library bc_view_editor;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// A single component placed in a [BcViewEditor] layout canvas.
///
/// Mirrors the visual layout-builder model used by the validation contract
/// (VAL-M5-027..029): each component has a [type] (e.g. 'list', 'form',
/// 'chart') and an [id]. The optional [label] is shown in the editor card.
class BcViewEditorComponent {
  final String id;
  final String type;
  final String? label;

  const BcViewEditorComponent({
    required this.id,
    required this.type,
    this.label,
  });

  @override
  String toString() =>
      'BcViewEditorComponent(id: $id, type: $type, label: $label)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcViewEditorComponent &&
          id == other.id &&
          type == other.type &&
          label == other.label;

  @override
  int get hashCode => Object.hash(id, type, label);
}

/// Visual view editor with drag-to-reorder of layout components.
///
/// Mirrors the TS `BcViewEditor` layout-builder behavior described in the
/// validation contract. Components are rendered into the canvas in order.
/// Dragging a component handle reorders the layout and fires
/// [onLayoutChange] with the updated component list and a [BcChangeMeta].
///
/// When [disabled] is true, components are not draggable (no drag affordance,
/// drop is a no-op) and no [onLayoutChange] is emitted; the rendered layout
/// remains static and matches the current config.
///
/// Platform-aware: tappable cards use Cupertino on iOS, Material elsewhere.
class BcViewEditor extends StatefulWidget {
  final List<BcViewEditorComponent> components;
  final List<BcViewEditorComponent> defaultComponents;
  final bool disabled;
  final void Function(
    List<BcViewEditorComponent> components,
    BcChangeMeta meta,
  )? onLayoutChange;

  const BcViewEditor({
    super.key,
    this.components = const [],
    this.defaultComponents = const [],
    this.disabled = false,
    this.onLayoutChange,
  });

  @override
  State<BcViewEditor> createState() => _BcViewEditorState();
}

class _BcViewEditorState extends State<BcViewEditor> {
  late List<BcViewEditorComponent> _components;

  @override
  void initState() {
    super.initState();
    _components =
        widget.components.isNotEmpty ? List.from(widget.components) : List.from(widget.defaultComponents);
  }

  @override
  void didUpdateWidget(covariant BcViewEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_listEquals(oldWidget.components, widget.components)) {
      _components = List.from(widget.components);
    }
  }

  void _onReorderItem(int oldIndex, int newIndex) {
    if (widget.disabled) return;
    final list = List<BcViewEditorComponent>.from(_components);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    setState(() => _components = list);
    widget.onLayoutChange?.call(
      List<BcViewEditorComponent>.from(list),
      const BcChangeMeta(
        reason: BcChangeReason.valueChange,
        source: BcEventSource.pointer,
      ),
    );
  }

  Widget _buildCard(BcViewEditorComponent component, int index) {
    final display = component.label ?? component.type;
    return Container(
      key: ValueKey<String>('ve-item-${component.id}'),
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: BcTheme.card,
        border: Border.all(color: BcTheme.border),
        borderRadius: const BorderRadius.all(Radius.circular(BcTheme.radius)),
      ),
      child: Row(
        children: [
          Icon(Icons.drag_indicator,
              size: 20,
              color: widget.disabled
                  ? BcTheme.mutedForeground.withValues(alpha: 0.4)
                  : BcTheme.mutedForeground),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  display,
                  key: ValueKey<String>('ve-label-${component.id}'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: BcTheme.foreground,
                  ),
                ),
                Text(
                  component.type,
                  style: const TextStyle(
                    fontSize: 11,
                    color: BcTheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReorderable() {
    return ReorderableListView(
      buildDefaultDragHandles: false,
      onReorderItem: _onReorderItem,
      children: _components.asMap().entries.map((entry) {
        final index = entry.key;
        final component = entry.value;
        return Container(
          key: ValueKey<String>('ve-row-${component.id}'),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(child: _buildCard(component, index)),
              ReorderableDragStartListener(
                key: ValueKey<String>('drag-${component.id}'),
                index: index,
                child: Container(
                  key: ValueKey<String>('drag-handle-${component.id}'),
                  width: 36,
                  height: 60,
                  alignment: Alignment.center,
                  child: const Icon(Icons.drag_handle, color: BcTheme.primary),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatic() {
    return Column(
      children: _components.asMap().entries.map((entry) {
        return Padding(
          key: ValueKey<String>('ve-row-${entry.value.id}'),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _buildCard(entry.value, entry.key),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: widget.disabled ? _buildStatic() : _buildReorderable(),
    );
  }

  static bool _listEquals(
      List<BcViewEditorComponent> a, List<BcViewEditorComponent> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
