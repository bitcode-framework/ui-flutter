// Input Extended demo - BcRichText, BcCode, BcJson, BcMarkdown, BcColorPicker,
// BcKnob, BcMentions, BcOtp, BcTransfer, BcCascader, BcTreeSelect,
// BcFieldDynLink.
library input_extended_section;

import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

import '../demo_widgets.dart';

class InputExtendedSection extends StatefulWidget {
  const InputExtendedSection({super.key});

  @override
  State<InputExtendedSection> createState() => _InputExtendedSectionState();
}

class _InputExtendedSectionState extends State<InputExtendedSection> {
  String _otpValue = '';
  List<String> _transferTarget = ['item2'];
  String _colorValue = '#3B82F6';
  double _knobValue = 50;

  @override
  Widget build(BuildContext context) {
    return BcYStack(
      gap: 24,
      children: [
        const SectionHeader(
          title: 'Input Extended',
          subtitle: 'Rich text editors, code, JSON, color pickers, OTP, transfer, cascader, tree select.',
        ),

        // -- BcRichText --
        DemoCard(
          title: 'BcRichText',
          description: 'Rich text editor with bold/italic/underline formatting toolbar.',
          child: BcRichText(
            label: 'Article Body',
            placeholder: 'Write your article...',
            rows: 5,
            defaultValue: 'This is editable rich text. Select text and use the toolbar to format.',
          ),
        ),

        // -- BcCode --
        DemoCard(
          title: 'BcCode',
          description: 'Code editor with syntax highlighting (Dart, JS, Python, etc.).',
          child: BcCode(
            label: 'Snippet',
            language: 'dart',
            rows: 6,
            defaultValue: 'void main() {\n  print("Hello, BitCode!");\n}',
          ),
        ),

        // -- BcJson --
        DemoCard(
          title: 'BcJson',
          description: 'JSON editor with raw and tree view modes.',
          child: BcJson(
            label: 'Config',
            rows: 6,
            defaultValue: '{\n  "name": "BitCode",\n  "version": "1.0.0"\n}',
          ),
        ),

        // -- BcMarkdown --
        DemoCard(
          title: 'BcMarkdown',
          description: 'Markdown editor with edit/preview toggle and format toolbar.',
          child: BcMarkdown(
            label: 'Readme',
            rows: 6,
            defaultValue: '# Heading\n\nThis is **bold** and *italic*.\n\n- Item 1\n- Item 2',
          ),
        ),

        // -- BcColorPicker --
        DemoCard(
          title: 'BcColorPicker',
          description: 'Hex color picker with optional preset swatches.',
          child: BcColorPicker(
            label: 'Brand Color',
            value: _colorValue,
            presets: const ['#EF4444', '#F97316', '#EAB308', '#22C55E', '#3B82F6', '#8B5CF6'],
            showValue: true,
            onValueChange: (v, _) => setState(() => _colorValue = v),
          ),
        ),

        // -- BcKnob --
        DemoCard(
          title: 'BcKnob',
          description: 'Rotary knob dial for analog-style value selection.',
          child: BcXStack(
            gap: 16,
            crossAxisAlignment: BcXStackAlign.center,
            children: [
              BcKnob(
                value: _knobValue,
                min: 0,
                max: 100,
                size: 96,
                label: 'Volume',
                onChange: (v, _) => setState(() => _knobValue = v),
              ),
              Text('Value: ${_knobValue.round()}',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),

        // -- BcMentions --
        DemoCard(
          title: 'BcMentions',
          description: '@-mention input with dropdown of suggestions.',
          child: BcMentions(
            label: 'Comment',
            placeholder: 'Type @ to mention someone...',
            rows: 3,
            prefix: '@',
            options: const [
              BcMentionOption(value: 'alice', label: 'Alice Johnson'),
              BcMentionOption(value: 'bob', label: 'Bob Smith'),
              BcMentionOption(value: 'charlie', label: 'Charlie Brown'),
              BcMentionOption(value: 'diana', label: 'Diana Prince'),
            ],
          ),
        ),

        // -- BcOtp --
        DemoCard(
          title: 'BcOtp',
          description: 'Segmented one-time password / PIN input (6 digits).',
          child: BcYStack(
            gap: 8,
            children: [
              BcOtp(
                name: 'otp',
                label: 'Verification Code',
                length: 6,
                value: _otpValue,
                onValueChange: (v, _) => setState(() => _otpValue = v),
              ),
              if (_otpValue.isNotEmpty)
                Text('Code: $_otpValue',
                    style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),

        // -- BcTransfer --
        DemoCard(
          title: 'BcTransfer',
          description: 'Dual-list transfer selector with arrow buttons.',
          child: BcTransfer(
            items: const [
              BcTransferItem(key: 'item1', label: 'Item One'),
              BcTransferItem(key: 'item2', label: 'Item Two'),
              BcTransferItem(key: 'item3', label: 'Item Three'),
              BcTransferItem(key: 'item4', label: 'Item Four'),
              BcTransferItem(key: 'item5', label: 'Item Five'),
            ],
            targetKeys: _transferTarget,
            titles: const ['Available', 'Selected'],
            onValueChange: (v, _) => setState(() => _transferTarget = v),
          ),
        ),

        // -- BcCascader --
        DemoCard(
          title: 'BcCascader',
          description: 'Multi-level cascading select (e.g. Country > Province > City).',
          child: BcCascader(
            name: 'region',
            label: 'Region',
            placeholder: 'Select region...',
            options: const [
              BcCascaderOption(
                label: 'Indonesia',
                value: 'id',
                children: [
                  BcCascaderOption(
                    label: 'Jakarta',
                    value: 'jkt',
                  ),
                  BcCascaderOption(
                    label: 'Bandung',
                    value: 'bdg',
                  ),
                ],
              ),
              BcCascaderOption(
                label: 'United States',
                value: 'us',
                children: [
                  BcCascaderOption(label: 'New York', value: 'ny'),
                  BcCascaderOption(label: 'California', value: 'ca'),
                ],
              ),
            ],
          ),
        ),

        // -- BcTreeSelect --
        DemoCard(
          title: 'BcTreeSelect',
          description: 'Tree-structured dropdown select with expand/collapse.',
          child: BcTreeSelect(
            name: 'category',
            label: 'Category',
            placeholder: 'Select category...',
            nodes: const [
              BcTreeSelectNode(
                label: 'Engineering',
                value: 'eng',
                children: [
                  BcTreeSelectNode(label: 'Frontend', value: 'fe'),
                  BcTreeSelectNode(label: 'Backend', value: 'be'),
                  BcTreeSelectNode(label: 'DevOps', value: 'devops'),
                ],
              ),
              BcTreeSelectNode(
                label: 'Design',
                value: 'design',
                children: [
                  BcTreeSelectNode(label: 'UI', value: 'ui'),
                  BcTreeSelectNode(label: 'UX', value: 'ux'),
                ],
              ),
            ],
            defaultExpanded: const ['eng'],
          ),
        ),

        // -- BcFieldMorph --
        DemoCard(
          title: 'BcFieldMorph',
          description: 'Morphing field that can switch between input/number/date/select types.',
          child: BcFieldMorph(
            label: 'Flexible Field',
            types: const [
              BcFieldMorphType(value: 'text', label: 'Text', widget: 'text'),
              BcFieldMorphType(value: 'number', label: 'Number', widget: 'number'),
              BcFieldMorphType(value: 'date', label: 'Date', widget: 'date'),
            ],
            placeholder: 'Type or switch field type...',
          ),
        ),

        // -- BcFieldTableSelect --
        DemoCard(
          title: 'BcFieldTableSelect',
          description: 'Selectable data table field (single or multi-row selection).',
          child: SizedBox(
            height: 200,
            child: BcFieldTableSelect(
              label: 'Pick a member',
              titleField: 'name',
              columns: const [
                BcFieldTableSelectColumn(key: 'name', label: 'Name'),
                BcFieldTableSelectColumn(key: 'role', label: 'Role'),
              ],
              data: const [
                {'name': 'Alice', 'role': 'Admin'},
                {'name': 'Bob', 'role': 'Editor'},
                {'name': 'Charlie', 'role': 'Viewer'},
              ],
            ),
          ),
        ),

        // -- BcLookupModal --
        DemoCard(
          title: 'BcLookupModal',
          description: 'Lookup modal with searchable data table (opens on trigger).',
          child: BcLookupModal(
            title: 'Find Contact',
            searchable: true,
            searchFields: const ['name', 'email'],
            columns: const [
              BcLookupModalColumn(key: 'name', label: 'Name'),
              BcLookupModalColumn(key: 'email', label: 'Email'),
            ],
            data: const [
              {'name': 'Alice', 'email': 'alice@example.com'},
              {'name': 'Bob', 'email': 'bob@example.com'},
            ],
          ),
        ),

        // -- BcFieldDynLink --
        DemoCard(
          title: 'BcFieldDynLink',
          description: 'Dynamic link field: pick a model, then search and select a record.',
          child: BcFieldDynLink(
            label: 'Linked Record',
            placeholder: 'Select a record...',
            models: const [
              BcDynLinkModel(model: 'contact', label: 'Contact'),
              BcDynLinkModel(model: 'product', label: 'Product'),
            ],
            dataFetcher: (model, query) async {
              // Demo data source — returns records filtered by query.
              final all = {
                'contact': const [
                  BcDynLinkRecord(id: 'c1', label: 'Alice Anderson'),
                  BcDynLinkRecord(id: 'c2', label: 'Bob Brown'),
                  BcDynLinkRecord(id: 'c3', label: 'Charlie Chen'),
                ],
                'product': const [
                  BcDynLinkRecord(id: 'p1', label: 'Laptop'),
                  BcDynLinkRecord(id: 'p2', label: 'Keyboard'),
                  BcDynLinkRecord(id: 'p3', label: 'Mouse'),
                ],
              };
              final list = all[model] ?? const [];
              if (query.isEmpty) return list;
              return list
                  .where((r) =>
                      r.label.toLowerCase().contains(query.toLowerCase()))
                  .toList();
            },
            onChange: (value) {
              if (value != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selected: ${value.display} (${value.id})'),
                    duration: const Duration(milliseconds: 900),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}