// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use
library bc_schema_builder;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:http/http.dart' as http;
import '../theme/bc_theme.dart';

/// Field type identifiers mirroring the TS `BcSchemaFieldType` union.
///
/// All 12 BitCode field types are supported.
enum BcSchemaFieldType {
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
      case BcSchemaFieldType.string:
        return 'string';
      case BcSchemaFieldType.integer:
        return 'integer';
      case BcSchemaFieldType.float:
        return 'float';
      case BcSchemaFieldType.boolean:
        return 'boolean';
      case BcSchemaFieldType.datetime:
        return 'datetime';
      case BcSchemaFieldType.json:
        return 'json';
      case BcSchemaFieldType.selection:
        return 'selection';
      case BcSchemaFieldType.many2one:
        return 'many2one';
      case BcSchemaFieldType.one2many:
        return 'one2many';
      case BcSchemaFieldType.many2many:
        return 'many2many';
      case BcSchemaFieldType.morphTo:
        return 'morph_to';
      case BcSchemaFieldType.computed:
        return 'computed';
    }
  }

  String get label {
    switch (this) {
      case BcSchemaFieldType.string:
        return 'Text';
      case BcSchemaFieldType.integer:
        return 'Integer';
      case BcSchemaFieldType.float:
        return 'Decimal';
      case BcSchemaFieldType.boolean:
        return 'Boolean';
      case BcSchemaFieldType.datetime:
        return 'Date/Time';
      case BcSchemaFieldType.json:
        return 'JSON';
      case BcSchemaFieldType.selection:
        return 'Selection';
      case BcSchemaFieldType.many2one:
        return 'Many to One';
      case BcSchemaFieldType.one2many:
        return 'One to Many';
      case BcSchemaFieldType.many2many:
        return 'Many to Many';
      case BcSchemaFieldType.morphTo:
        return 'Polymorphic';
      case BcSchemaFieldType.computed:
        return 'Computed';
    }
  }

  IconData get icon {
    switch (this) {
      case BcSchemaFieldType.string:
      case BcSchemaFieldType.computed:
        return Icons.text_fields;
      case BcSchemaFieldType.integer:
      case BcSchemaFieldType.float:
        return Icons.numbers;
      case BcSchemaFieldType.boolean:
        return Icons.check_box_outlined;
      case BcSchemaFieldType.datetime:
        return Icons.calendar_today;
      case BcSchemaFieldType.json:
        return Icons.code;
      case BcSchemaFieldType.selection:
        return Icons.list;
      case BcSchemaFieldType.many2one:
      case BcSchemaFieldType.one2many:
      case BcSchemaFieldType.many2many:
      case BcSchemaFieldType.morphTo:
        return Icons.link;
    }
  }

  static BcSchemaFieldType fromString(String s) {
    switch (s) {
      case 'string':
        return BcSchemaFieldType.string;
      case 'integer':
        return BcSchemaFieldType.integer;
      case 'float':
        return BcSchemaFieldType.float;
      case 'boolean':
        return BcSchemaFieldType.boolean;
      case 'datetime':
        return BcSchemaFieldType.datetime;
      case 'json':
        return BcSchemaFieldType.json;
      case 'selection':
        return BcSchemaFieldType.selection;
      case 'many2one':
        return BcSchemaFieldType.many2one;
      case 'one2many':
        return BcSchemaFieldType.one2many;
      case 'many2many':
        return BcSchemaFieldType.many2many;
      case 'morph_to':
        return BcSchemaFieldType.morphTo;
      case 'computed':
        return BcSchemaFieldType.computed;
      default:
        return BcSchemaFieldType.string;
    }
  }

  bool get isRelation =>
      this == BcSchemaFieldType.many2one ||
      this == BcSchemaFieldType.one2many ||
      this == BcSchemaFieldType.many2many ||
      this == BcSchemaFieldType.morphTo;
}

/// A single field definition in the schema builder.
///
/// Mirrors TS `BcSchemaField`.
class BcSchemaField {
  final String id;
  final String name;
  final String label;
  final BcSchemaFieldType type;
  final bool required;
  final bool unique;
  final bool index;
  final int? max;
  final String? defaultValue;
  final List<String> options;
  final String? relationModel;
  final String? computed;

