import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_view_editor.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  List<BcViewEditorComponent> sampleComponents() => const [
        BcViewEditorComponent(id: 'c1', type: 'list', label: 'List View'),
        BcViewEditorComponent(id: 'c2', type: 'form', label: 'Form View'),
        BcViewEditorComponent(id: 'c3', type: 'chart', label: 'Chart View'),
      ];

  group('VAL-M5-027: Layout renders configured components in order', () {
    testWidgets('renders all components in declaration order', (tester) async {
      await tester.pumpWidget(harness(
        BcViewEditor(components: sampleComponents()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('List View'), findsOneWidget);
      expect(find.text('Form View'), findsOneWidget);
      expect(find.text('Chart View'), findsOneWidget);

      final firstLabel =
          tester.getCenter(find.byKey(const ValueKey<String>('ve-row-c1')));
      final secondLabel =
          tester.getCenter(find.byKey(const ValueKey<String>('ve-row-c2')));
      final thirdLabel =
          tester.getCenter(find.byKey(const ValueKey<String>('ve-row-c3')));

      expect(firstLabel.dy, lessThan(secondLabel.dy));
      expect(secondLabel.dy, lessThan(thirdLabel.dy));
    });

    testWidgets('renders the component type beneath each label', (tester) async {
      await tester.pumpWidget(harness(
        BcViewEditor(components: sampleComponents()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('list'), findsOneWidget);
      expect(find.text('form'), findsOneWidget);
      expect(find.text('chart'), findsOneWidget);
    });

    testWidgets('renders empty editor without error', (tester) async {
      await tester.pumpWidget(harness(
        const BcViewEditor(components: []),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('VAL-M5-028: Drag-drop reorders components and emits layout', () {
    testWidgets('reordering emits updated layout list and meta', (tester) async {
      List<BcViewEditorComponent>? capturedLayout;
      BcChangeMeta? capturedMeta;
      int callCount = 0;

      await tester.pumpWidget(harness(
        BcViewEditor(
          components: sampleComponents(),
          onLayoutChange: (components, meta) {
            capturedLayout = components;
            capturedMeta = meta;
            callCount++;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const ValueKey<String>('drag-handle-c1')),
        const Offset(0, 250),
      );
      await tester.pumpAndSettle();

      expect(callCount, greaterThanOrEqualTo(1));
      expect(capturedLayout, isNotNull);
      expect(capturedLayout!.length, 3);
      expect(capturedLayout![0].id, 'c2');
      expect(capturedLayout![1].id, 'c3');
      expect(capturedLayout![2].id, 'c1');
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets('reordering reflects in the rendered order', (tester) async {
      late void Function(void Function()) setStateProxy;
      List<BcViewEditorComponent> currentComponents = sampleComponents();

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            setStateProxy = setState;
            return harness(
              BcViewEditor(
                components: currentComponents,
                onLayoutChange: (components, meta) {
                  setStateProxy(() {
                    currentComponents = components;
                  });
                },
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const ValueKey<String>('drag-handle-c1')),
        const Offset(0, 250),
      );
      await tester.pumpAndSettle();

      final firstCenter =
          tester.getCenter(find.byKey(const ValueKey<String>('ve-row-c1')));
      final thirdCenter =
          tester.getCenter(find.byKey(const ValueKey<String>('ve-row-c3')));
      expect(firstCenter.dy, greaterThan(thirdCenter.dy));
    });
  });

  group('VAL-M5-029: Disabled editor prevents drag-drop', () {
    testWidgets('disabled editor does not emit layout change', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        BcViewEditor(
          components: sampleComponents(),
          disabled: true,
          onLayoutChange: (_, __) => callCount++,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('List View'), findsOneWidget);
      expect(find.byType(ReorderableListView), findsNothing);
      expect(callCount, 0);
    });

    testWidgets('disabled editor renders static list (no drag handle)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcViewEditor(
          components: sampleComponents(),
          disabled: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('List View'), findsOneWidget);
      expect(find.text('Form View'), findsOneWidget);
      expect(find.text('Chart View'), findsOneWidget);
      expect(find.byType(ReorderableListView), findsNothing);
    });

    testWidgets('disabled editor order matches current config', (tester) async {
      await tester.pumpWidget(harness(
        BcViewEditor(
          components: sampleComponents(),
          disabled: true,
        ),
      ));
      await tester.pumpAndSettle();

      final firstCenter =
          tester.getCenter(find.byKey(const ValueKey<String>('ve-row-c1')));
      final secondCenter =
          tester.getCenter(find.byKey(const ValueKey<String>('ve-row-c2')));
      final thirdCenter =
          tester.getCenter(find.byKey(const ValueKey<String>('ve-row-c3')));

      expect(firstCenter.dy, lessThan(secondCenter.dy));
      expect(secondCenter.dy, lessThan(thirdCenter.dy));
    });
  });
}
