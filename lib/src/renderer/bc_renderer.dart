library bc_renderer;

import 'package:flutter/material.dart';

import '../components/bc_data_table.dart';
import '../components/bc_form.dart';
import '../components/bc_empty.dart';
import '../schema/ui_schema.dart';
import 'bc_data_source_loader.dart';

/// Schema-driven UI compositor (ADR-005).
///
/// Walks a [UiSchema] tree and produces the matching Flutter widgets wired to
/// a [ReactiveStore]. Dispatches on [UiSchema.type]:
///
/// | Kind     | Behaviour                                                    |
/// |----------|--------------------------------------------------------------|
/// | `form`   | Wraps content in [BcForm] with fields/actions/callbacks.     |
/// | `detail` | Same as `form` but `disabled: true`; submit actions omitted. |
/// | `list`   | Async load via [loadDataSource], render [BcDataTable].       |
/// | `section`| Title/description + recursive children in a `Column`.        |
/// | `grid`   | Title/description + recursive children in a `GridView`.      |
/// | `custom` | Invokes [BcRenderer.customBuilder].                          |
///
/// Recursive rendering (section/grid) propagates `values`, `disabled`, and all
/// callbacks to nested [BcRenderer] instances.
///
/// See the VAL-RENDER-* validation contract for behavioral requirements.
class BcRenderer extends StatefulWidget {
  /// Renderer configuration: schema, values, callbacks, disabled state.
  final BcRendererProps props;

  /// Custom builder invoked for `UiSchemaKind.custom` schemas.
  ///
  /// Receives `schema.name` and `schema.payload`. When null, a fallback
  /// placeholder is rendered (VAL-RENDER-012).
  final Widget Function(String name, Object? payload)? customBuilder;

  const BcRenderer({
    super.key,
    required this.props,
    this.customBuilder,
  });

  @override
  State<BcRenderer> createState() => _BcRendererState();
}

class _BcRendererState extends State<BcRenderer> {
  // -- List loading state ---------------------------------------------------

  List<dynamic>? _loadedData;
  Object? _loadError;
  bool _isLoading = false;
  bool _listInitiated = false;

  @override
  void didUpdateWidget(covariant BcRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-trigger list load when the schema source changes.
    final schema = widget.props.schema;
    if (schema != null && schema.type == UiSchemaKind.list) {
      final oldSchema = oldWidget.props.schema;
      if (oldSchema == null ||
          oldSchema.source != schema.source ||
          oldSchema.data != schema.data) {
        _listInitiated = false;
        _loadedData = null;
        _loadError = null;
        _isLoading = false;
      }
    }
  }

