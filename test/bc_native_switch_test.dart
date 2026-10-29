import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_toggle.dart';
import 'package:bc_ui_flutter/src/components/bc_native_switch.dart';

void main() {
  group('BcNativeSwitch (typedef alias to BcToggle)', () {
    Widget buildHarness({
      bool? value,
      bool? defaultValue,
      bool disabled = false,
      String? label,
      BcChangeHandler<bool>? onValueChange,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: BcNativeSwitch(
              value: value,
              defaultValue: defaultValue,
              disabled: disabled,
              label: label,
              onValueChange: onValueChange,
            ),
          ),
        ),
      );
    }

    testWidgets('typedef resolves to BcToggle (VAL-G-019)', (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();
      expect(find.byType(BcToggle), findsOneWidget);
    });

    testWidgets('renders with optional label (VAL-G-020)', (tester) async {
      await tester.pumpWidget(buildHarness(label: 'Wi-Fi'));
      await tester.pumpAndSettle();
      expect(find.text('Wi-Fi'), findsOneWidget);
    });

    testWidgets('onValueChange fires with meta when toggled (VAL-G-021)',
        (tester) async {
      BcChangeMeta? meta;
      bool? captured;
      await tester.pumpWidget(buildHarness(
        value: false,
        onValueChange: (v, m) {
          captured = v;
          meta = m;
        },
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(BcToggle));
      await tester.pumpAndSettle();

      expect(captured, isTrue);
      expect(meta, isNotNull);
      expect(meta!.reason, BcChangeReason.toggle);
    });

    testWidgets('disabled switch does not toggle (VAL-G-022)', (tester) async {
      int callCount = 0;
      await tester.pumpWidget(buildHarness(
        disabled: true,
        value: false,
        onValueChange: (_, __) => callCount++,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(BcToggle), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });
  });
}
