import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_avatar.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  testWidgets('BcAvatar renders fallback initials from alt when no src', (tester) async {
    await tester.pumpWidget(harness(const BcAvatar(alt: 'Alice')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc-avatar-fallback')), findsOneWidget);
    expect(find.text('A'), findsOneWidget,
        reason: 'fallback should be first char of alt uppercased');
    expect(find.byKey(const Key('bc-avatar-image')), findsNothing);
  });

  testWidgets('BcAvatar prefers fallback prop over alt initial', (tester) async {
    await tester.pumpWidget(harness(const BcAvatar(
      alt: 'Alice',
      fallback: 'AB',
    )));
    await tester.pumpAndSettle();

    expect(find.text('AB'), findsOneWidget,
        reason: 'explicit fallback prop should win over alt initial');
  });

  testWidgets('BcAvatar renders ? placeholder when no src, alt, or fallback', (tester) async {
    await tester.pumpWidget(harness(const BcAvatar()));
    await tester.pumpAndSettle();

    expect(find.text('?'), findsOneWidget,
        reason: 'empty avatar should render ? placeholder');
  });

  testWidgets('BcAvatar renders image widget when src is provided', (tester) async {
    await tester.pumpWidget(harness(const BcAvatar(
      src: 'https://example.com/a.png',
      alt: 'Alice',
    )));
    // Pump once (do not settle network image - it will not resolve in tests).
    await tester.pump();

    expect(find.byKey(const Key('bc-avatar-image')), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('BcAvatar falls back when src is empty string', (tester) async {
    await tester.pumpWidget(harness(const BcAvatar(
      src: '',
      alt: 'Bob',
    )));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc-avatar-fallback')), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.byKey(const Key('bc-avatar-image')), findsNothing);
  });

  testWidgets('BcAvatar size maps to diameter (sm < md < lg)', (tester) async {
    double sizeOf(BcComponentSize s) {
      final w = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byKey(const Key('bc-avatar-fallback')),
          matching: find.byType(SizedBox),
        ),
      );
      return w.width ?? 0;
    }

    await tester.pumpWidget(harness(const BcAvatar(alt: 'A', size: BcComponentSize.sm)));
    await tester.pumpAndSettle();
    final sm = sizeOf(BcComponentSize.sm);

    await tester.pumpWidget(harness(const BcAvatar(alt: 'A', size: BcComponentSize.md)));
    await tester.pumpAndSettle();
    final md = sizeOf(BcComponentSize.md);

    await tester.pumpWidget(harness(const BcAvatar(alt: 'A', size: BcComponentSize.lg)));
    await tester.pumpAndSettle();
    final lg = sizeOf(BcComponentSize.lg);

    expect(sm, 32.0);
    expect(md, 40.0);
    expect(lg, 48.0);
    expect(sm < md, isTrue);
    expect(md < lg, isTrue);
  });

  testWidgets('BcAvatar exposes semantics label', (tester) async {
    await tester.pumpWidget(harness(const BcAvatar(alt: 'Alice avatar')));
    await tester.pumpAndSettle();

    final semantics = tester.getSemantics(find.byType(BcAvatar));
    expect(semantics.label, 'Alice avatar',
        reason: 'avatar should expose alt as semantics label');
  });
}