  void _initListLoad(UiSchema schema) {
    if (_listInitiated) return;
    _listInitiated = true;

    if (schema.source == null) {
      // Inline data — synchronous, no loading state.
      _loadedData = schema.data;
      return;
    }

    _isLoading = true;
    loadDataSource(schema.source).then((result) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (result.error != null) {
          _loadError = result.error;
        } else {
          _loadedData = result.data;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final schema = widget.props.schema;

    // VAL-RENDER-016: null schema renders a minimal placeholder.
    if (schema == null) {
      return const SizedBox.shrink();
    }

    switch (schema.type) {
      case UiSchemaKind.form:
        return _buildForm(schema, disabled: widget.props.disabled);
      case UiSchemaKind.detail:
        return _buildDetail(schema);
      case UiSchemaKind.list:
        return _buildList(context, schema);
      case UiSchemaKind.section:
        return _buildSection(schema);
      case UiSchemaKind.grid:
        return _buildGrid(schema);
      case UiSchemaKind.custom:
        return _buildCustom(schema);
    }
  }

  // -- form / detail --------------------------------------------------------

  Widget _buildForm(UiSchema schema, {required bool disabled}) {
    final props = widget.props;
    final formWidget = BcForm(
      initialValues: props.values,
      fields: schema.fields,
      actions: schema.actions,
      layout: schema.layout,
      reactions: schema.reactions,
      disabled: disabled,
      onChange: props.onChange,
      onSubmit: props.onSubmit,
      onAction: props.onAction,
    );
    return _wrapTitleDescription(schema, formWidget);
  }

  /// VAL-RENDER-003: detail kind renders a disabled form.
  /// VAL-RENDER-022: detail does not expose mutating actions by default.
  Widget _buildDetail(UiSchema schema) {
    final props = widget.props;
    // Strip submit actions for detail views.
    final nonSubmitActions = schema.actions
        .where((a) => !a.submit)
        .toList();

    final formWidget = BcForm(
      initialValues: props.values,
      fields: schema.fields,
      actions: nonSubmitActions,
      layout: schema.layout,
      reactions: schema.reactions,
      disabled: true,
      onChange: props.onChange,
      onSubmit: null,
      onAction: props.onAction,
    );
    return _wrapTitleDescription(schema, formWidget);
  }

  /// Wraps a form/detail widget with title/description above it.
  Widget _wrapTitleDescription(UiSchema schema, Widget formWidget) {
    final titleDesc = _buildTitleDescription(schema);
    if (titleDesc == null) return formWidget;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [titleDesc, formWidget],
    );
  }

  // -- list -----------------------------------------------------------------

  Widget _buildList(BuildContext context, UiSchema schema) {
    // Trigger async load if a source is present.
    _initListLoad(schema);

    final titleDesc = _buildTitleDescription(schema);

    Widget content;

    if (_isLoading) {
      // VAL-RENDER-005: show loading indicator while awaiting data.
      content = const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_loadError != null) {
      // VAL-RENDER-006: show error state on load failure.
      content = _buildErrorState(_loadError!);
    } else {
      final rows = (_loadedData ?? schema.data)
          .map((item) => item is Map<String, dynamic>
              ? item
              : <String, dynamic>{'value': item})
          .toList();
      final columns = schema.columnsDef
          .map((col) => BcDataColumn<Map<String, dynamic>>(
                label: col.label,
                numeric: col.align == ColumnAlign.right,
                sortable: col.sortable,
                cellBuilder: (context, row) {
                  final value = row[col.key];
                  return Text(value?.toString() ?? '');
                },
              ))
          .toList();

      if (columns.isEmpty) {
        // No columns defined: show empty state.
        content = _buildEmptyState();
      } else {
        content = BcDataTable<Map<String, dynamic>>(
          key: ValueKey('bc_renderer_list_${schema.name ?? ''}'),
          columns: columns,
          rows: rows,
          emptyState: _buildEmptyState(),
        );
      }
    }

    if (titleDesc != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          titleDesc,
          content,
        ],
      );
    }
    return content;
  }

  // -- section --------------------------------------------------------------

  Widget _buildSection(UiSchema schema) {
    final titleDesc = _buildTitleDescription(schema);
    final children = schema.sections
        .map((child) => _buildRecursiveChild(child))
        .toList();

    if (titleDesc != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          titleDesc,
          ...children,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  // -- grid -----------------------------------------------------------------

  Widget _buildGrid(UiSchema schema) {
    final titleDesc = _buildTitleDescription(schema);
    final children = schema.sections
        .map((child) => _buildRecursiveChild(child))
        .toList();

    final grid = _buildGridRows(children, schema.columns);

    if (titleDesc != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          titleDesc,
          grid,
        ],
      );
    }
    return grid;
  }

  /// Lays [children] out in rows of [columns] equal-width cells.
  ///
  /// Cells are sized by their content: the row uses
  /// [CrossAxisAlignment.start] with [Expanded] cells, so a `detail` or `form`
  /// with many fields grows the row instead of being clipped to a fixed cell
  /// height. The previous `GridView` + `childAspectRatio` approach forced a
  /// fixed cell height and overflowed whenever the content was taller.
  ///
  /// Trailing gaps in the last row keep the column widths aligned.
  Widget _buildGridRows(List<Widget> children, int columns) {
    if (children.isEmpty) return const SizedBox.shrink();

    final columnCount = columns < 1 ? 1 : columns;
    const spacing = 12.0;

    final rows = <Widget>[];
    for (var start = 0; start < children.length; start += columnCount) {
      final cells = <Widget>[];
      for (var offset = 0; offset < columnCount; offset++) {
        if (offset > 0) cells.add(const SizedBox(width: spacing));
        final index = start + offset;
        cells.add(
          Expanded(
            child: index < children.length
                ? children[index]
                : const SizedBox.shrink(),
          ),
        );
      }

      if (rows.isNotEmpty) rows.add(const SizedBox(height: spacing));
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cells,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }

  // -- custom ---------------------------------------------------------------

  /// VAL-RENDER-012: custom kind invokes the customBuilder callback.
  /// VAL-RENDER-021: custom builder can participate in recursive rendering.
  Widget _buildCustom(UiSchema schema) {
    final builder = widget.customBuilder;
    if (builder != null) {
      return builder(schema.name ?? '', schema.payload);
    }
    // Fallback when no customBuilder is provided.
    return const SizedBox.shrink();
  }

  // -- recursion helpers ----------------------------------------------------

  /// Builds a nested [BcRenderer] for a child schema, propagating values,
  /// disabled state, and callbacks from the parent props.
  ///
  /// Each child form gets its own independent [BcForm] store
  /// (VAL-RENDER-023, VAL-CROSS-024). Values, disabled state, and callbacks
  /// are propagated to all nested instances (VAL-RENDER-013, VAL-RENDER-014,
  /// VAL-RENDER-015).
  Widget _buildRecursiveChild(UiSchema childSchema) {
    return BcRenderer(
      props: BcRendererProps(
        schema: childSchema,
        values: widget.props.values,
        disabled: widget.props.disabled,
        onChange: widget.props.onChange,
        onSubmit: widget.props.onSubmit,
        onAction: widget.props.onAction,
      ),
      customBuilder: widget.customBuilder,
    );
  }

  // -- title / description --------------------------------------------------

  /// Returns a widget containing the schema's title and description, or null
  /// if neither is present.
  Widget? _buildTitleDescription(UiSchema schema) {
    final hasTitle = schema.title != null && schema.title!.isNotEmpty;
    final hasDescription =
        schema.description != null && schema.description!.isNotEmpty;

    if (!hasTitle && !hasDescription) return null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasTitle)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              schema.title!,
              key: ValueKey('bc_renderer_title_${schema.name ?? ''}'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (hasDescription)
          Text(
            schema.description!,
            key: ValueKey('bc_renderer_desc_${schema.name ?? ''}'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  // -- state widgets --------------------------------------------------------

  Widget _buildErrorState(Object error) {
    final message = error is Exception
        ? error.toString()
        : error.toString();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: 8),
          Text(
            'Error: $message',
            style: TextStyle(color: Colors.red[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: BcEmpty(
        message: 'No data',
      ),
    );
  }
}
