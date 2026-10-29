import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_favorites.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/theme/bc_theme.dart';

void main() {
  Widget harness(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  group('VAL-M7-018 — BcFavorites renders toggle button with active/inactive state', () {
    testWidgets('renders inactive star by default', (tester) async {
      await tester.pumpWidget(harness(
        const BcFavorites(),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_favorites_inactive')), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });

    testWidgets('renders active star when defaultValue is true', (tester) async {
      await tester.pumpWidget(harness(
        const BcFavorites(defaultValue: true),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_favorites_active')), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('tapping toggle emits boolean with meta', (tester) async {
      bool? capturedValue;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcFavorites(
          defaultValue: false,
          onValueChange: (value, meta) {
            capturedValue = value;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_favorites_inactive')));
      await tester.pumpAndSettle();

      expect(capturedValue, true);
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, BcChangeReason.select);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets('tapping active toggle emits deselect reason', (tester) async {
      bool? capturedValue;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcFavorites(
          defaultValue: true,
          onValueChange: (value, meta) {
            capturedValue = value;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_favorites_active')));
      await tester.pumpAndSettle();

      expect(capturedValue, false);
      expect(capturedMeta!.reason, BcChangeReason.deselect);
    });

    testWidgets('active state renders with distinct color (warning token)', (tester) async {
      await tester.pumpWidget(harness(
        const BcFavorites(defaultValue: true),
      ));
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.color, BcTheme.warning);
    });

    testWidgets('inactive state renders with mutedForeground color', (tester) async {
      await tester.pumpWidget(harness(
        const BcFavorites(defaultValue: false),
      ));
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.star_border));
      expect(icon.color, BcTheme.mutedForeground);
    });
  });

  group('VAL-M7-019 — BcFavorites controlled mode does not auto-toggle', () {
    testWidgets('controlled value stays the same after tap', (tester) async {
      await tester.pumpWidget(harness(
        const BcFavorites(value: false),
      ));
      await tester.pumpAndSettle();

      // Tap the button
      await tester.tap(find.byKey(const Key('bc_favorites_inactive')));
      await tester.pumpAndSettle();

      // In controlled mode, the visual state should not auto-flip
      expect(find.byKey(const Key('bc_favorites_inactive')), findsOneWidget);
      expect(find.byKey(const Key('bc_favorites_active')), findsNothing);
    });

    testWidgets('controlled mode callback still fires with correct value', (tester) async {
      bool? capturedValue;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcFavorites(
          value: false,
          onValueChange: (value, meta) {
            capturedValue = value;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_favorites_inactive')));
      await tester.pumpAndSettle();

      expect(capturedValue, true);
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, BcChangeReason.select);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets('parent updating controlled value changes visual state', (tester) async {
      bool controlledValue = false;

      await tester.pumpWidget(harness(
        BcFavorites(value: controlledValue),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_favorites_inactive')), findsOneWidget);

      controlledValue = true;
      await tester.pumpWidget(harness(
        BcFavorites(value: controlledValue),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_favorites_active')), findsOneWidget);
    });
  });
}
