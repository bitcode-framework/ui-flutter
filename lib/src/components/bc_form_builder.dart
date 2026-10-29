// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use
library bc_form_builder;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:http/http.dart' as http;
import '../theme/bc_theme.dart';

/// Field type identifiers mirroring the TS `BcFieldType` union.
///
/// All 12 BitCode field types are supported.
enum BcFieldType {
  string,
  integer,
  float,
  boolean,
  datetime,
  json,
  selection,
  many2one,
  one2many,
  many2many,
  morphTo,
  computed;

  String get id {
    switch (this) {
      case BcFieldType.string:
        return 'string';
      case BcFieldType.integer:
        return 'integer';
      case BcFieldType.float:
        return 'float';
      case BcFieldType.boolean:
        return 'boolean';
      case BcFieldType.datetime:
        return 'datetime';
      case BcFieldType.json:
        return 'json';
      case BcFieldType.selection:
        return 'selection';
      case BcFieldType.many2one:
        return 'many2one';
      case BcFieldType.one2many:
        return 'one2many';
      case BcFieldType.many2many:
        return 'many2many';
      case BcFieldType.morphTo:
        return 'morph_to';
      case BcFieldType.computed:
        return 'computed';
    }
  }

  String get label {
    switch (this) {
      case BcFieldType.string:
        return 'Text';
      case BcFieldType.integer:
        return 'Integer';
      case BcFieldType.float:
        return 'Decimal';
      case BcFieldType.boolean:
        return 'Boolean';
      case BcFieldType.datetime:
        return 'Date/Time';
      case BcFieldType.json:
        return 'JSON';
      case BcFieldType.selection:
        return 'Selection';
      case BcFieldType.many2one:
        return 'Many to One';
      case BcFieldType.one2many:
        return 'One to Many';
      case BcFieldType.many2many:
        return 'Many to Many';
      case BcFieldType.morphTo:
        return 'Polymorphic';
      case BcFieldType.computed:
        return 'Computed';
    }
  }

  IconData get icon {
    switch (this) {
      case BcFieldType.string:
      case BcFieldType.computed:
        return Icons.text_fields;
      case BcFieldType.integer:
      case BcFieldType.float:
        return Icons.numbers;
      case BcFieldType.boolean:
        return Icons.check_box_outlined;
      case BcFieldType.datetime:
        return Icons.calendar_today;
      case BcFieldType.json:
        return Icons.code;
      case BcFieldType.selection:
        return Icons.list;
      case BcFieldType.many2one:
      case BcFieldType.one2many:
      case BcFieldType.many2many:
      case BcFieldType.morphTo:
        return Icons.link;
    }
  }

  static BcFieldType fromString(String s) {
    switch (s) {
      case 'string':
        return BcFieldType.string;
      case 'integer':
        return BcFieldType.integer;
      case 'float':
        return BcFieldType.float;
      case 'boolean':
        return BcFieldType.boolean;
      case 'datetime':
        return BcFieldType.datetime;
      case 'json':
        return BcFieldType.json;
      case 'selection':
        return BcFieldType.selection;
      case 'many2one':
        return BcFieldType.many2one;
      case 'one2many':
        return BcFieldType.one2many;
      case 'many2many':
        return BcFieldType.many2many;
      case 'morph_to':
        return BcFieldType.morphTo;
      case 'computed':
        return BcFieldType.computed;
      default:
        return BcFieldType.string;
    }
  }

  bool get isRelation =>
      this == BcFieldType.many2one ||
      this == BcFieldType.one2many ||
      this == BcFieldType.many2many ||
      this == BcFieldType.morphTo;
}

/// A single field definition in the form builder.
///
/// Mirrors TS `BcFormField`.
class BcFormField {
  final String id;
  final String name;
  final String label;
  final BcFieldType type;
  final bool required;
  final bool readonly;
  final int width;
  final String? widget;
  final String? defaultValue;
  final List<String> options;
  final String? relationModel;

  const BcFormField({
    required this.id,
    required this.name,
    required this.label,
    required this.type,
    this.required = false,
    this.readonly = false,
    this.width = 12,
    this.widget,
    this.defaultValue,
    this.options = const [],
    this.relationModel,
  });

