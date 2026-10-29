// Forms demo — BcInput, BcSelect, BcCheckbox, BcToggle, BcSegmented, BcSlider,
// BcNumberField, BcDateField, BcCombobox, BcMultiSelect, BcTagsInput,
// BcToggleGroup, BcFieldDuration, BcTextField, BcTimeField, BcTagGroup, BcForm.
library forms_section;

import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

import '../demo_widgets.dart';

class FormsSection extends StatefulWidget {
  const FormsSection({super.key});

  @override
  State<FormsSection> createState() => _FormsSectionState();
}

class _FormsSectionState extends State<FormsSection> {
  String _inputValue = '';
  String _selectedFruit = 'Apple';
  bool _isChecked = false;
  bool _isToggled = true;
  String _segment = 'Daily';
  double _sliderValue = 50;
  num _numberValue = 5;
  DateTime? _selectedDate;
  String _comboValue = '';
  List<String> _multiValue = ['Engineering'];
  List<String> _tags = ['flutter', 'dart'];
  String _toggleGroupSingle = 'left';
  num _durationSeconds = 3661;
  TimeOfDay? _selectedTime = const TimeOfDay(hour: 14, minute: 30);
  List<BcTagGroupTag> _tagGroupTags = const [
    BcTagGroupTag(label: 'Frontend', value: 'fe'),
    BcTagGroupTag(label: 'Backend', value: 'be'),
    BcTagGroupTag(label: 'DevOps', value: 'devops'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Forms',
          subtitle: 'Adaptive form controls — Material on Android, Cupertino on iOS.',
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcInput',
          description: 'Adaptive text input (Material TextFormField / CupertinoTextField).',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BcInput(
                label: 'Name',
                placeholder: 'Enter your name',
                value: _inputValue,
                onValueChange: (v, _) => setState(() => _inputValue = v),
              ),
              const SizedBox(height: 12),
              BcInput(
                label: 'Email',
                placeholder: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              BcInput(
                label: 'Disabled',
                placeholder: 'Cannot edit',
                disabled: true,
                defaultValue: 'Read-only value',
              ),
              if (_inputValue.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('You typed: $_inputValue',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcSelect',
          description: 'Adaptive dropdown (Material DropdownButtonFormField / Cupertino modal).',
          child: BcSelect<String>(
            label: 'Favorite Fruit',
            value: _selectedFruit,
            options: const [
              BcSelectOption(value: 'Apple', label: 'Apple'),
              BcSelectOption(value: 'Banana', label: 'Banana'),
              BcSelectOption(value: 'Cherry', label: 'Cherry'),
              BcSelectOption(value: 'Date', label: 'Date'),
            ],
            onValueChange: (v, _) => setState(() => _selectedFruit = v),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcCheckbox & BcToggle',
          description: 'Adaptive checkbox and switch.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BcCheckbox(
                label: 'Accept terms and conditions',
                value: _isChecked,
                onValueChange: (v, _) => setState(() => _isChecked = v),
              ),
              const SizedBox(height: 12),
              BcToggle(
                label: 'Enable notifications',
                value: _isToggled,
                onValueChange: (v, _) => setState(() => _isToggled = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcSegmented',
          description: 'Adaptive segmented control (Material SegmentedButton / CupertinoSegmentedControl).',
          child: BcSegmented<String>(
            value: _segment,
            options: const [
              BcSegmentedOption(value: 'Daily', label: 'Daily'),
              BcSegmentedOption(value: 'Weekly', label: 'Weekly'),
              BcSegmentedOption(value: 'Monthly', label: 'Monthly'),
            ],
            onValueChange: (v, _) => setState(() => _segment = v),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcSlider',
          description: 'Single-thumb slider with min/max/step clamping.',
          child: BcSlider(
            label: 'Volume',
            value: _sliderValue,
            min: 0,
            max: 100,
            step: 5,
            showValue: true,
            unit: '%',
            onChange: (v, _) => setState(() => _sliderValue = v),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcNumberField',
          description: 'Numeric input with min/max and stepper.',
          child: BcNumberField(
            label: 'Quantity',
            value: _numberValue,
            min: 0,
            max: 99,
            step: 1,
            onValueChange: (v, _) => setState(() => _numberValue = v),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcDateField',
          description: 'Adaptive date picker (Material calendar / Cupertino wheel).',
          child: BcDateField(
            label: 'Birth Date',
            value: _selectedDate,
            placeholder: 'Select a date',
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
            onValueChange: (v, _) => setState(() => _selectedDate = v),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcCombobox',
          description: 'Autocomplete combobox (Material-only). Type to filter options.',
          child: BcCombobox<String>(
            label: 'Country',
            placeholder: 'Start typing a country...',
            value: _comboValue,
            options: const [
              BcComboboxOption(value: 'id', label: 'Indonesia'),
              BcComboboxOption(value: 'us', label: 'United States'),
              BcComboboxOption(value: 'uk', label: 'United Kingdom'),
              BcComboboxOption(value: 'jp', label: 'Japan'),
              BcComboboxOption(value: 'sg', label: 'Singapore'),
              BcComboboxOption(value: 'au', label: 'Australia'),
            ],
            onValueChange: (v, _) => setState(() => _comboValue = v),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcMultiSelect',
          description: 'Multi-select with chip display (Material-only).',
          child: BcMultiSelect<String>(
            label: 'Departments',
            value: _multiValue,
            options: const [
              BcMultiSelectOption(value: 'Engineering', label: 'Engineering'),
              BcMultiSelectOption(value: 'Design', label: 'Design'),
              BcMultiSelectOption(value: 'Marketing', label: 'Marketing'),
              BcMultiSelectOption(value: 'Sales', label: 'Sales'),
              BcMultiSelectOption(value: 'Operations', label: 'Operations'),
            ],
            onValueChange: (v, _) => setState(() => _multiValue = v),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcTagsInput',
          description: 'Add/remove tags by typing comma or pressing Enter.',
          child: BcTagsInput(
            label: 'Skills',
            placeholder: 'Type a skill and press Enter',
            value: _tags,
            maxTags: 8,
            onChange: (v, _) => setState(() => _tags = v),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcToggleGroup',
          description: 'Button group toggle (single or multiple selection).',
          child: BcToggleGroup(
            value: _toggleGroupSingle,
            options: const [
              BcToggleGroupOption(label: 'Left', value: 'left'),
              BcToggleGroupOption(label: 'Center', value: 'center'),
              BcToggleGroupOption(label: 'Right', value: 'right'),
              BcToggleGroupOption(label: 'Justify', value: 'justify'),
            ],
            onChange: (v, _) => setState(() => _toggleGroupSingle = v as String),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcFieldDuration',
          description: 'HH:MM:SS duration input with stepper overflow.',
          child: BcFieldDuration(
            label: 'Elapsed Time',
            value: _durationSeconds,
            showSeconds: true,
            onValueChange: (v, _) => setState(() => _durationSeconds = v),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcRangeSlider',
          description: 'Dual-thumb min/max range slider with non-crossing thumbs.',
          child: BcRangeSlider(
            label: 'Price Range',
            min: 0,
            max: 1000,
            step: 50,
            showValues: true,
            unit: '\$',
            defaultValue: const BcRangeValue(min: 100, max: 500),
          ),
        ),
        const SizedBox(height: 24),

        // -- BcTextField --
        DemoCard(
          title: 'BcTextField',
          description: 'Rich text input with auto-grow, counter, and prefix/suffix.',
          child: BcYStack(
            gap: 12,
            children: [
              BcTextField(
                name: 'username',
                label: 'Username',
                placeholder: 'Enter username',
                description: 'Must be 3-20 characters.',
              ),
              BcTextField(
                name: 'bio',
                label: 'Bio',
                placeholder: 'Tell us about yourself',
                multiline: true,
                autoGrow: true,
                showCount: true,
                maxLength: 200,
              ),
              BcTextField(
                name: 'price',
                label: 'Price',
                prefixText: '\$',
                suffixText: 'USD',
                clearable: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // -- BcTimeField --
        DemoCard(
          title: 'BcTimeField',
          description: 'Adaptive time picker (Material showTimePicker / CupertinoDatePicker).',
          child: BcYStack(
            gap: 8,
            children: [
              BcTimeField(
                label: 'Start Time',
                value: _selectedTime,
                onValueChange: (v, _) => setState(() => _selectedTime = v),
              ),
              if (_selectedTime != null)
                Text(
                  'Selected: ${_selectedTime!.hour.toString().padLeft(2, '0')}'
                  ':${_selectedTime!.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // -- BcTagGroup --
        DemoCard(
          title: 'BcTagGroup',
          description: 'Group of tags with optional add/remove. Type and press Enter to add.',
          child: BcTagGroup(
            label: 'Skills',
            tags: _tagGroupTags,
            addable: true,
            removable: true,
            onChange: (tags, _) => setState(() => _tagGroupTags = tags),
          ),
        ),
        const SizedBox(height: 24),

        // -- BcForm (legacy child mode) --
        DemoCard(
          title: 'BcForm',
          description: 'Reactive form container. Wraps a child widget tree and exposes a store via storeOf().',
          child: BcForm(
            initialValues: const {'name': 'Alice', 'role': 'Admin'},
            child: BcYStack(
              gap: 12,
              children: [
                BcInput(
                  label: 'Name',
                  placeholder: 'Enter name',
                  defaultValue: 'Alice',
                ),
                BcInput(
                  label: 'Role',
                  placeholder: 'Enter role',
                  defaultValue: 'Admin',
                ),
                Text(
                  'BcForm provides a ReactiveStore scope; descendant fields can read/write via BcForm.storeOf(context).',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
