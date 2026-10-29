import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bc_ui_flutter/src/renderer/bc_renderer.dart';
import 'package:bc_ui_flutter/src/schema/ui_schema.dart';

/// Regression tests for grid layout at the renderer seam.
///
/// A `grid` schema holds `detail` / `form` children whose natural height
/// depends on how many fields they contain. The renderer must size each cell
/// from its content, not from a fixed aspect ratio, otherwise a `detail` with
/// three or more fields overflows its cell and Flutter paints the yellow-and-
/// black overflow bar (as seen in the Block Catalog demo).
///
/// The Sales Order schema in the demo is exactly this shape:
///   section -> grid(columns: 2) -> [detail(3 fields), detail(4 fields)]
UiSchema _detail(String name, String title, int fieldCount) => UiSchema(
      type: UiSchemaKind.detail,
      name: name,
      title: title,
      fields: [
        for (var i = 0; i < fieldCount; i++)
          FieldNode(name: '${name}_f$i', label: 'Field $i'),
      ],
    );

UiSchema _gridWithTallDetails() => UiSchema(
      type: UiSchemaKind.grid,
      name: 'order-header',
      columns: 2,
      sections: [
        _detail('customer', 'Customer', 3),
        _detail('summary', 'Order Summary', 4),
      ],
    );

/// Pumps [schema] and returns the number of layout-overflow errors raised.
///
/// The overflow bar is reported through `FlutterError.onError`, not thrown,
/// so a plain `pumpWidget` would silently pass.
Future<int> _countOverflows(
  WidgetTester tester,
  UiSchema schema, {
  Size surface = const Size(1024, 2000),
}) async {
  final overflows = <String>[];
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    final text = details.exceptionAsString();
    if (text.contains('overflowed')) overflows.add(text);
  };

  tester.view.physicalSize = surface;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  try {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BcRenderer(props: BcRendererProps(schema: schema)),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  } finally {
    FlutterError.onError = original;
  }

  return overflows.length;
}

void main() {
  group('grid cells size to their content', () {
    testWidgets('two details with 3 and 4 fields do not overflow',
        (tester) async {
      final count = await _countOverflows(tester, _gridWithTallDetails());
      expect(count, 0);
    });

    testWidgets('no overflow at a narrow surface', (tester) async {
      final count = await _countOverflows(
        tester,
        _gridWithTallDetails(),
        surface: const Size(600, 1600),
      );
      expect(count, 0);
    });

    testWidgets('no overflow with a single tall child', (tester) async {
      final count = await _countOverflows(
        tester,
        UiSchema(
          type: UiSchemaKind.grid,
          columns: 2,
          sections: [_detail('only', 'Only', 6)],
        ),
      );
      expect(count, 0);
    });

    testWidgets('uneven field counts still align without overflow',
        (tester) async {
      final count = await _countOverflows(
        tester,
        UiSchema(
          type: UiSchemaKind.grid,
          columns: 3,
          sections: [
            _detail('a', 'A', 1),
            _detail('b', 'B', 5),
            _detail('c', 'C', 2),
          ],
        ),
      );
      expect(count, 0);
    });
  });

  group('grid structure is preserved', () {
    testWidgets('still lays children out in rows of `columns`', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BcRenderer(
                props: BcRendererProps(
                  schema: UiSchema(
                    type: UiSchemaKind.grid,
                    columns: 2,
                    sections: [
                      _detail('a', 'A', 1),
                      _detail('b', 'B', 1),
                      _detail('c', 'C', 1),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // A and B share the first row; C starts a new row below.
      final a = tester.getTopLeft(find.text('A')).dy;
      final b = tester.getTopLeft(find.text('B')).dy;
      final c = tester.getTopLeft(find.text('C')).dy;

      expect(b, equals(a));
      expect(c, greaterThan(a));

      // A and B sit side by side; C is under A.
      final ax = tester.getTopLeft(find.text('A')).dx;
      final bx = tester.getTopLeft(find.text('B')).dx;
      final cx = tester.getTopLeft(find.text('C')).dx;
      expect(bx, greaterThan(ax));
      expect(cx, equals(ax));
    });

    testWidgets('title and description render above the grid', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BcRenderer(
                props: BcRendererProps(
                  schema: UiSchema(
                    type: UiSchemaKind.grid,
                    title: 'Header',
                    description: 'Desc',
                    columns: 2,
                    sections: [_detail('a', 'A', 1)],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Desc'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Header')).dy,
        lessThan(tester.getTopLeft(find.text('A')).dy),
      );
    });

    testWidgets('empty grid renders nothing without throwing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcRenderer(
              props: BcRendererProps(
                schema: const UiSchema(type: UiSchemaKind.grid, columns: 2),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