  BcFormField copyWith({
    String? name,
    String? label,
    BcFieldType? type,
    bool? required,
    bool? readonly,
    int? width,
    String? widget,
    String? defaultValue,
    List<String>? options,
    String? relationModel,
  }) {
    return BcFormField(
      id: id,
      name: name ?? this.name,
      label: label ?? this.label,
      type: type ?? this.type,
      required: required ?? this.required,
      readonly: readonly ?? this.readonly,
      width: width ?? this.width,
      widget: widget ?? this.widget,
      defaultValue: defaultValue ?? this.defaultValue,
      options: options ?? this.options,
      relationModel: relationModel ?? this.relationModel,
    );
  }
}

/// A validation issue (error or warning) from the engine validate endpoint.
///
/// Mirrors TS `BcValidationIssue`.
class BcValidationIssue {
  final String? field;
  final String message;

  const BcValidationIssue({this.field, required this.message});
}

/// Validation result from the admin validate endpoint.
///
/// Mirrors TS `BcValidationResult`.
class BcValidationResult {
  final bool valid;
  final List<BcValidationIssue> errors;
  final List<BcValidationIssue> warnings;

  const BcValidationResult({
    required this.valid,
    this.errors = const [],
    this.warnings = const [],
  });

  factory BcValidationResult.fromJson(Map<String, dynamic> json) {
    return BcValidationResult(
      valid: json['valid'] == true,
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) => BcValidationIssue(
                    field: e['field'] as String?,
                    message: e['message'] as String? ?? '',
                  ))
              .toList() ??
          [],
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => BcValidationIssue(
                    field: e['field'] as String?,
                    message: e['message'] as String? ?? '',
                  ))
              .toList() ??
          [],
    );
  }
}

/// Data source for the form builder validation endpoint.
///
/// Mirrors TS `BcFormBuilderDataSource`.
class BcFormBuilderDataSource {
  final String? validateEndpoint;
  final Map<String, String>? headers;

  const BcFormBuilderDataSource({this.validateEndpoint, this.headers});
}

/// The view.json output of the form builder.
///
/// Mirrors TS `BcFormViewJson`.
class BcFormViewJson {
  final String name;
  final String type;
  final String? model;
  final String? title;
  final List<String>? fields;
  final List<BcFormLayoutRow>? layout;

  const BcFormViewJson({
    required this.name,
    this.type = 'form',
    this.model,
    this.title,
    this.fields,
    this.layout,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'type': type,
    };
    if (model != null && model!.isNotEmpty) json['model'] = model;
    if (title != null && title!.isNotEmpty) json['title'] = title;
    if (fields != null) json['fields'] = fields;
    if (layout != null) {
      json['layout'] = layout!
          .map((row) => {
                'row': row.toRowList(),
              })
          .toList();
    }
    return json;
  }

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());
}

/// A layout row in the view.json output.
class BcFormLayoutRow {
  final List<BcFormLayoutCell> cells;

  const BcFormLayoutRow(this.cells);

  List<Map<String, dynamic>> toRowList() =>
      cells.map((c) => c.toJson()).toList();
}

/// A layout cell in the view.json output.
class BcFormLayoutCell {
  final String field;
  final int width;
  final bool readonly;
  final String? widget;

  const BcFormLayoutCell({
    required this.field,
    this.width = 12,
    this.readonly = false,
    this.widget,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'field': field,
      'width': width,
      'readonly': readonly,
    };
    if (widget != null && widget!.isNotEmpty) json['widget'] = widget;
    return json;
  }
}

/// The active builder tab.
enum BcFormBuilderTab { canvas, json, live }

/// Visual Form Builder widget (ADR-014 Phase 4).
///
/// Mirrors TS `BcFormBuilder.lite.tsx` (ADR-006 Pure/Adapt pattern).
///
/// Features:
/// - Drag-drop canvas with field palette (LongPress draggable)
/// - Property panel for editing field properties
/// - JSON preview tab
/// - Live preview tab
/// - Validation via POST /api/v1/admin/views/validate before save
/// - Platform-aware (ADR-011): iOS uses Cupertino-style controls in the
///   property panel; Android uses Material controls.
class BcFormBuilder extends StatefulWidget {
  final String viewName;
  final String model;
  final String title;
  final List<BcFormField> fields;
  final BcFormBuilderDataSource? dataSource;
  final BcValidationResult? validation;
  final bool validating;
  final bool saveDisabled;
  final Map<String, String>? i18n;
  final void Function(List<BcFormField> fields)? onChange;
  final void Function(BcFormViewJson viewJson)? onValidate;
  final void Function(BcValidationResult result)? onValidationResult;
  final void Function(BcFormViewJson viewJson)? onSave;

