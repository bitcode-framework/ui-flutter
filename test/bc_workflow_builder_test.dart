// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_workflow_builder.dart';

void main() {
  group('BcWorkflowStepType', () {
    test('all 18 step types have unique ids', () {
      final ids = BcWorkflowStepType.values.map((e) => e.id).toSet();
      expect(ids.length, 18);
    });

    test('fromString round-trips all types', () {
      for (final st in BcWorkflowStepType.values) {
        expect(BcWorkflowStepType.fromString(st.id), st);
      }
    });

    test('fromString defaults to query for unknown', () {
      expect(BcWorkflowStepType.fromString('unknown'), BcWorkflowStepType.query);
    });

    test('needsModel returns true for data step types', () {
      expect(BcWorkflowStepType.query.needsModel, isTrue);
      expect(BcWorkflowStepType.create.needsModel, isTrue);
      expect(BcWorkflowStepType.update.needsModel, isTrue);
      expect(BcWorkflowStepType.delete.needsModel, isTrue);
      expect(BcWorkflowStepType.upsert.needsModel, isTrue);
      expect(BcWorkflowStepType.count.needsModel, isTrue);
      expect(BcWorkflowStepType.sum.needsModel, isTrue);
      expect(BcWorkflowStepType.ifCondition.needsModel, isFalse);
      expect(BcWorkflowStepType.emit.needsModel, isFalse);
    });

    test('if id is correct', () {
      expect(BcWorkflowStepType.ifCondition.id, 'if');
    });

    test('switch id is correct', () {
      expect(BcWorkflowStepType.switchType.id, 'switch');
    });
  });

  group('BcProcessJson', () {
    test('toJson produces valid sequential process.json structure', () {
      final processJson = BcProcessJson(
        name: 'confirm_order',
        steps: [
          {'name': 'validate', 'type': 'validate'},
          {'name': 'create', 'type': 'create', 'model': 'order'},
        ],
      );

      final json = processJson.toJson();
      expect(json['name'], 'confirm_order');
      expect(json['steps'], isA<List>());
      expect((json['steps'] as List).length, 2);
    });

    test('toJson produces valid DAG process.json structure', () {
      final processJson = BcProcessJson(
        name: 'approval_flow',
        nodes: {
          'start': {'type': 'query', 'model': 'invoice'},
          'approve': {'type': 'update', 'model': 'invoice'},
        },
        edges: [
          {'from': 'start', 'to': 'approve'},
        ],
      );

      final json = processJson.toJson();
      expect(json['name'], 'approval_flow');
      expect(json['nodes'], isA<Map>());
      expect(json['edges'], isA<List>());
      expect((json['edges'] as List).length, 1);
    });

    test('toJsonString produces indented JSON', () {
      final processJson = BcProcessJson(
        name: 'test',
        steps: [
          {'name': 'step1', 'type': 'query'},
        ],
      );

      final str = processJson.toJsonString();
      expect(str, contains('"name"'));
      expect(str, contains('"test"'));
      expect(str, contains('"steps"'));
    });

    test('toJson includes runtime when set', () {
      final processJson = BcProcessJson(
        name: 'test',
        runtime: 'goja',
        steps: [],
      );

      final json = processJson.toJson();
      expect(json['runtime'], 'goja');
    });

    test('toJson omits empty runtime', () {
      final processJson = BcProcessJson(
        name: 'test',
        steps: [],
      );

      final json = processJson.toJson();
      expect(json.containsKey('runtime'), isFalse);
    });
  });

  group('BcWorkflowStep', () {
    test('copyWith updates specified fields', () {
      final step = BcWorkflowStep(
        id: '1',
        name: 'query_1',
        type: BcWorkflowStepType.query,
        x: 10,
        y: 20,
      );

      final updated = step.copyWith(label: 'My Step', model: 'contact');
      expect(updated.label, 'My Step');
      expect(updated.model, 'contact');
      expect(updated.name, 'query_1');
      expect(updated.type, BcWorkflowStepType.query);
    });
  });

  group('BcWorkflowTransition', () {
    test('copyWith updates specified fields', () {
      final tr = BcWorkflowTransition(
        id: 'edge_1',
        from: 'step_a',
        to: 'step_b',
      );

      final updated = tr.copyWith(condition: 'ctx.valid == true', label: 'yes');
      expect(updated.condition, 'ctx.valid == true');
      expect(updated.label, 'yes');
      expect(updated.from, 'step_a');
      expect(updated.to, 'step_b');
    });
  });

  group('BcWorkflowValidationResult', () {
    test('fromJson parses valid result', () {
      final json = {
        'valid': true,
        'errors': [],
        'warnings': [],
      };

      final result = BcWorkflowValidationResult.fromJson(json);
      expect(result.valid, isTrue);
      expect(result.errors, isEmpty);
      expect(result.warnings, isEmpty);
    });

    test('fromJson parses invalid result with errors', () {
      final json = {
        'valid': false,
        'errors': [
          {'field': 'name', 'message': 'Process name is required'},
        ],
        'warnings': [],
      };

      final result = BcWorkflowValidationResult.fromJson(json);
      expect(result.valid, isFalse);
      expect(result.errors.length, 1);
      expect(result.errors.first.field, 'name');
      expect(result.errors.first.message, 'Process name is required');
    });
  });

  group('BcWorkflowBuilder widget', () {
    testWidgets('renders with key bc-workflow-builder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcWorkflowBuilder(
              processName: 'my_process',
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('bc-workflow-builder')), findsOneWidget);
    });

    testWidgets('shows palette with step types', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcWorkflowBuilder(processName: 'my_process'),
          ),
        ),
      );

      expect(find.byKey(const Key('bc-workflow-builder-palette')), findsOneWidget);
      expect(find.byKey(const Key('bc-workflow-builder-palette-item-call')),
          findsOneWidget);
      expect(find.byKey(const Key('bc-workflow-builder-palette-item-if')),
          findsOneWidget);
      expect(find.byKey(const Key('bc-workflow-builder-palette-item-query')),
          findsOneWidget);
      expect(find.byKey(const Key('bc-workflow-builder-palette-item-emit')),
          findsOneWidget);
      expect(find.byKey(const Key('bc-workflow-builder-palette-item-http')),
          findsOneWidget);
    });

    testWidgets('shows empty state when no steps', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcWorkflowBuilder(processName: 'my_process'),
          ),
        ),
      );

      expect(find.byKey(const Key('bc-workflow-builder-empty')), findsOneWidget);
    });

    testWidgets('shows toolbar with validate and save buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcWorkflowBuilder(processName: 'my_process'),
          ),
        ),
      );

      expect(find.byKey(const Key('bc-workflow-builder-validate')), findsOneWidget);
      expect(find.byKey(const Key('bc-workflow-builder-save')), findsOneWidget);
    });

    testWidgets('shows DAG mode toggle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcWorkflowBuilder(processName: 'my_process'),
          ),
        ),
      );

      expect(find.byKey(const Key('bc-workflow-builder-mode')), findsOneWidget);
    });

    testWidgets('tapping a palette item adds a step', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcWorkflowBuilder(processName: 'my_process'),
          ),
        ),
      );

      expect(find.byKey(const Key('bc-workflow-builder-empty')), findsOneWidget);

      await tester.tap(
          find.byKey(const Key('bc-workflow-builder-palette-item-query')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-workflow-builder-empty')), findsNothing);
      expect(find.byKey(const Key('bc-workflow-builder-canvas')), findsOneWidget);
    });

    testWidgets('JSON tab shows process.json output', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcWorkflowBuilder(processName: 'my_process'),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('bc-workflow-builder-tab-json')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-workflow-builder-json')), findsOneWidget);
      expect(find.byKey(const Key('bc-workflow-builder-json-output')),
          findsOneWidget);
    });

    testWidgets('onChange callback fires when step is added', (tester) async {
      List<BcWorkflowStep>? changedSteps;
      List<BcWorkflowTransition>? changedTransitions;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcWorkflowBuilder(
              processName: 'my_process',
              onChange: (steps, transitions) {
                changedSteps = steps;
                changedTransitions = transitions;
              },
            ),
          ),
        ),
      );

      await tester.tap(
          find.byKey(const Key('bc-workflow-builder-palette-item-emit')));
      await tester.pumpAndSettle();

      expect(changedSteps, isNotNull);
      expect(changedSteps!.length, 1);
      expect(changedSteps!.first.type, BcWorkflowStepType.emit);
      expect(changedTransitions, isNotNull);
      expect(changedTransitions!.length, 0);
    });

    testWidgets('renders provided steps from props', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(
            body: BcWorkflowBuilder(
              processName: 'my_process',
              steps: [
                BcWorkflowStep(
                  id: 's1',
                  name: 'fetch_data',
                  label: 'Fetch Data',
                  type: BcWorkflowStepType.query,
                  x: 40,
                  y: 40,
                  model: 'invoice',
                ),
                BcWorkflowStep(
                  id: 's2',
                  name: 'check_amount',
                  label: 'Check Amount',
                  type: BcWorkflowStepType.ifCondition,
                  x: 220,
                  y: 40,
                  condition: 'ctx.amount > 1000',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Fetch Data'), findsOneWidget);
      expect(find.text('Check Amount'), findsOneWidget);
      expect(find.byKey(const Key('bc-workflow-builder-step-s1')), findsOneWidget);
      expect(find.byKey(const Key('bc-workflow-builder-step-s2')), findsOneWidget);
    });

    testWidgets('selecting a step shows property panel', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcWorkflowBuilder(
              processName: 'my_process',
              steps: [
                BcWorkflowStep(
                  id: 's1',
                  name: 'fetch_data',
                  label: 'Fetch Data',
                  type: BcWorkflowStepType.query,
                  x: 40,
                  y: 40,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('bc-workflow-builder-step-s1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-workflow-builder-step-properties')),
          findsOneWidget);
      expect(find.byKey(const Key('bc-workflow-builder-prop-label')),
          findsOneWidget);
      expect(find.byKey(const Key('bc-workflow-builder-prop-name')),
          findsOneWidget);
      expect(find.byKey(const Key('bc-workflow-builder-prop-type')),
          findsOneWidget);
      expect(find.byKey(const Key('bc-workflow-builder-prop-model')),
          findsOneWidget);
    });

    testWidgets('validation status shows when validation prop is set',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcWorkflowBuilder(
              processName: 'my_process',
              validation: BcWorkflowValidationResult(
                valid: false,
                errors: [
                  BcWorkflowValidationIssue(
                      field: 'name', message: 'Process name required'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('bc-workflow-builder-validation-status')),
          findsOneWidget);
      expect(find.byKey(const Key('bc-workflow-builder-errors')), findsOneWidget);
      expect(find.textContaining('Process name required'), findsOneWidget);
    });

    testWidgets('tapping DAG mode toggles to DAG mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcWorkflowBuilder(processName: 'my_process'),
          ),
        ),
      );

      expect(find.text('Sequential'), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc-workflow-builder-mode')));
      await tester.pumpAndSettle();

      expect(find.text('DAG Mode'), findsOneWidget);
    });

    testWidgets('save is disabled when validation is invalid', (tester) async {
      var saved = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcWorkflowBuilder(
              processName: 'my_process',
              validation: BcWorkflowValidationResult(
                valid: false,
                errors: [
                  BcWorkflowValidationIssue(message: 'Error'),
                ],
              ),
              onSave: (_) {
                saved = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('bc-workflow-builder-save')));
      await tester.pumpAndSettle();

      expect(saved, isFalse);
    });
  });
}
