import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_chip.dart';

void main() {
  group('BcChip', () {
    Widget buildHarness({
      required String label,
      BcChipVariant variant = BcChipVariant.defaultVariant,
      String? avatar,
      bool removable = false,
      bool disabled = false,
      bool? removed,
      bool defaultRemoved = false,
      BcChangeHandler<bool>? onRemove,
      VoidCallback? onClick,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BcChip(
            label: label,
            variant: variant,
            avatar: avatar,
            removable: removable,
            disabled: disabled,
            removed: removed,
            defaultRemoved: defaultRemoved,
            onRemove: onRemove,
            onClick: onClick,
          ),
        ),
      );
    }

    testWidgets('renders label (VAL-E2-001)', (tester) async {
      await tester.pumpWidget(buildHarness(label: 'TypeScript'));
      await tester.pumpAndSettle();
      expect(find.text('TypeScript'), findsOneWidget);
      expect(find.byKey(const Key('bc-chip-root')), findsOneWidget);
    });

    testWidgets('6 variants use distinct background tokens (VAL-E2-002)',
        (tester) async {
      Color extractBg() {
        final container = tester.widget<Container>(
          find.byKey(const Key('bc-chip-root')),
        );
        return (container.decoration as BoxDecoration).color!;
      }

      final bgs = <BcChipVariant, Color>{};
      for (final v in [
        BcChipVariant.defaultVariant,
        BcChipVariant.primary,
        BcChipVariant.success,
        BcChipVariant.warning,
        BcChipVariant.destructive,
        BcChipVariant.info,
      ]) {
        await tester.pumpWidget(buildHarness(label: 'x', variant: v));
        await tester.pumpAndSettle();
        bgs[v] = extractBg();
      }
      expect(bgs.values.toSet().length, 6, reason: 'each variant must use a distinct background');
    });

    testWidgets('removable=false hides the remove button (VAL-E2-003)',
        (tester) async {
      await tester.pumpWidget(buildHarness(label: 'No remove'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-chip-remove')), findsNothing);
    });

    testWidgets('removable=true + tap hides the chip + emits onRemove with pointer source (VAL-E2-004)',
        (tester) async {
      bool? removed;
      BcChangeMeta? meta;
      await tester.pumpWidget(buildHarness(
        label: 'Removable',
        removable: true,
        onRemove: (v, m) {
          removed = v;
          meta = m;
        },
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-chip-remove')), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc-chip-remove')));
      await tester.pumpAndSettle();

      expect(removed, isTrue);
      expect(meta, isNotNull);
      expect(meta!.source, BcEventSource.pointer);
      expect(find.byKey(const Key('bc-chip-root')), findsNothing);
    });

    testWidgets('controlled removed=true hides the chip (VAL-E2-005)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        label: 'Controlled',
        removed: true,
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-chip-root')), findsNothing);
    });

    testWidgets('disabled chip dims + remove button is disabled (VAL-E2-006)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        label: 'Disabled',
        removable: true,
        disabled: true,
      ));
      await tester.pumpAndSettle();
      // IconButton onPressed should be null when disabled.
      final btn = tester.widget<IconButton>(
        find.byKey(const Key('bc-chip-remove')),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('initials avatar renders for non-URL string (VAL-E2-007)',
        (tester) async {
      await tester.pumpWidget(buildHarness(label: 'Marketing', avatar: 'MK'));
      await tester.pumpAndSettle();
      expect(find.text('MK'), findsOneWidget);
    });

    testWidgets('onClick makes the chip tappable (VAL-E2-008)',
        (tester) async {
      bool clicked = false;
      await tester.pumpWidget(buildHarness(
        label: 'Clickable',
        onClick: () => clicked = true,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-chip-root')));
      await tester.pumpAndSettle();
      expect(clicked, isTrue);
    });

    testWidgets('long label truncates (VAL-E2-009)', (tester) async {
      const longLabel = 'A very long label that should be truncated by the ConstrainedBox maxWidth';
      await tester.pumpWidget(buildHarness(label: longLabel));
      await tester.pumpAndSettle();
      final text = tester.widget<Text>(find.text(longLabel));
      expect(text.overflow, TextOverflow.ellipsis);
    });
  });
}