  const BcFormBuilder({
    super.key,
    this.viewName = '',
    this.model = '',
    this.title = '',
    this.fields = const [],
    this.dataSource,
    this.validation,
    this.validating = false,
    this.saveDisabled = false,
    this.i18n,
    this.onChange,
    this.onValidate,
    this.onValidationResult,
    this.onSave,
  });

  @override
  State<BcFormBuilder> createState() => _BcFormBuilderState();
}

class _BcFormBuilderState extends State<BcFormBuilder> {
  List<BcFormField> _fields = [];
  String _selectedFieldId = '';
  BcFormBuilderTab _activeTab = BcFormBuilderTab.canvas;
  BcValidationResult? _validation;
  bool _validating = false;
  int _fieldCounter = 0;

  // i18n label resolver
  String t(String key, String fallback) {
    if (widget.i18n != null && widget.i18n!.containsKey(key)) {
      return widget.i18n![key]!;
    }
    return fallback;
  }

  @override
  void initState() {
    super.initState();
    _fields = List.from(widget.fields);
  }

  List<BcFormField> get _effectiveFields =>
      widget.fields.isNotEmpty ? widget.fields : _fields;

  BcValidationResult? get _effectiveValidation =>
      widget.validation ?? _validation;

  bool get _effectiveValidating => widget.validating || _validating;

  bool get _effectiveSaveDisabled {
    if (widget.saveDisabled) return true;
    final val = _effectiveValidation;
    if (val != null && !val.valid) return true;
    return false;
  }

  void _emitChange(List<BcFormField> fields) {
    setState(() {
      _fields = fields;
    });
    widget.onChange?.call(fields);
  }

  BcFormField? get _selectedField {
    if (_selectedFieldId.isEmpty) return null;
    for (final f in _effectiveFields) {
      if (f.id == _selectedFieldId) return f;
    }
    return null;
  }

  BcFormViewJson _buildViewJson() {
    final fields = _effectiveFields;
    return BcFormViewJson(
      name: widget.viewName.isNotEmpty
          ? widget.viewName
          : 'form_view',
      type: 'form',
      model: widget.model.isNotEmpty ? widget.model : null,
      title: widget.title.isNotEmpty ? widget.title : null,
      fields: fields.map((f) => f.name).toList(),
      layout: fields
          .map((f) => BcFormLayoutRow([
                BcFormLayoutCell(
                  field: f.name,
                  width: f.width,
                  readonly: f.readonly,
                  widget: f.widget,
                ),
              ]))
          .toList(),
    );
  }

  void _addField(BcFieldType type) {
    _fieldCounter++;
    final id = 'field_$_fieldCounter';
    final name = '${type.id}_$_fieldCounter';
    final field = BcFormField(
      id: id,
      name: name,
      label: name[0].toUpperCase() + name.substring(1),
      type: type,
    );
    final next = [..._effectiveFields, field];
    _emitChange(next);
    setState(() {
      _selectedFieldId = id;
    });
  }

  void _removeField(String id) {
    final next = _effectiveFields.where((f) => f.id != id).toList();
    _emitChange(next);
    if (_selectedFieldId == id) {
      setState(() {
        _selectedFieldId = '';
      });
    }
  }

  void _updateField(String id, BcFormField Function(BcFormField) updater) {
    final next = _effectiveFields.map((f) {
      return f.id == id ? updater(f) : f;
    }).toList();
    _emitChange(next);
  }

  void _moveField(int from, int to) {
    if (from < 0 || to < 0 || from >= _effectiveFields.length || to >= _effectiveFields.length) {
      return;
    }
    final fields = List<BcFormField>.from(_effectiveFields);
    final item = fields.removeAt(from);
    fields.insert(to, item);
    _emitChange(fields);
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    _moveField(oldIndex, newIndex);
  }

