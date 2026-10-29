import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_inplace.dart';

/// Stateful wrapper to test controlled mode properly.
class _ControlledWrapper extends StatefulWidget {
  final String initialValue;
  final bool withButtons;
  final String? placeholder;
  final bool disabled;
  final void Function(String val, BcChangeMeta meta)? onChanged;

  const _ControlledWrapper({
    required this.initialValue,
    this.withButtons = false,
    this.placeholder,
    this.disabled = false,
    this.onChanged,
  });

  @override
  State<_ControlledWrapper> createState() => _ControlledWrapperState();
}

class _ControlledWrapperState extends State<_ControlledWrapper> {
  late String _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: BcInplace(
            value: _value,
            withButtons: widget.withButtons,
            placeholder: widget.placeholder,
            disabled: widget.disabled,
            onChange: (val, meta) {
              setState(() => _value = val);
              widget.onChanged?.call(val, meta);
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  group('BcInplace', () {
    testWidgets(
        'click on display text enters edit mode with the current value '
        '(VAL-M4-030)', (tester) async {
      await tester.pumpWidget(const _ControlledWrapper(
        initialValue: 'Hello World',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Hello World'), findsOneWidget);
      expect(find.byKey(const Key('bc-inplace-display')), findsOneWidget);
      expect(find.byKey(const Key('bc-inplace-input')), findsNothing);

      await tester.tap(find.byKey(const Key('bc-inplace-display')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-inplace-input')), findsOneWidget);
      final field = tester.widget<TextField>(
        find.byKey(const Key('bc-inplace-input')),
      );
      expect(field.controller!.text, 'Hello World');
    });

    testWidgets(
        'confirm commits the new value with BcChangeMeta and returns to '
        'display mode (VAL-M4-031)', (tester) async {
      String? changedValue;
      BcChangeMeta? changedMeta;

      await tester.pumpWidget(_ControlledWrapper(
        initialValue: 'Original',
        withButtons: true,
        onChanged: (val, meta) {
          changedValue = val;
          changedMeta = meta;
        },
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-inplace-display')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('bc-inplace-input')),
        'New Value',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-inplace-save')));
      await tester.pumpAndSettle();

      expect(changedValue, 'New Value');
      expect(changedMeta, isNotNull);
      expect(changedMeta!.reason, BcChangeReason.confirm);
      expect(find.byKey(const Key('bc-inplace-input')), findsNothing);
      expect(find.text('New Value'), findsOneWidget);
    });

    testWidgets(
        'confirm via Enter key commits without buttons',
        (tester) async {
      String? changedValue;

      await tester.pumpWidget(_ControlledWrapper(
        initialValue: 'Original',
        withButtons: false,
        onChanged: (val, _) => changedValue = val,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-inplace-display')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('bc-inplace-input')),
        'Committed',
      );
      await tester.pumpAndSettle();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(changedValue, 'Committed');
      expect(find.byKey(const Key('bc-inplace-input')), findsNothing);
    });

    testWidgets(
        'cancel reverts to the prior value without emitting a change '
        '(VAL-M4-032)', (tester) async {
      int changeCount = 0;

      await tester.pumpWidget(_ControlledWrapper(
        initialValue: 'Original',
        withButtons: true,
        onChanged: (_, __) => changeCount++,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-inplace-display')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('bc-inplace-input')),
        'Discarded',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-inplace-cancel')));
      await tester.pumpAndSettle();

      expect(changeCount, 0);
      expect(find.byKey(const Key('bc-inplace-input')), findsNothing);
      expect(find.text('Original'), findsOneWidget);
    });

    testWidgets(
        'Escape key cancels edit and reverts value',
        (tester) async {
      int changeCount = 0;

      await tester.pumpWidget(_ControlledWrapper(
        initialValue: 'Original',
        withButtons: false,
        onChanged: (_, __) => changeCount++,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-inplace-display')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('bc-inplace-input')),
        'Discarded',
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(changeCount, 0);
      expect(find.byKey(const Key('bc-inplace-input')), findsNothing);
      expect(find.text('Original'), findsOneWidget);
    });

    testWidgets(
        'disabled state prevents entering edit mode (VAL-M4-033)',
        (tester) async {
      await tester.pumpWidget(const _ControlledWrapper(
        initialValue: 'Read Only',
        disabled: true,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-inplace-display')), findsOneWidget);
      expect(find.text('Read Only'), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc-inplace-display')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-inplace-input')), findsNothing,
          reason: 'Disabled should not enter edit mode');
      expect(find.byKey(const Key('bc-inplace-display')), findsOneWidget);
    });

    testWidgets('shows placeholder when no value', (tester) async {
      await tester.pumpWidget(const _ControlledWrapper(
        initialValue: '',
        placeholder: 'Click to edit',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Click to edit'), findsOneWidget);
    });

    testWidgets('uncontrolled defaultValue seeds initial value',
        (tester) async {
      String? changed;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcInplace(
            defaultValue: 'Seed',
            withButtons: true,
            onChange: (val, _) => changed = val,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Seed'), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc-inplace-display')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('bc-inplace-input')),
        'Updated',
      );
      await tester.tap(find.byKey(const Key('bc-inplace-save')));
      await tester.pumpAndSettle();

      expect(changed, 'Updated');
      expect(find.text('Updated'), findsOneWidget);
    });

    testWidgets('blur commits in withoutButtons mode', (tester) async {
      String? changed;

      await tester.pumpWidget(_ControlledWrapper(
        initialValue: 'Original',
        withButtons: false,
        onChanged: (val, _) => changed = val,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-inplace-display')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('bc-inplace-input')),
        'Blurred',
      );
      await tester.pumpAndSettle();

      // Blur by removing focus from the text field
      FocusManager.instance.primaryFocus?.unfocus(disposition: UnfocusDisposition.scope);
      await tester.pumpAndSettle();

      expect(changed, 'Blurred');
      expect(find.byKey(const Key('bc-inplace-input')), findsNothing);
      expect(find.text('Blurred'), findsOneWidget);
    });
  });
}