  const BcSchemaField({
    required this.id,
    required this.name,
    required this.label,
    required this.type,
    this.required = false,
    this.unique = false,
    this.index = false,
    this.max,
    this.defaultValue,
    this.options = const [],
    this.relationModel,
    this.computed,
  });

  BcSchemaField copyWith({
    String? name,
    String? label,
    BcSchemaFieldType? type,
    bool? required,
    bool? unique,
    bool? index,
    int? max,
    String? defaultValue,
    List<String>? options,
    String? relationModel,
    String? computed,
  }) {
    return BcSchemaField(
      id: id,
      name: name ?? this.name,
      label: label ?? this.label,
      type: type ?? this.type,
      required: required ?? this.required,
      unique: unique ?? this.unique,
      index: index ?? this.index,
      max: max ?? this.max,
      defaultValue: defaultValue ?? this.defaultValue,
      options: options ?? this.options,
      relationModel: relationModel ?? this.relationModel,
      computed: computed ?? this.computed,
    );
  }
}

/// A validation issue (error or warning) from the engine validate endpoint.
///
/// Mirrors TS `BcSchemaValidationIssue`.
class BcSchemaValidationIssue {
  final String? field;
  final String message;

  const BcSchemaValidationIssue({this.field, required this.message});
}

/// Validation result from the admin validate endpoint.
///
/// Mirrors TS `BcSchemaValidationResult`.
class BcSchemaValidationResult {
  final bool valid;
  final List<BcSchemaValidationIssue> errors;
  final List<BcSchemaValidationIssue> warnings;

  const BcSchemaValidationResult({
    required this.valid,
    this.errors = const [],
    this.warnings = const [],
  });

  factory BcSchemaValidationResult.fromJson(Map<String, dynamic> json) {
    return BcSchemaValidationResult(
      valid: json['valid'] == true,
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) => BcSchemaValidationIssue(
                    field: e['field'] as String?,
                    message: e['message'] as String? ?? '',
                  ))
              .toList() ??
          [],
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => BcSchemaValidationIssue(
                    field: e['field'] as String?,
                    message: e['message'] as String? ?? '',
                  ))
              .toList() ??
          [],
    );
  }
}

/// Data source for the schema builder validation endpoint.
///
/// Mirrors TS `BcSchemaBuilderDataSource`.
class BcSchemaBuilderDataSource {
  final String? validateEndpoint;
  final Map<String, String>? headers;

  const BcSchemaBuilderDataSource({this.validateEndpoint, this.headers});
}

/// The model.json output of the schema builder.
///
/// Mirrors TS `BcModelJson`.
class BcModelJson {
  final String name;
  final String? module;
  final String? label;
  final Map<String, Map<String, dynamic>> fields;

  const BcModelJson({
    required this.name,
    this.module,
    this.label,
    required this.fields,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'fields': fields,
    };
    if (module != null && module!.isNotEmpty) json['module'] = module;
    if (label != null && label!.isNotEmpty) json['label'] = label;
    return json;
  }

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());
}

/// The active builder tab.
enum BcSchemaBuilderTab { canvas, json }

/// Visual Schema Builder widget (ADR-014 Phase 4).
///
/// Mirrors TS `BcSchemaBuilder.lite.tsx` (ADR-006 Pure/Adapt pattern).
///
/// Features:
/// - Drag-drop field list with field type palette (LongPress draggable)
/// - Relation config for many2one/one2many/many2many/morph_to
/// - Property panel (required, unique, index, max, default, options, computed)
/// - JSON preview tab
/// - Validation via POST /api/v1/admin/models/validate before save
/// - Platform-aware (ADR-011): iOS uses Cupertino-style controls in the
///   property panel; Android uses Material controls.
class BcSchemaBuilder extends StatefulWidget {
  final String modelName;
  final String module;
  final String label;
  final List<BcSchemaField> fields;
  final BcSchemaBuilderDataSource? dataSource;
  final BcSchemaValidationResult? validation;
  final bool validating;
  final bool saveDisabled;
  final Map<String, String>? i18n;
  final void Function(List<BcSchemaField> fields)? onChange;
  final void Function(BcModelJson modelJson)? onValidate;
  final void Function(BcSchemaValidationResult result)? onValidationResult;
  final void Function(BcModelJson modelJson)? onSave;

