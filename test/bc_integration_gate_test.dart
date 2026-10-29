import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

void main() {
  group('VAL-CROSS-001: Barrel exports all 8 P1 widgets', () {
    test('BcDisclosure is exported from barrel', () {
      expect(BcDisclosure, isNotNull);
    });

    test('BcPortal is exported from barrel', () {
      expect(BcPortal, isNotNull);
    });

    test('BcFieldDuration is exported from barrel', () {
      expect(BcFieldDuration, isNotNull);
    });

    test('BcFieldTableSelect is exported from barrel', () {
      expect(BcFieldTableSelect, isNotNull);
    });

    test('BcFieldMorph is exported from barrel', () {
      expect(BcFieldMorph, isNotNull);
    });

    test('BcFieldDynLink is exported from barrel', () {
      expect(BcFieldDynLink, isNotNull);
    });

    test('BcLookupModal is exported from barrel', () {
      expect(BcLookupModal, isNotNull);
    });

    test('BcViewGantt is exported from barrel', () {
      expect(BcViewGantt, isNotNull);
    });
  });

  group('VAL-CROSS-001: Barrel exports all P1 typed classes and enums', () {
    test('BcFieldTableSelectColumn is exported', () {
      expect(BcFieldTableSelectColumn, isNotNull);
    });

    test('BcFieldMorphOption is exported', () {
      expect(BcFieldMorphOption, isNotNull);
    });

    test('BcFieldMorphType is exported', () {
      expect(BcFieldMorphType, isNotNull);
    });

    test('BcFieldMorphValue is exported', () {
      expect(BcFieldMorphValue, isNotNull);
    });

    test('BcDynLinkModel is exported', () {
      expect(BcDynLinkModel, isNotNull);
    });

    test('BcDynLinkValue is exported', () {
      expect(BcDynLinkValue, isNotNull);
    });

    test('BcDynLinkRecord is exported', () {
      expect(BcDynLinkRecord, isNotNull);
    });

    test('BcLookupModalColumn is exported', () {
      expect(BcLookupModalColumn, isNotNull);
    });

    test('BcGanttTask is exported', () {
      expect(BcGanttTask, isNotNull);
    });

    test('BcGanttLink is exported', () {
      expect(BcGanttLink, isNotNull);
    });

    test('BcGanttTaskType enum is exported', () {
      expect(BcGanttTaskType.values.length, 3);
    });

    test('BcGanttZoomLevel enum is exported', () {
      expect(BcGanttZoomLevel.values.length, 4);
    });

    test('BcPortalAnimation enum is exported', () {
      expect(BcPortalAnimation.values.length, 3);
    });
  });

  group('VAL-CROSS-006: P1 widgets use BcChangeHandler pattern', () {
    testWidgets('BcDisclosure onOpenChange fires with BcChangeMeta', (tester) async {
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcDisclosure(
            title: 'Test',
            onOpenChange: (v, m) => capturedMeta = m,
            child: const Text('Body'),
          ),
        ),
      ));

      await tester.tap(find.text('Test'));
      await tester.pump();

      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, isA<BcChangeReason>());
    });

    testWidgets('BcFieldDuration onValueChange fires with BcChangeMeta', (tester) async {
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcFieldDuration(
            name: 'dur',
            onValueChange: (v, m) => capturedMeta = m,
          ),
        ),
      ));

      await tester.tap(find.byIcon(Icons.arrow_drop_up).first);
      await tester.pump();

      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, isA<BcChangeReason>());
    });

    testWidgets('BcFieldTableSelect onValueChange fires with BcChangeMeta', (tester) async {
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcFieldTableSelect(
            columns: const [
              BcFieldTableSelectColumn(key: 'name', label: 'Name'),
            ],
            data: const [
              {'id': '1', 'name': 'Alice'},
            ],
            titleField: 'name',
            onValueChange: (v, m) => capturedMeta = m,
          ),
        ),
      ));

      await tester.tap(find.text('Alice'));
      await tester.pump();

      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, isA<BcChangeReason>());
    });

    testWidgets('BcFieldMorph onValueChange fires with BcChangeMeta', (tester) async {
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcFieldMorph(
            types: const [
              BcFieldMorphType(value: 'text', label: 'Text', widget: 'text'),
            ],
            onValueChange: (v, m) => capturedMeta = m,
          ),
        ),
      ));

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Text').last);
      await tester.pumpAndSettle();

      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, isA<BcChangeReason>());
    });

    testWidgets('BcFieldDynLink onValueChange fires with BcChangeMeta', (tester) async {
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcFieldDynLink(
            models: const [
              BcDynLinkModel(model: 'crm.contact', label: 'Contact'),
            ],
            dataFetcher: (model, query) async => [],
            onValueChange: (v, m) => capturedMeta = m,
          ),
        ),
      ));

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Contact').last);
      await tester.pumpAndSettle();

      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, isA<BcChangeReason>());
    });

    testWidgets('BcLookupModal onValueChange fires with BcChangeMeta', (tester) async {
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcLookupModal(
            open: true,
            title: 'Pick',
            columns: const [
              BcLookupModalColumn(key: 'name', label: 'Name'),
            ],
            data: const [
              {'id': '1', 'name': 'Alice'},
            ],
            onValueChange: (v, m) => capturedMeta = m,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alice'));
      await tester.pump();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, isA<BcChangeReason>());
    });

    testWidgets('BcLookupModal onOpenChange fires with BcChangeMeta', (tester) async {
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcLookupModal(
            open: true,
            title: 'Pick',
            columns: const [
              BcLookupModalColumn(key: 'name', label: 'Name'),
            ],
            data: const [
              {'id': '1', 'name': 'Alice'},
            ],
            onOpenChange: (v, m) => capturedMeta = m,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, isA<BcChangeReason>());
    });

    testWidgets('BcPortal onRequestClose fires with BcChangeMeta', (tester) async {
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcPortal(
            open: true,
            onRequestClose: (m) => capturedMeta = m,
            child: const Text('Overlay'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, isA<BcChangeReason>());
    });
  });

  group('VAL-CROSS-007: P1 widgets use correct BcChangeReason values', () {
    testWidgets('BcDisclosure emits toggle reason on tap', (tester) async {
      BcChangeReason? capturedReason;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcDisclosure(
            title: 'Details',
            onOpenChange: (v, m) => capturedReason = m.reason,
            child: const Text('Body'),
          ),
        ),
      ));

      await tester.tap(find.text('Details'));
      await tester.pump();

      expect(capturedReason, BcChangeReason.toggle);
    });

    testWidgets('BcDisclosure emits programmatic reason on external open change', (tester) async {
      BcChangeReason? capturedReason;
      var isOpen = false;

      Widget buildHarness() => MaterialApp(
            home: Scaffold(
              body: BcDisclosure(
                open: isOpen,
                title: 'Details',
                onOpenChange: (v, m) => capturedReason = m.reason,
                child: const Text('Body'),
              ),
            ),
          );

      await tester.pumpWidget(buildHarness());
      isOpen = true;
      await tester.pumpWidget(buildHarness());

      expect(capturedReason, BcChangeReason.programmatic);
    });

    testWidgets('BcFieldDuration emits increment reason on up button', (tester) async {
      BcChangeReason? capturedReason;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcFieldDuration(
            name: 'dur',
            value: 0,
            onValueChange: (v, m) => capturedReason = m.reason,
          ),
        ),
      ));

      await tester.tap(find.byIcon(Icons.arrow_drop_up).first);
      await tester.pump();

      expect(capturedReason, BcChangeReason.increment);
    });

    testWidgets('BcFieldDuration emits decrement reason on down button', (tester) async {
      BcChangeReason? capturedReason;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcFieldDuration(
            name: 'dur',
            value: 120,
            onValueChange: (v, m) => capturedReason = m.reason,
          ),
        ),
      ));

      await tester.tap(find.byIcon(Icons.arrow_drop_down).first);
      await tester.pump();

      expect(capturedReason, BcChangeReason.decrement);
    });

    testWidgets('BcFieldDuration emits clear reason on clear button', (tester) async {
      BcChangeReason? capturedReason;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcFieldDuration(
            name: 'dur',
            value: 60,
            clearable: true,
            onValueChange: (v, m) => capturedReason = m.reason,
          ),
        ),
      ));

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(capturedReason, BcChangeReason.clear);
    });

    testWidgets('BcFieldTableSelect emits select reason on row tap', (tester) async {
      BcChangeReason? capturedReason;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcFieldTableSelect(
            columns: const [
              BcFieldTableSelectColumn(key: 'name', label: 'Name'),
            ],
            data: const [
              {'id': '1', 'name': 'Alice'},
            ],
            titleField: 'name',
            onValueChange: (v, m) => capturedReason = m.reason,
          ),
        ),
      ));

      await tester.tap(find.text('Alice'));
      await tester.pump();

      expect(capturedReason, BcChangeReason.select);
    });

    testWidgets('BcFieldTableSelect emits deselect reason on re-tap in multiple mode', (tester) async {
      BcChangeReason? capturedReason;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcFieldTableSelect(
            columns: const [
              BcFieldTableSelectColumn(key: 'name', label: 'Name'),
            ],
            data: const [
              {'id': '1', 'name': 'Alice'},
            ],
            multiple: true,
            titleField: 'name',
            onValueChange: (v, m) => capturedReason = m.reason,
          ),
        ),
      ));

      await tester.tap(find.text('Alice'));
      await tester.pump();
      await tester.tap(find.text('Alice'));
      await tester.pump();

      expect(capturedReason, BcChangeReason.deselect);
    });

    testWidgets('BcFieldMorph emits typeChange reason on type change', (tester) async {
      BcChangeReason? capturedReason;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcFieldMorph(
            types: const [
              BcFieldMorphType(value: 'text', label: 'Text', widget: 'text'),
              BcFieldMorphType(value: 'number', label: 'Number', widget: 'number'),
            ],
            onValueChange: (v, m) => capturedReason = m.reason,
          ),
        ),
      ));

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Text').last);
      await tester.pumpAndSettle();

      expect(capturedReason, BcChangeReason.typeChange);
    });

    testWidgets('BcFieldMorph emits clear reason on clear button', (tester) async {
      BcChangeReason? capturedReason;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcFieldMorph(
            value: const BcFieldMorphValue(type: 'text', value: 'hello'),
            types: const [
              BcFieldMorphType(value: 'text', label: 'Text', widget: 'text'),
            ],
            clearable: true,
            onValueChange: (v, m) => capturedReason = m.reason,
          ),
        ),
      ));

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(capturedReason, BcChangeReason.clear);
    });

    testWidgets('BcFieldDynLink emits modelChange reason on model change', (tester) async {
      BcChangeReason? capturedReason;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcFieldDynLink(
            models: const [
              BcDynLinkModel(model: 'crm.contact', label: 'Contact'),
              BcDynLinkModel(model: 'crm.company', label: 'Company'),
            ],
            dataFetcher: (model, query) async => [],
            onValueChange: (v, m) => capturedReason = m.reason,
          ),
        ),
      ));

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Contact').last);
      await tester.pumpAndSettle();

      expect(capturedReason, BcChangeReason.modelChange);
    });

    testWidgets('BcLookupModal emits confirm reason on confirm', (tester) async {
      BcChangeReason? capturedReason;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcLookupModal(
            open: true,
            title: 'Pick',
            columns: const [
              BcLookupModalColumn(key: 'name', label: 'Name'),
            ],
            data: const [
              {'id': '1', 'name': 'Alice'},
            ],
            onValueChange: (v, m) => capturedReason = m.reason,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alice'));
      await tester.pump();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(capturedReason, BcChangeReason.confirm);
    });

    testWidgets('BcLookupModal emits cancel reason on cancel', (tester) async {
      BcChangeReason? capturedReason;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcLookupModal(
            open: true,
            title: 'Pick',
            columns: const [
              BcLookupModalColumn(key: 'name', label: 'Name'),
            ],
            data: const [
              {'id': '1', 'name': 'Alice'},
            ],
            onOpenChange: (v, m) => capturedReason = m.reason,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(capturedReason, BcChangeReason.cancel);
    });

    testWidgets('BcLookupModal emits escape reason on Escape key', (tester) async {
      BcChangeReason? capturedReason;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcLookupModal(
            open: true,
            title: 'Pick',
            columns: const [
              BcLookupModalColumn(key: 'name', label: 'Name'),
            ],
            data: const [
              {'id': '1', 'name': 'Alice'},
            ],
            onOpenChange: (v, m) => capturedReason = m.reason,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(capturedReason, BcChangeReason.escape);
    });

    testWidgets('BcPortal emits escape reason on Escape key', (tester) async {
      BcChangeReason? capturedReason;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcPortal(
            open: true,
            onRequestClose: (m) => capturedReason = m?.reason,
            child: const Text('Overlay'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(capturedReason, BcChangeReason.escape);
    });
  });

  group('VAL-CROSS-012: No widget leaks controllers or overlay entries in dispose', () {
    testWidgets('BcDisclosure disposes controllers on unmount', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: BcDisclosure(
            title: 'Test',
            child: Text('Body'),
          ),
        ),
      ));

      await tester.tap(find.text('Test'));
      await tester.pump();

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SizedBox.shrink()),
      ));

      expect(tester.takeException(), isNull);
    });

    testWidgets('BcPortal removes overlay entry on dispose', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: BcPortal(
            open: true,
            child: Text('Overlay'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Overlay'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SizedBox.shrink()),
      ));

      expect(tester.takeException(), isNull);
    });

    testWidgets('BcFieldDuration disposes text controllers on unmount', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: BcFieldDuration(name: 'dur', value: 3600),
        ),
      ));

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SizedBox.shrink()),
      ));

      expect(tester.takeException(), isNull);
    });

    testWidgets('BcFieldTableSelect disposes search controller on unmount', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: BcFieldTableSelect(
            columns: [
              BcFieldTableSelectColumn(key: 'name', label: 'Name'),
            ],
            data: [
              {'id': '1', 'name': 'Alice'},
            ],
            searchable: true,
          ),
        ),
      ));

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SizedBox.shrink()),
      ));

      expect(tester.takeException(), isNull);
    });

    testWidgets('BcFieldDynLink disposes timer and controllers on unmount', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcFieldDynLink(
            models: const [
              BcDynLinkModel(model: 'crm.contact', label: 'Contact'),
            ],
            dataFetcher: (model, query) async => [],
          ),
        ),
      ));

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SizedBox.shrink()),
      ));

      expect(tester.takeException(), isNull);
    });

    testWidgets('BcLookupModal disposes controllers on unmount', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: BcLookupModal(
            open: true,
            title: 'Pick',
            columns: [
              BcLookupModalColumn(key: 'name', label: 'Name'),
            ],
            data: [
              {'id': '1', 'name': 'Alice'},
            ],
            searchable: true,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SizedBox.shrink()),
      ));

      expect(tester.takeException(), isNull);
    });

    testWidgets('BcViewGantt disposes scroll controllers on unmount', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: BcViewGantt(
            tasks: [
              BcGanttTask(id: 't1', label: 'Task 1', start: 0, duration: 5),
            ],
          ),
        ),
      ));

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SizedBox.shrink()),
      ));

      expect(tester.takeException(), isNull);
    });
  });
}