  Future<void> _runValidation() async {
    final viewJson = _buildViewJson();
    setState(() {
      _validating = true;
    });

    widget.onValidate?.call(viewJson);

    final endpoint = widget.dataSource?.validateEndpoint ??
        '/api/v1/admin/views/validate';

    try {
      final uri = Uri.parse(endpoint);
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ...?widget.dataSource?.headers,
        },
        body: jsonEncode(viewJson.toJson()),
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final result = BcValidationResult.fromJson(json);
      setState(() {
        _validation = result;
        _validating = false;
      });
      widget.onValidationResult?.call(result);
    } catch (e) {
      final result = BcValidationResult(
        valid: false,
        errors: [
          BcValidationIssue(message: 'Validation request failed: $e'),
        ],
      );
      setState(() {
        _validation = result;
        _validating = false;
      });
      widget.onValidationResult?.call(result);
    }
  }

  void _handleSave() {
    if (_effectiveSaveDisabled || _effectiveValidating) return;
    widget.onSave?.call(_buildViewJson());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('bc-form-builder'),
      decoration: BoxDecoration(
        border: Border.all(color: BcTheme.border),
        borderRadius: BorderRadius.circular(BcTheme.radius),
      ),
      child: Column(
        children: [
          _buildToolbar(),
          Expanded(child: _buildTabContent()),
          if (_effectiveValidation != null &&
              !_effectiveValidation!.valid &&
              !_effectiveValidating)
            _buildErrorBar(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      key: const Key('bc-form-builder-tabs'),
      decoration: BoxDecoration(
        color: BcTheme.muted,
        border: Border(
          bottom: BorderSide(color: BcTheme.border),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabs = <Widget>[
            _buildTabButton(BcFormBuilderTab.canvas,
                t('builder.canvas', 'Canvas')),
            const SizedBox(width: 4),
            _buildTabButton(BcFormBuilderTab.json,
                t('builder.json_preview', 'JSON')),
            const SizedBox(width: 4),
            _buildTabButton(BcFormBuilderTab.live,
                t('builder.live_preview', 'Live')),
          ];

          final status = <Widget>[
            if (_effectiveValidating)
              Padding(
                key: const Key('bc-form-builder-validating'),
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: BcTheme.mutedForeground,
                  ),
                ),
              ),
            if (_effectiveValidation != null && !_effectiveValidating)
              Padding(
                key: const Key('bc-form-builder-validation-status'),
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  _effectiveValidation!.valid
                      ? t('builder.validation_passed', 'Valid')
                      : t('builder.validation_failed', 'Invalid'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _effectiveValidation!.valid
                        ? BcTheme.success
                        : BcTheme.destructive,
                  ),
                ),
              ),
            PlatformElevatedButton(
              key: const Key('bc-form-builder-validate'),
              onPressed: _effectiveValidating ? null : _runValidation,
              child: Text(t('builder.validate', 'Validate')),
            ),
            const SizedBox(width: 4),
            PlatformElevatedButton(
              key: const Key('bc-form-builder-save'),
              onPressed: (_effectiveSaveDisabled || _effectiveValidating)
                  ? null
                  : _handleSave,
              child: Text(t('builder.save', 'Save')),
            ),
          ];

          // Tabs plus actions exceed a narrow host, so scroll instead of
          // overflowing. A Spacer needs bounded width, so it is only used in
          // the wide layout.
          if (constraints.maxWidth < 560) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [...tabs, const SizedBox(width: 12), ...status],
              ),
            );
          }

          return Row(
            children: [...tabs, const Spacer(), ...status],
          );
        },
      ),
    );
  }

  Widget _buildTabButton(BcFormBuilderTab tab, String label) {
    final isActive = _activeTab == tab;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = tab;
        });
      },
      child: Container(
        key: Key('bc-form-builder-tab-${tab.name}'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? BcTheme.foreground : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isActive ? BcTheme.foreground : BcTheme.mutedForeground,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case BcFormBuilderTab.canvas:
        return _buildCanvasTab();
      case BcFormBuilderTab.json:
        return _buildJsonTab();
      case BcFormBuilderTab.live:
        return _buildLiveTab();
    }
  }

  Widget _buildCanvasTab() {
    // Palette and property panel have fixed widths, so the three-pane row
    // overflows as soon as the host is narrower than their sum plus a usable
    // canvas. Below that threshold, keep every pane reachable by scrolling
    // horizontally instead of clipping content.
    const paletteWidth = 180.0;
    const panelWidth = 280.0;
    const minCanvasWidth = 340.0;
    const minTotalWidth = paletteWidth + panelWidth + minCanvasWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        final panes = Row(
          children: [
            _buildPalette(),
            Expanded(child: _buildCanvas()),
            _buildPropertyPanel(),
          ],
        );

        if (constraints.maxWidth >= minTotalWidth) return panes;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: minTotalWidth, child: panes),
        );
      },
    );
  }

  Widget _buildPalette() {
    return Container(
      key: const Key('bc-form-builder-palette'),
      width: 180,
      decoration: BoxDecoration(
        color: BcTheme.muted,
        border: Border(
          right: BorderSide(color: BcTheme.border),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              t('builder.field_type', 'Field Types'),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: BcTheme.mutedForeground,
              ),
            ),
          ),
          for (final ft in BcFieldType.values)
            _buildPaletteItem(ft),
        ],
      ),
    );
  }

  Widget _buildPaletteItem(BcFieldType ft) {
    return LongPressDraggable<BcFieldType>(
      data: ft,
      delay: const Duration(milliseconds: 200),
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(BcTheme.radius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: BcTheme.background,
            border: Border.all(color: BcTheme.foreground),
            borderRadius: BorderRadius.circular(BcTheme.radius),
          ),
          child: Text(
            ft.label,
            style: TextStyle(
              fontSize: 14,
              color: BcTheme.foreground,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _paletteItemContent(ft),
      ),
      child: _paletteItemContent(ft),
    );
  }

  Widget _paletteItemContent(BcFieldType ft) {
    return GestureDetector(
      key: Key('bc-form-builder-palette-item-${ft.id}'),
      onTap: () => _addField(ft),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: BcTheme.background,
          border: Border.all(color: BcTheme.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(ft.icon, size: 16, color: BcTheme.mutedForeground),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                ft.label,
                style: TextStyle(
                  fontSize: 14,
                  color: BcTheme.foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    final fields = _effectiveFields;
    return DragTarget<BcFieldType>(
      key: const Key('bc-form-builder-canvas'),
      onAcceptWithDetails: (details) {
        _addField(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Container(
          color: isHovering ? BcTheme.accent : null,
          child: fields.isEmpty
              ? Center(
                  key: const Key('bc-form-builder-empty'),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      t('builder.drag_hint', 'Drag fields here to build your form'),
                      style: TextStyle(
                        fontSize: 14,
                        color: BcTheme.mutedForeground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: fields.length,
                  onReorder: _onReorder,
                  proxyDecorator: (child, index, animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return Material(
                          elevation: 4 * animation.value,
                          borderRadius: BorderRadius.circular(BcTheme.radius),
                          child: child,
                        );
                      },
                      child: child,
                    );
                  },
                  itemBuilder: (context, index) {
                    final field = fields[index];
                    return _buildFieldCard(field, index, Key(field.id));
                  },
                ),
        );
      },
    );
  }

  Widget _buildFieldCard(BcFormField field, int index, Key key) {
    final isSelected = _selectedFieldId == field.id;
    return GestureDetector(
      key: key,
      onTap: () {
        setState(() {
          _selectedFieldId = field.id;
        });
      },
      child: Container(
        key: Key('bc-form-builder-field-${field.id}'),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: BcTheme.background,
          border: Border.all(
            color: isSelected ? BcTheme.foreground : BcTheme.border,
          ),
          borderRadius: BorderRadius.circular(BcTheme.radius),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: BcTheme.foreground.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(field.type.icon, size: 20, color: BcTheme.mutedForeground),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          field.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: BcTheme.foreground,
                          ),
                        ),
                      ),
                      if (field.required)
                        Text(
                          ' *',
                          style: TextStyle(
                            color: BcTheme.destructive,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${field.name} (${field.type.id})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: BcTheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_upward, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              tooltip: 'Move up',
              onPressed: index > 0
                  ? () => _moveField(index, index - 1)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_downward, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              tooltip: 'Move down',
              onPressed: index < _effectiveFields.length - 1
                  ? () => _moveField(index, index + 1)
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.close, size: 16, color: BcTheme.destructive),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              tooltip: t('builder.remove_field', 'Remove'),
              onPressed: () => _removeField(field.id),
            ),
            ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.drag_indicator,
                  size: 20,
                  color: BcTheme.mutedForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyPanel() {
    final selected = _selectedField;
    return Container(
      key: const Key('bc-form-builder-properties'),
      width: 280,
      decoration: BoxDecoration(
        color: BcTheme.background,
        border: Border(
          left: BorderSide(color: BcTheme.border),
        ),
      ),
      child: selected == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  t('builder.property_panel', 'Select a field to edit properties'),
                  style: TextStyle(
                    fontSize: 14,
                    color: BcTheme.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : _buildPropertyPanelContent(selected),
    );
  }

  Widget _buildPropertyPanelContent(BcFormField field) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          t('builder.property_panel', 'Properties'),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: BcTheme.mutedForeground,
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          key: 'bc-form-builder-prop-label',
          label: t('builder.field_label', 'Label'),
          value: field.label,
          onChanged: (v) => _updateField(
            field.id,
            (f) => f.copyWith(label: v),
          ),
        ),
        _buildTextField(
          key: 'bc-form-builder-prop-name',
          label: t('builder.field_name', 'Field Name'),
          value: field.name,
          onChanged: (v) => _updateField(
            field.id,
            (f) => f.copyWith(name: v),
          ),
        ),
        _buildDropdownField(
          key: 'bc-form-builder-prop-type',
          label: t('builder.field_type', 'Field Type'),
          value: field.type,
          items: BcFieldType.values,
          itemLabel: (ft) => ft.label,
          onChanged: (ft) => _updateField(
            field.id,
            (f) => f.copyWith(type: ft),
          ),
        ),
        _buildNumberField(
          key: 'bc-form-builder-prop-width',
          label: t('builder.field_width', 'Width (1-12)'),
          value: field.width,
          min: 1,
          max: 12,
          onChanged: (v) => _updateField(
            field.id,
            (f) => f.copyWith(width: v),
          ),
        ),
        _buildTextField(
          key: 'bc-form-builder-prop-widget',
          label: t('builder.field_widget', 'Widget'),
          value: field.widget ?? '',
          onChanged: (v) => _updateField(
            field.id,
            (f) => f.copyWith(widget: v.isEmpty ? null : v),
          ),
        ),
        if (field.type == BcFieldType.selection)
          _buildTextField(
            key: 'bc-form-builder-prop-options',
            label: 'Options (comma-separated)',
            value: field.options.join(', '),
            onChanged: (v) => _updateField(
              field.id,
              (f) => f.copyWith(
                options: v
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList(),
              ),
            ),
          ),
        if (field.type.isRelation)
          _buildTextField(
            key: 'bc-form-builder-prop-relation',
            label: 'Relation Model',
            value: field.relationModel ?? '',
            onChanged: (v) => _updateField(
              field.id,
              (f) => f.copyWith(relationModel: v.isEmpty ? null : v),
            ),
          ),
        _buildTextField(
          key: 'bc-form-builder-prop-default',
          label: t('builder.field_default', 'Default Value'),
          value: field.defaultValue ?? '',
          onChanged: (v) => _updateField(
            field.id,
            (f) => f.copyWith(defaultValue: v.isEmpty ? null : v),
          ),
        ),
        const SizedBox(height: 8),
        _buildCheckboxField(
          key: 'bc-form-builder-prop-required',
          label: t('builder.field_required', 'Required'),
          value: field.required,
          onChanged: (v) => _updateField(
            field.id,
            (f) => f.copyWith(required: v),
          ),
        ),
        _buildCheckboxField(
          key: 'bc-form-builder-prop-readonly',
          label: t('builder.field_readonly', 'Read Only'),
          value: field.readonly,
          onChanged: (v) => _updateField(
            field.id,
            (f) => f.copyWith(readonly: v),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String key,
    required String label,
    required String value,
    required void Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: BcTheme.foreground,
            ),
          ),
          const SizedBox(height: 4),
          PlatformWidget(
            key: Key(key),
            material: (context, platform) => TextField(
              controller: TextEditingController(text: value),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: BcTheme.border),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                isDense: true,
              ),
              style: TextStyle(fontSize: 14, color: BcTheme.foreground),
              onChanged: onChanged,
            ),
            cupertino: (context, platform) => CupertinoTextField(
              controller: TextEditingController(text: value),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: BcTheme.border),
                borderRadius: BorderRadius.circular(4),
              ),
              style: TextStyle(fontSize: 14, color: BcTheme.foreground),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String key,
    required String label,
    required int value,
    required int min,
    required int max,
    required void Function(int) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: BcTheme.foreground,
            ),
          ),
          const SizedBox(height: 4),
          PlatformWidget(
            key: Key(key),
            material: (context, platform) => TextField(
              controller: TextEditingController(text: value.toString()),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: BcTheme.border),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                isDense: true,
              ),
              style: TextStyle(fontSize: 14, color: BcTheme.foreground),
              onChanged: (v) {
                final n = int.tryParse(v) ?? min;
                onChanged(n.clamp(min, max));
              },
            ),
            cupertino: (context, platform) => CupertinoTextField(
              controller: TextEditingController(text: value.toString()),
              keyboardType: TextInputType.number,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: BcTheme.border),
                borderRadius: BorderRadius.circular(4),
              ),
              style: TextStyle(fontSize: 14, color: BcTheme.foreground),
              onChanged: (v) {
                final n = int.tryParse(v) ?? min;
                onChanged(n.clamp(min, max));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String key,
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: BcTheme.foreground,
            ),
          ),
          const SizedBox(height: 4),
          PlatformWidget(
            key: Key(key),
            material: (context, platform) => DropdownButtonFormField<T>(
              value: value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: BcTheme.border),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                isDense: true,
              ),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          itemLabel(item),
                          style: TextStyle(
                            fontSize: 14,
                            color: BcTheme.foreground,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
            cupertino: (context, platform) =>CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: BcTheme.background,
              onPressed: () {
                _showCupertinoPicker(context, items, value, itemLabel, onChanged);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    itemLabel(value),
                    style: TextStyle(
                      fontSize: 14,
                      color: BcTheme.foreground,
                    ),
                  ),
                  Icon(
                    CupertinoIcons.chevron_down,
                    size: 14,
                    color: BcTheme.mutedForeground,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCupertinoPicker<T>(
    BuildContext context,
    List<T> items,
    T currentValue,
    String Function(T) label,
    void Function(T) onChanged,
  ) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 250,
        color: BcTheme.background,
        child: CupertinoPicker(
          itemExtent: 32,
          scrollController: FixedExtentScrollController(
            initialItem: items.indexOf(currentValue).clamp(0, items.length - 1),
          ),
          onSelectedItemChanged: (index) {
            onChanged(items[index]);
          },
          children: items
              .map((item) => Center(
                    child: Text(
                      label(item),
                      style: TextStyle(
                        fontSize: 14,
                        color: BcTheme.foreground,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildCheckboxField({
    required String key,
    required String label,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return PlatformWidget(
      key: Key(key),
      material: (context, platform) => Material(
        color: Colors.transparent,
        child: CheckboxListTile(
          value: value,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          title: Text(
            label,
            style: TextStyle(fontSize: 14, color: BcTheme.foreground),
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
      cupertino: (context, platform) =>CupertinoListTile(
        leading: CupertinoSwitch(
          value: value,
          onChanged: onChanged,
        ),
        title: Text(
          label,
          style: TextStyle(fontSize: 14, color: BcTheme.foreground),
        ),
      ),
    );
  }

  Widget _buildJsonTab() {
    final jsonStr = _buildViewJson().toJsonString();
    return Container(
      key: const Key('bc-form-builder-json'),
      color: BcTheme.muted,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: SelectableText(
          key: const Key('bc-form-builder-json-output'),
          jsonStr,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: BcTheme.foreground,
          ),
        ),
      ),
    );
  }

  Widget _buildLiveTab() {
    final fields = _effectiveFields;
    return Container(
      key: const Key('bc-form-builder-live'),
      padding: const EdgeInsets.all(16),
      child: fields.isEmpty
          ? Center(
              child: Text(
                'No fields to preview',
                style: TextStyle(
                  fontSize: 14,
                  color: BcTheme.mutedForeground,
                ),
              ),
            )
          : Form(
              key: const Key('bc-form-builder-live-form'),
              child: ListView(
                children: fields.map((field) => _buildLiveField(field)).toList(),
              ),
            ),
    );
  }

  Widget _buildLiveField(BcFormField field) {
    return Padding(
      key: Key('bc-form-builder-live-field-${field.name}'),
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                field.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: BcTheme.foreground,
                ),
              ),
              if (field.required)
                Text(
                  ' *',
                  style: TextStyle(
                    color: BcTheme.destructive,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          _buildLiveFieldInput(field),
        ],
      ),
    );
  }

  Widget _buildLiveFieldInput(BcFormField field) {
    if (field.type == BcFieldType.boolean) {
      return PlatformSwitch(
        value: false,
        onChanged: field.readonly ? null : (_) {},
      );
    }
    if (field.type == BcFieldType.selection) {
      return PlatformWidget(
        material: (context, platform) => DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: BcTheme.border),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
          items: field.options
              .map((opt) => DropdownMenuItem(
                    value: opt,
                    child: Text(opt),
                  ))
              .toList(),
          onChanged: field.readonly ? null : (_) {},
        ),
        cupertino: (context, platform) =>CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          color: BcTheme.background,
          onPressed: field.readonly
              ? null
              : () {
                  _showCupertinoPicker(
                    context,
                    field.options,
                    field.options.isNotEmpty ? field.options.first : '',
                    (s) => s,
                    (_) {},
                  );
                },
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              field.options.isNotEmpty ? field.options.first : 'Select...',
              style: TextStyle(fontSize: 14, color: BcTheme.foreground),
            ),
          ),
        ),
      );
    }
    if (field.type == BcFieldType.integer || field.type == BcFieldType.float) {
      return PlatformWidget(
        material: (context, platform) => TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: BcTheme.border),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            hintText: field.defaultValue,
          ),
          enabled: !field.readonly,
        ),
        cupertino: (context, platform) =>CupertinoTextField(
          keyboardType: TextInputType.number,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: BcTheme.border),
            borderRadius: BorderRadius.circular(4),
          ),
          placeholder: field.defaultValue,
          enabled: !field.readonly,
        ),
      );
    }
    if (field.type == BcFieldType.datetime) {
      return PlatformWidget(
        material: (context, platform) => TextField(
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: BcTheme.border),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
          enabled: !field.readonly,
        ),
        cupertino: (context, platform) =>CupertinoTextField(
          keyboardType: TextInputType.datetime,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: BcTheme.border),
            borderRadius: BorderRadius.circular(4),
          ),
          enabled: !field.readonly,
        ),
      );
    }
    if (field.type == BcFieldType.json) {
      return PlatformWidget(
        material: (context, platform) => TextField(
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: BcTheme.border),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            hintText: '{}',
          ),
          enabled: !field.readonly,
        ),
        cupertino: (context, platform) =>CupertinoTextField(
          maxLines: 3,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: BcTheme.border),
            borderRadius: BorderRadius.circular(4),
          ),
          placeholder: '{}',
          enabled: !field.readonly,
        ),
      );
    }
    if (field.type.isRelation) {
      return PlatformWidget(
        material: (context, platform) => TextField(
          enabled: false,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: BcTheme.border),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            hintText: field.type.isRelation && field.relationModel != null
                ? '${field.type.id} -> ${field.relationModel}'
                : field.type.id,
          ),
        ),
        cupertino: (context, platform) =>CupertinoTextField(
          enabled: false,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: BcTheme.border),
            borderRadius: BorderRadius.circular(4),
          ),
          placeholder: field.type.isRelation && field.relationModel != null
              ? '${field.type.id} -> ${field.relationModel}'
              : field.type.id,
        ),
      );
    }
    return PlatformWidget(
      material: (context, platform) => TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: BcTheme.border),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          hintText: field.defaultValue,
        ),
        enabled: !field.readonly,
      ),
      cupertino: (context, platform) =>CupertinoTextField(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: BcTheme.border),
          borderRadius: BorderRadius.circular(4),
        ),
        placeholder: field.defaultValue,
        enabled: !field.readonly,
      ),
    );
  }

  Widget _buildErrorBar() {
    return Container(
      key: const Key('bc-form-builder-errors'),
      decoration: BoxDecoration(
        color: BcTheme.destructive.withValues(alpha: 0.05),
        border: Border(
          top: BorderSide(
            color: BcTheme.destructive.withValues(alpha: 0.3),
          ),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _effectiveValidation!.errors.map((err) {
          return Padding(
            key: Key('bc-form-builder-error-${err.field ?? ''}-${err.message}'),
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              err.field != null && err.field!.isNotEmpty
                  ? '[${err.field}] ${err.message}'
                  : err.message,
              style: TextStyle(
                fontSize: 12,
                color: BcTheme.destructive,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