  const BcSchemaBuilder({
    super.key,
    this.modelName = '',
    this.module = '',
    this.label = '',
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
  State<BcSchemaBuilder> createState() => _BcSchemaBuilderState();
}

class _BcSchemaBuilderState extends State<BcSchemaBuilder> {
  List<BcSchemaField> _fields = [];
  String _selectedFieldId = '';
  BcSchemaBuilderTab _activeTab = BcSchemaBuilderTab.canvas;
  BcSchemaValidationResult? _validation;
  bool _validating = false;
  int _fieldCounter = 0;

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

  List<BcSchemaField> get _effectiveFields =>
      widget.fields.isNotEmpty ? widget.fields : _fields;

  BcSchemaValidationResult? get _effectiveValidation =>
      widget.validation ?? _validation;

  bool get _effectiveValidating => widget.validating || _validating;

  bool get _effectiveSaveDisabled {
    if (widget.saveDisabled) return true;
    final val = _effectiveValidation;
    if (val != null && !val.valid) return true;
    return false;
  }

  void _emitChange(List<BcSchemaField> fields) {
    setState(() {
      _fields = fields;
    });
    widget.onChange?.call(fields);
  }

  BcSchemaField? get _selectedField {
    if (_selectedFieldId.isEmpty) return null;
    for (final f in _effectiveFields) {
      if (f.id == _selectedFieldId) return f;
    }
    return null;
  }

  BcModelJson _buildModelJson() {
    final fields = _effectiveFields;
    final fieldsMap = <String, Map<String, dynamic>>{};

    for (final f in fields) {
      final fieldDef = <String, dynamic>{'type': f.type.id};
      if (f.required) fieldDef['required'] = true;
      if (f.unique) fieldDef['unique'] = true;
      if (f.index) fieldDef['index'] = true;
      if (f.max != null && f.max! > 0) fieldDef['max'] = f.max;
      if (f.defaultValue != null && f.defaultValue!.isNotEmpty) {
        fieldDef['default'] = f.defaultValue;
      }
      if (f.type == BcSchemaFieldType.selection &&
          f.options.isNotEmpty) {
        fieldDef['options'] = f.options;
      }
      if (f.type.isRelation && f.relationModel != null) {
        if (f.type == BcSchemaFieldType.morphTo) {
          fieldDef['models'] = [f.relationModel];
        } else {
          fieldDef['model'] = f.relationModel;
        }
      }
      if (f.type == BcSchemaFieldType.computed && f.computed != null) {
        fieldDef['computed'] = f.computed;
      }
      fieldsMap[f.name] = fieldDef;
    }

    return BcModelJson(
      name: widget.modelName.isNotEmpty ? widget.modelName : 'new_model',
      module: widget.module.isNotEmpty ? widget.module : null,
      label: widget.label.isNotEmpty ? widget.label : null,
      fields: fieldsMap,
    );
  }

  void _addField(BcSchemaFieldType type) {
    _fieldCounter++;
    final id = 'field_$_fieldCounter';
    final name = '${type.id}_$_fieldCounter';
    final field = BcSchemaField(
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

  void _updateField(String id, BcSchemaField Function(BcSchemaField) updater) {
    final next = _effectiveFields.map((f) {
      return f.id == id ? updater(f) : f;
    }).toList();
    _emitChange(next);
  }

  void _moveField(int from, int to) {
    if (from < 0 ||
        to < 0 ||
        from >= _effectiveFields.length ||
        to >= _effectiveFields.length) {
      return;
    }
    final fields = List<BcSchemaField>.from(_effectiveFields);
    final item = fields.removeAt(from);
    fields.insert(to, item);
    _emitChange(fields);
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    _moveField(oldIndex, newIndex);
  }

  Future<void> _runValidation() async {
    final modelJson = _buildModelJson();
    setState(() {
      _validating = true;
    });

    widget.onValidate?.call(modelJson);

    final endpoint = widget.dataSource?.validateEndpoint ??
        '/api/v1/admin/models/validate';

    try {
      final uri = Uri.parse(endpoint);
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ...?widget.dataSource?.headers,
        },
        body: jsonEncode(modelJson.toJson()),
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final result = BcSchemaValidationResult.fromJson(json);
      setState(() {
        _validation = result;
        _validating = false;
      });
      widget.onValidationResult?.call(result);
    } catch (e) {
      final result = BcSchemaValidationResult(
        valid: false,
        errors: [
          BcSchemaValidationIssue(message: 'Validation request failed: $e'),
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
    widget.onSave?.call(_buildModelJson());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('bc-schema-builder'),
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
      key: const Key('bc-schema-builder-tabs'),
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
            _buildTabButton(BcSchemaBuilderTab.canvas,
                t('schema_builder.fields', 'Fields')),
            const SizedBox(width: 4),
            _buildTabButton(BcSchemaBuilderTab.json,
                t('schema_builder.json_preview', 'JSON')),
          ];

          final status = <Widget>[
            if (_effectiveValidating)
              Padding(
                key: const Key('bc-schema-builder-validating'),
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
                key: const Key('bc-schema-builder-validation-status'),
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  _effectiveValidation!.valid
                      ? t('schema_builder.validation_passed', 'Valid')
                      : t('schema_builder.validation_failed', 'Invalid'),
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
              key: const Key('bc-schema-builder-validate'),
              onPressed: _effectiveValidating ? null : _runValidation,
              child: Text(t('schema_builder.validate', 'Validate')),
            ),
            const SizedBox(width: 4),
            PlatformElevatedButton(
              key: const Key('bc-schema-builder-save'),
              onPressed: (_effectiveSaveDisabled || _effectiveValidating)
                  ? null
                  : _handleSave,
              child: Text(t('schema_builder.save', 'Save')),
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

          return Row(children: [...tabs, const Spacer(), ...status]);
        },
      ),
    );
  }

  Widget _buildTabButton(BcSchemaBuilderTab tab, String label) {
    final isActive = _activeTab == tab;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = tab;
        });
      },
      child: Container(
        key: Key('bc-schema-builder-tab-${tab.name}'),
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
      case BcSchemaBuilderTab.canvas:
        return _buildCanvasTab();
      case BcSchemaBuilderTab.json:
        return _buildJsonTab();
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
      key: const Key('bc-schema-builder-palette'),
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
              t('schema_builder.field_type', 'Field Types'),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: BcTheme.mutedForeground,
              ),
            ),
          ),
          for (final ft in BcSchemaFieldType.values) _buildPaletteItem(ft),
        ],
      ),
    );
  }

  Widget _buildPaletteItem(BcSchemaFieldType ft) {
    return LongPressDraggable<BcSchemaFieldType>(
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

  Widget _paletteItemContent(BcSchemaFieldType ft) {
    return GestureDetector(
      key: Key('bc-schema-builder-palette-item-${ft.id}'),
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
    return DragTarget<BcSchemaFieldType>(
      key: const Key('bc-schema-builder-canvas'),
      onAcceptWithDetails: (details) {
        _addField(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Container(
          color: isHovering ? BcTheme.accent : null,
          child: fields.isEmpty
              ? Center(
                  key: const Key('bc-schema-builder-empty'),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      t('schema_builder.drag_hint',
                          'Drag fields here to define your model'),
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

  Widget _buildFieldCard(BcSchemaField field, int index, Key key) {
    final isSelected = _selectedFieldId == field.id;
    return GestureDetector(
      key: key,
      onTap: () {
        setState(() {
          _selectedFieldId = field.id;
        });
      },
      child: Container(
        key: Key('bc-schema-builder-field-${field.id}'),
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
                    field.type.isRelation && field.relationModel != null
                        ? '${field.name} (${field.type.id} -> ${field.relationModel})'
                        : '${field.name} (${field.type.id})',
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
              onPressed:
                  index > 0 ? () => _moveField(index, index - 1) : null,
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
              tooltip: t('schema_builder.remove_field', 'Remove'),
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
      key: const Key('bc-schema-builder-properties'),
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
                  t('schema_builder.select_field_hint',
                      'Select a field to edit properties'),
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

  Widget _buildPropertyPanelContent(BcSchemaField field) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          t('schema_builder.property_panel', 'Properties'),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: BcTheme.mutedForeground,
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          key: 'bc-schema-builder-prop-label',
          label: t('schema_builder.field_label', 'Label'),
          value: field.label,
          onChanged: (v) => _updateField(
            field.id,
            (f) => f.copyWith(label: v),
          ),
        ),
        _buildTextField(
          key: 'bc-schema-builder-prop-name',
          label: t('schema_builder.field_name', 'Field Name'),
          value: field.name,
          onChanged: (v) => _updateField(
            field.id,
            (f) => f.copyWith(name: v),
          ),
        ),
        _buildDropdownField(
          key: 'bc-schema-builder-prop-type',
          label: t('schema_builder.field_type', 'Field Type'),
          value: field.type,
          items: BcSchemaFieldType.values,
          itemLabel: (ft) => ft.label,
          onChanged: (ft) => _updateField(
            field.id,
            (f) => f.copyWith(type: ft),
          ),
        ),
        if (field.type == BcSchemaFieldType.string ||
            field.type == BcSchemaFieldType.integer ||
            field.type == BcSchemaFieldType.float)
          _buildNumberField(
            key: 'bc-schema-builder-prop-max',
            label: 'Max Length / Value',
            value: field.max ?? 0,
            min: 0,
            max: 999999,
            onChanged: (v) => _updateField(
              field.id,
              (f) => f.copyWith(max: v > 0 ? v : null),
            ),
          ),
        if (field.type == BcSchemaFieldType.selection)
          _buildTextField(
            key: 'bc-schema-builder-prop-options',
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
            key: 'bc-schema-builder-prop-relation',
            label: t('schema_builder.relation_target', 'Relation Target Model'),
            value: field.relationModel ?? '',
            onChanged: (v) => _updateField(
              field.id,
              (f) => f.copyWith(relationModel: v.isEmpty ? null : v),
            ),
          ),
        if (field.type == BcSchemaFieldType.computed)
          _buildTextAreaField(
            key: 'bc-schema-builder-prop-computed',
            label: 'Computed Expression',
            value: field.computed ?? '',
            onChanged: (v) => _updateField(
              field.id,
              (f) => f.copyWith(computed: v.isEmpty ? null : v),
            ),
          ),
        _buildTextField(
          key: 'bc-schema-builder-prop-default',
          label: 'Default Value',
          value: field.defaultValue ?? '',
          onChanged: (v) => _updateField(
            field.id,
            (f) => f.copyWith(defaultValue: v.isEmpty ? null : v),
          ),
        ),
        const SizedBox(height: 8),
        _buildCheckboxField(
          key: 'bc-schema-builder-prop-required',
          label: 'Required',
          value: field.required,
          onChanged: (v) => _updateField(
            field.id,
            (f) => f.copyWith(required: v),
          ),
        ),
        _buildCheckboxField(
          key: 'bc-schema-builder-prop-unique',
          label: 'Unique',
          value: field.unique,
          onChanged: (v) => _updateField(
            field.id,
            (f) => f.copyWith(unique: v),
          ),
        ),
        _buildCheckboxField(
          key: 'bc-schema-builder-prop-index',
          label: 'Index',
          value: field.index,
          onChanged: (v) => _updateField(
            field.id,
            (f) => f.copyWith(index: v),
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

  Widget _buildTextAreaField({
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
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: BcTheme.border),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                isDense: true,
              ),
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
                color: BcTheme.foreground,
              ),
              onChanged: onChanged,
            ),
            cupertino: (context, platform) => CupertinoTextField(
              controller: TextEditingController(text: value),
              maxLines: 3,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: BcTheme.border),
                borderRadius: BorderRadius.circular(4),
              ),
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
                color: BcTheme.foreground,
              ),
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
            cupertino: (context, platform) => CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: BcTheme.background,
              onPressed: () {
                _showCupertinoPicker(
                    context, items, value, itemLabel, onChanged);
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
            initialItem:
                items.indexOf(currentValue).clamp(0, items.length - 1),
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
      cupertino: (context, platform) => CupertinoListTile(
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
    final jsonStr = _buildModelJson().toJsonString();
    return Container(
      key: const Key('bc-schema-builder-json'),
      color: BcTheme.muted,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: SelectableText(
          key: const Key('bc-schema-builder-json-output'),
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

  Widget _buildErrorBar() {
    return Container(
      key: const Key('bc-schema-builder-errors'),
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
            key: Key(
                'bc-schema-builder-error-${err.field ?? ''}-${err.message}'),
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
