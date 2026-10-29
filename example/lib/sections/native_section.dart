// Native demo - platform-idiomatic components (iOS Cupertino / Android Material).
// BcNativeButton, BcNativeInput, BcNativeSelect, BcNativeSwitch, BcNativeSlider,
// BcNativePicker, BcNativeAlert, BcNativeActionSheet, BcNativeModal,
// BcNativeToast.
library native_section;

import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

import '../demo_widgets.dart';

class NativeSection extends StatefulWidget {
  const NativeSection({super.key});

  @override
  State<NativeSection> createState() => _NativeSectionState();
}

class _NativeSectionState extends State<NativeSection> {
  // State for various demos
  bool _switchValue = false;
  double _sliderValue = 50;
  String? _selectedValue;
  // BcNativeToast is controlled; toggling true shows it, the widget dismisses.
  bool _toastOpen = false;
  bool _toastWithActionOpen = false;
  // BcNativeModal is controlled; open/close drives the overlay.
  bool _modalOpen = false;

  void _showResult(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 800),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BcYStack(
      gap: 24,
      children: [
        const SectionHeader(
          title: 'Native',
          subtitle:
              'Platform-idiomatic components (iOS Cupertino / Android Material).',
        ),

        // -- BcNativeButton --
        DemoCard(
          title: 'BcNativeButton',
          description:
              'Platform-idiomatic button. 5 variants, loading and disabled states.',
          child: BcYStack(
            gap: 12,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  BcNativeButton(
                    label: 'Primary',
                    variant: BcNativeButtonVariant.primary,
                    onPress: (_, __) => _showResult('Primary pressed'),
                  ),
                  BcNativeButton(
                    label: 'Secondary',
                    variant: BcNativeButtonVariant.secondary,
                    onPress: (_, __) => _showResult('Secondary pressed'),
                  ),
                  BcNativeButton(
                    label: 'Destructive',
                    variant: BcNativeButtonVariant.destructive,
                    onPress: (_, __) => _showResult('Destructive pressed'),
                  ),
                  BcNativeButton(
                    label: 'Outline',
                    variant: BcNativeButtonVariant.outline,
                    onPress: (_, __) => _showResult('Outline pressed'),
                  ),
                  BcNativeButton(
                    label: 'Plain',
                    variant: BcNativeButtonVariant.plain,
                    onPress: (_, __) => _showResult('Plain pressed'),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  BcNativeButton(
                    label: 'Loading',
                    variant: BcNativeButtonVariant.primary,
                    loading: true,
                    onPress: (_, __) {},
                  ),
                  BcNativeButton(
                    label: 'Disabled',
                    variant: BcNativeButtonVariant.primary,
                    disabled: true,
                    onPress: (_, __) {},
                  ),
                ],
              ),
            ],
          ),
        ),

        // -- BcNativeInput --
        DemoCard(
          title: 'BcNativeInput',
          description:
              'Platform-idiomatic text field. Material TextFormField / CupertinoTextField.',
          child: BcYStack(
            gap: 12,
            children: [
              BcNativeInput(
                label: 'Email',
                placeholder: 'you@example.com',
                onValueChange: (value, _) => _showResult('Input: $value'),
              ),
              BcNativeInput(
                label: 'Disabled',
                placeholder: 'Cannot edit',
                disabled: true,
              ),
            ],
          ),
        ),

        // -- BcNativeSelect --
        DemoCard(
          title: 'BcNativeSelect',
          description:
              'Platform-idiomatic picker. Material dropdown / Cupertino wheel.',
          child: BcNativeSelect(
            placeholder: 'Choose a plan',
            value: _selectedValue,
            options: const [
              BcSelectOption(value: 'free', label: 'Free'),
              BcSelectOption(value: 'pro', label: 'Pro'),
              BcSelectOption(value: 'team', label: 'Team'),
              BcSelectOption(value: 'enterprise', label: 'Enterprise'),
            ],
            onValueChange: (value, _) {
              final v = value as String?;
              setState(() => _selectedValue = v);
              _showResult('Selected: $v');
            },
          ),
        ),

        // -- BcNativeSwitch --
        DemoCard(
          title: 'BcNativeSwitch',
          description: 'Platform-idiomatic toggle. Material Switch / CupertinoSwitch.',
          child: BcNativeSwitch(
            label: 'Enable notifications',
            value: _switchValue,
            onValueChange: (value, _) {
              setState(() => _switchValue = value);
              _showResult('Switch: $value');
            },
          ),
        ),

        // -- BcNativeSlider --
        DemoCard(
          title: 'BcNativeSlider',
          description:
              'Platform-idiomatic range slider. Renders Cupertino-style on iOS, Material on Android.',
          child: BcNativeSlider(
            label: 'Volume',
            value: _sliderValue,
            min: 0,
            max: 100,
            step: 5,
            showValue: true,
            unit: '%',
            onChange: (value, _) => setState(() => _sliderValue = value),
          ),
        ),

