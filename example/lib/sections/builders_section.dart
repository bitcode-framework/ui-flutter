// Builders demo - BcFormBuilder, BcSchemaBuilder, BcWorkflowBuilder.
//
// Visual admin builder widgets (ADR-014 Phase 4). These mirror the TS
// *.lite.tsx pure widgets (ADR-006). Each builder provides a drag-drop
// canvas + property panel + JSON preview tab.
library builders_section;

import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

import '../demo_widgets.dart';

class BuildersSection extends StatefulWidget {
  const BuildersSection({super.key});

  @override
  State<BuildersSection> createState() => _BuildersSectionState();
}

class _BuildersSectionState extends State<BuildersSection> {
  List<BcFormField> _formFields = const [
    BcFormField(
      id: 'f1',
      name: 'name',
      label: 'Name',
      type: BcFieldType.string,
      required: true,
      width: 12,
    ),
    BcFormField(
      id: 'f2',
      name: 'email',
      label: 'Email',
      type: BcFieldType.string,
      required: true,
      width: 12,
    ),
    BcFormField(
      id: 'f3',
      name: 'role',
      label: 'Role',
      type: BcFieldType.selection,
      width: 6,
      options: ['Admin', 'Editor', 'Viewer'],
    ),
  ];

  List<BcSchemaField> _schemaFields = const [
    BcSchemaField(
      id: 's1',
      name: 'title',
      label: 'Title',
      type: BcSchemaFieldType.string,
      required: true,
    ),
    BcSchemaField(
      id: 's2',
      name: 'amount',
      label: 'Amount',
      type: BcSchemaFieldType.float,
    ),
    BcSchemaField(
      id: 's3',
      name: 'customer_id',
      label: 'Customer',
      type: BcSchemaFieldType.many2one,
      relationModel: 'res.customer',
      index: true,
    ),
  ];

  List<BcWorkflowStep> _steps = const [
    BcWorkflowStep(
      id: 'step1',
      name: 'fetch_orders',
      type: BcWorkflowStepType.query,
      x: 40,
      y: 40,
      label: 'Fetch Orders',
      model: 'sale.order',
    ),
    BcWorkflowStep(
      id: 'step2',
      name: 'check_status',
      type: BcWorkflowStepType.ifCondition,
      x: 240,
      y: 40,
      label: 'If Confirmed',
      condition: "status == 'confirmed'",
    ),
    BcWorkflowStep(
      id: 'step3',
      name: 'create_invoice',
      type: BcWorkflowStepType.create,
      x: 440,
      y: 40,
      label: 'Create Invoice',
      model: 'account.invoice',
    ),
  ];

  List<BcWorkflowTransition> _transitions = const [
    BcWorkflowTransition(
      id: 't1',
      from: 'step1',
      to: 'step2',
    ),
    BcWorkflowTransition(
      id: 't2',
      from: 'step2',
      to: 'step3',
      label: 'yes',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BcYStack(
      gap: 24,
      children: [
        const SectionHeader(
          title: 'Builders',
          subtitle: 'Visual admin builders for forms, models, and workflows. '
              'Each has a drag-drop canvas and JSON preview tab.',
        ),

        // -- BcFormBuilder --
        DemoCard(
          title: 'BcFormBuilder',
          description: 'Visual form view.json builder. Drag fields, edit properties, preview JSON.',
          child: SizedBox(
            height: 460,
            child: BcFormBuilder(
              viewName: 'sale_order_form',
              model: 'sale.order',
              title: 'Sales Order Form',
              fields: _formFields,
              onChange: (fields) => setState(() => _formFields = fields),
              onSave: (viewJson) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Saved: ${viewJson.name}'),
                    duration: const Duration(milliseconds: 900),
                  ),
                );
              },
            ),
          ),
        ),

        // -- BcSchemaBuilder --
        DemoCard(
          title: 'BcSchemaBuilder',
          description: 'Visual model.json builder. Define fields, relations, and constraints.',
          child: SizedBox(
            height: 460,
            child: BcSchemaBuilder(
              modelName: 'custom_invoice',
              module: 'custom',
              label: 'Custom Invoice',
              fields: _schemaFields,
              onChange: (fields) => setState(() => _schemaFields = fields),
              onSave: (modelJson) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Saved: ${modelJson.name}'),
                    duration: const Duration(milliseconds: 900),
                  ),
                );
              },
            ),
          ),
        ),

        // -- BcWorkflowBuilder --
        DemoCard(
          title: 'BcWorkflowBuilder',
          description: 'Visual process.json builder. Drag steps, wire transitions, toggle DAG mode.',
          child: SizedBox(
            height: 460,
            child: BcWorkflowBuilder(
              processName: 'invoice_workflow',
              runtime: 'process',
              steps: _steps,
              transitions: _transitions,
              onChange: (steps, transitions) => setState(() {
                _steps = steps;
                _transitions = transitions;
              }),
              onSave: (processJson) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Saved: ${processJson.name}'),
                    duration: const Duration(milliseconds: 900),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
