import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_box.dart';
import 'package:bc_ui_flutter/src/theme/bc_theme.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 400,
          child: Align(
            alignment: Alignment.topLeft,
            child: child,
          ),
        ),
      ),
    );
  }

  testWidgets('BcBox applies token-based padding, margin, and border (VAL-M1-013)', (tester) async {
    await tester.pumpWidget(harness(
      BcBox(
        padding: 12,
        margin: 8,
        border: true,
        child: Container(
          key: const ValueKey('inner'),
          width: 50,
          height: 50,
          color: Colors.red,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('inner')), findsOneWidget);

    final containerRect = tester.getRect(find.byType(Container).first);
    final innerRect = tester.getRect(find.byKey(const ValueKey('inner')));

    expect(innerRect.left, closeTo(containerRect.left + 12, 1.0),
        reason: 'child should be inset by padding from the left');
    expect(innerRect.top, closeTo(containerRect.top + 12, 1.0),
        reason: 'child should be inset by padding from the top');

    expect(containerRect.left, closeTo(8, 1.0),
        reason: 'margin should offset box from the top-left of parent');
    expect(containerRect.top, closeTo(8, 1.0),
        reason: 'margin should offset box from the top-left of parent');

    expect(find.byType(BoxBorder), findsNothing);
    expect(find.byType(Border), findsNothing);
    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.border, isNotNull,
        reason: 'border should be set on the decoration');
  });

  testWidgets('BcBox background color resolves from BcTheme tokens (VAL-M1-014)', (tester) async {
    await tester.pumpWidget(harness(
      const BcBox(
        backgroundColor: BcBoxColorToken.surface,
        child: Text('content'),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('content'), findsOneWidget);

    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, isNotNull,
        reason: 'background color should be set');

    await tester.pumpWidget(harness(
      const BcBox(
        backgroundColor: BcBoxColorToken.primary,
        child: Text('content2'),
      ),
    ));
    await tester.pumpAndSettle();

    final container2 = tester.widget<Container>(find.byType(Container).first);
    final decoration2 = container2.decoration as BoxDecoration;
    expect(decoration2.color, equals(BcTheme.primary),
        reason: 'primary token should resolve to BcTheme.primary color');
  });

  testWidgets('BcBox borderRadius clips children when clipBehavior is set (VAL-M1-015)', (tester) async {
    await tester.pumpWidget(harness(
      BcBox(
        borderRadius: 20,
        clipBehavior: Clip.antiAlias,
        child: Container(
          key: const ValueKey('wide'),
          width: 200,
          height: 200,
          color: Colors.blue,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ClipRRect), findsOneWidget);

    final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
    expect(clipRRect.borderRadius, isNotNull);
    expect(clipRRect.clipBehavior, Clip.antiAlias);

    await tester.pumpWidget(harness(
      BcBox(
        borderRadius: 20,
        clipBehavior: Clip.none,
        child: Container(
          key: const ValueKey('wide2'),
          width: 200,
          height: 200,
          color: Colors.blue,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ClipRRect), findsNothing,
        reason: 'Clip.none should not produce a ClipRRect');
  });

  testWidgets('BcBox renders empty box without assertion (VAL-M1-016)', (tester) async {
    await tester.pumpWidget(harness(
      const BcBox(),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(BcBox), findsOneWidget);
  });
}
