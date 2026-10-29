library bc_tags_input;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

class BcTagsInput extends StatefulWidget {
  final String? name;
  final String? label;
  final String? placeholder;
  final List<String>? value;
  final List<String>? defaultValue;
  final bool disabled;
  final bool required;
  final int? maxTags;
  final BcChangeHandler<List<String>>? onChange;

  const BcTagsInput({
    super.key,
    this.name,
    this.label,
    this.placeholder,
    this.value,
    this.defaultValue,
    this.disabled = false,
    this.required = false,
    this.maxTags,
    this.onChange,
  });

  @override
  State<BcTagsInput> createState() => _BcTagsInputState();
}

class _BcTagsInputState extends State<BcTagsInput> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _internalTags = const [];

  @override
  void initState() {
    super.initState();
    _internalTags = List<String>.from(widget.defaultValue ?? const <String>[]);
    _focusNode.addListener(_onFocusChange);
    _inputController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    final text = _inputController.text;
    if (text.contains(',')) {
      _addTag();
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _inputController.text.isNotEmpty) {
      _addTag();
    }
  }

  @override
  void didUpdateWidget(BcTagsInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null && !_listEquals(widget.value!, oldWidget.value ?? const [])) {
      // controlled mode update is reflected via _current getter
    }
    if (widget.defaultValue != oldWidget.defaultValue &&
        widget.value == null) {
      _internalTags = List<String>.from(widget.defaultValue ?? const <String>[]);
    }
  }

  @override
  void dispose() {
    _inputController.removeListener(_onInputChanged);
    _inputController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  List<String> get _current =>
      widget.value ?? _internalTags;

  bool get _atMax =>
      widget.maxTags != null && _current.length >= widget.maxTags!;

  void _addTag() {
    final raw = _inputController.text;
    final token = raw.replaceAll(',', '').trim();

    if (token.isEmpty || widget.disabled || _atMax) {
      _inputController.clear();
      return;
    }
    if (_current.contains(token)) {
      _inputController.clear();
      return;
    }

    final next = List<String>.from(_current)..add(token);

    if (widget.value == null) {
      setState(() => _internalTags = next);
    }
    _inputController.clear();
    widget.onChange?.call(
      next,
      const BcChangeMeta(
        reason: BcChangeReason.input,
        source: BcEventSource.keyboard,
      ),
    );
  }

  void _removeTag(int index) {
    if (widget.disabled) return;
    if (index < 0 || index >= _current.length) return;

    final next = List<String>.from(_current)..removeAt(index);

    if (widget.value == null) {
      setState(() => _internalTags = next);
    }
    widget.onChange?.call(
      next,
      const BcChangeMeta(
        reason: BcChangeReason.deselect,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _handleKeyDown(KeyEvent event) {
    if (widget.disabled) return;
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      _addTag();
    } else if (event.logicalKey == LogicalKeyboardKey.comma) {
      _addTag();
    } else if (event.logicalKey == LogicalKeyboardKey.backspace &&
        _inputController.text.isEmpty &&
        _current.isNotEmpty) {
      _removeLastWithBackReason();
    }
  }

  void _removeLastWithBackReason() {
    if (widget.disabled) return;
    final lastIdx = _current.length - 1;
    if (lastIdx < 0) return;

    final next = List<String>.from(_current)..removeLast();

    if (widget.value == null) {
      setState(() => _internalTags = next);
    }
    widget.onChange?.call(
      next,
      const BcChangeMeta(
        reason: BcChangeReason.back,
        source: BcEventSource.keyboard,
      ),
    );
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        _handleKeyDown(event);
        return KeyEventResult.ignored;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label!,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  if (widget.required)
                    const Padding(
                      padding: EdgeInsets.only(left: 2),
                      child: Text(
                        '*',
                        style: TextStyle(color: BcTheme.destructive),
                      ),
                    ),
                ],
              ),
            ),
          _buildTagContainer(context),
        ],
      ),
    );
  }

  Widget _buildTagContainer(BuildContext context) {
    return PlatformWidget(
      material: (context, _) => _wrapField(
        container: Container(
          decoration: BoxDecoration(
            border: Border.all(color: BcTheme.border),
            borderRadius: const BorderRadius.all(Radius.circular(BcTheme.radius)),
            color: BcTheme.background,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: _tagRow(context),
        ),
      ),
      cupertino: (context, _) => _wrapField(
        container: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: BcTheme.border),
            borderRadius: const BorderRadius.all(Radius.circular(BcTheme.radius)),
            color: BcTheme.background,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: _tagRow(context),
          ),
        ),
      ),
    );
  }

  Widget _wrapField({required Widget container}) {
    return container;
  }

  Widget _tagRow(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < _current.length; i++)
          _buildChip(context, _current[i], i),
        _buildTextField(context),
      ],
    );
  }

  Widget _buildChip(BuildContext context, String tag, int index) {
    return Container(
      key: ValueKey<String>('bc_tags_input_chip_$index'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: const BoxDecoration(
        color: BcTheme.accent,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: const TextStyle(
              fontSize: 12,
              color: BcTheme.accentForeground,
            ),
          ),
          const SizedBox(width: 4),
          _buildRemoveButton(tag, index),
        ],
      ),
    );
  }

  Widget _buildRemoveButton(String tag, int index) {
    final disabled = widget.disabled;
    return PlatformWidget(
      material: (context, _) => InkWell(
        key: Key('bc_tags_input_remove_$index'),
        onTap: disabled ? null : () => _removeTag(index),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            Icons.close,
            size: 12,
            color: disabled ? BcTheme.mutedForeground : BcTheme.foreground,
          ),
        ),
      ),
      cupertino: (context, _) => GestureDetector(
        key: Key('bc_tags_input_remove_$index'),
        onTap: disabled ? null : () => _removeTag(index),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            CupertinoIcons.clear_circled_solid,
            size: 12,
            color: disabled ? BcTheme.mutedForeground : BcTheme.foreground,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context) {
    final showPlaceholder = _current.isEmpty;
    final enabled = !widget.disabled && !_atMax;

    return PlatformWidget(
      material: (context, _) => SizedBox(
        width: 120,
        child: TextField(
          key: const Key('bc_tags_input_field'),
          controller: _inputController,
          focusNode: _focusNode,
          enabled: enabled,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            hintText: showPlaceholder ? widget.placeholder : null,
            hintStyle: const TextStyle(color: BcTheme.mutedForeground),
          ),
          onSubmitted: (_) => _addTag(),
        ),
      ),
      cupertino: (context, _) => SizedBox(
        width: 120,
        child: CupertinoTextField(
          key: const Key('bc_tags_input_field'),
          controller: _inputController,
          focusNode: _focusNode,
          enabled: enabled,
          style: const TextStyle(fontSize: 14),
          padding: EdgeInsets.zero,
          decoration: const BoxDecoration(),
          placeholder: showPlaceholder ? widget.placeholder : null,
          onSubmitted: (_) => _addTag(),
        ),
      ),
    );
  }
}