        // -- BcNativePicker --
        DemoCard(
          title: 'BcNativePicker',
          description:
              'Platform-idiomatic value picker overlay. iOS wheel / Material radio list.',
          child: BcNativeButton(
            label: 'Open picker',
            variant: BcNativeButtonVariant.outline,
            onPress: (_, __) async {
              final result = await BcNativePicker.show(
                context: context,
                title: 'Select a color',
                options: const [
                  BcNativePickerOption(label: 'Red', value: 'red'),
                  BcNativePickerOption(label: 'Green', value: 'green'),
                  BcNativePickerOption(label: 'Blue', value: 'blue'),
                  BcNativePickerOption(label: 'Yellow', value: 'yellow'),
                ],
              );
              _showResult('Picker result: $result');
            },
          ),
        ),

        // -- BcNativeAlert --
        DemoCard(
          title: 'BcNativeAlert',
          description:
              'Platform-idiomatic confirmation alert. iOS CupertinoAlertDialog / Material AlertDialog.',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              BcNativeButton(
                label: 'Confirm',
                variant: BcNativeButtonVariant.secondary,
                onPress: (_, __) async {
                  final result = await BcNativeAlert.show(
                    context: context,
                    title: 'Delete item?',
                    message: 'This action cannot be undone.',
                    confirmLabel: 'Delete',
                    cancelLabel: 'Cancel',
                    destructive: true,
                  );
                  _showResult('Alert result: $result');
                },
              ),
            ],
          ),
        ),

        // -- BcNativeActionSheet --
        DemoCard(
          title: 'BcNativeActionSheet',
          description:
              'Platform-idiomatic action sheet. iOS CupertinoActionSheet / Material bottom sheet.',
          child: BcNativeButton(
            label: 'Open action sheet',
            variant: BcNativeButtonVariant.secondary,
            onPress: (_, __) async {
              final result = await BcNativeActionSheet.show(
                context: context,
                title: 'Share',
                items: const [
                  BcNativeActionSheetItem(label: 'Copy link', value: 'copy'),
                  BcNativeActionSheetItem(label: 'Email', value: 'email'),
                  BcNativeActionSheetItem(
                      label: 'Message', value: 'message'),
                  BcNativeActionSheetItem(
                    label: 'Delete',
                    value: 'delete',
                    destructive: true,
                  ),
                ],
              );
              _showResult('Action sheet result: $result');
            },
          ),
        ),

        // -- BcNativeModal --
        DemoCard(
          title: 'BcNativeModal',
          description:
              'Platform-idiomatic modal container. fullscreen / formSheet / pageSheet presentation.',
          child: BcYStack(
            gap: 8,
            children: [
              BcNativeButton(
                label: 'Open formSheet',
                variant: BcNativeButtonVariant.primary,
                onPress: (_, __) =>
                    setState(() => _modalOpen = true),
              ),
              // Controlled modal driven by _modalOpen.
              BcNativeModal(
                open: _modalOpen,
                title: 'Form Sheet',
                presentationStyle:
                    BcNativeModalPresentationStyle.formSheet,
                onClose: (_) => setState(() => _modalOpen = false),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BcYStack(
                    gap: 12,
                    children: [
                      Text(
                        'This is a centered formSheet modal.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      BcNativeInput(
                        label: 'Note',
                        placeholder: 'Type something...',
                      ),
                      BcNativeButton(
                        label: 'Close',
                        block: true,
                        variant: BcNativeButtonVariant.secondary,
                        onPress: (_, __) =>
                            setState(() => _modalOpen = false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // -- BcNativeToast --
        DemoCard(
          title: 'BcNativeToast',
          description:
              'Platform-idiomatic ephemeral toast. iOS overlay card / Android Snackbar idiom.',
          child: BcYStack(
            gap: 8,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  BcNativeButton(
                    label: 'Info toast',
                    variant: BcNativeButtonVariant.outline,
                    onPress: (_, __) =>
                        setState(() => _toastOpen = true),
                  ),
                  BcNativeButton(
                    label: 'Toast with action',
                    variant: BcNativeButtonVariant.outline,
                    onPress: (_, __) =>
                        setState(() => _toastWithActionOpen = true),
                  ),
                ],
              ),
              // Controlled toasts; the widget auto-dismisses after duration.
              SizedBox(
                height: 64,
                child: BcYStack(
                  gap: 8,
                  crossAxisAlignment: BcYStackAlign.stretch,
                  children: [
                    BcNativeToast(
                      open: _toastOpen,
                      message: 'Settings saved successfully.',
                      duration: const Duration(seconds: 3),
                      onClose: (_, __) =>
                          setState(() => _toastOpen = false),
                    ),
                    BcNativeToast(
                      open: _toastWithActionOpen,
                      message: 'Item archived.',
                      actionLabel: 'Undo',
                      duration: const Duration(seconds: 4),
                      onAction: (_, __) {
                        _showResult('Toast action pressed');
                      },
                      onClose: (_, __) =>
                          setState(() => _toastWithActionOpen = false),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
