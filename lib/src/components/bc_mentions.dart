library bc_mentions;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

class BcMentionOption {
  final String value;
  final String? label;

  const BcMentionOption({required this.value, this.label});

  String get displayLabel => label ?? value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcMentionOption && value == other.value && label == other.label;

  @override
  int get hashCode => Object.hash(value, label);
}

class BcMentions extends StatefulWidget {
  final String? name;
  final String? label;
  final String? value;
  final String? placeholder;
  final String prefix;
  final List<BcMentionOption>? options;
  final bool disabled;
  final int rows;
  final BcChangeHandler<String>? onChange;
  final void Function(BcMentionOption option)? onSelect;

  const BcMentions({
    super.key,
    this.name,
    this.label,
    this.value,
    this.placeholder,
    this.prefix = '@',
    this.options,
    this.disabled = false,
    this.rows = 3,
    this.onChange,
    this.onSelect,
  });

  @override
  State<BcMentions> createState() => _BcMentionsState();
}

class _BcMentionsState extends State<BcMentions> {
  final TextEditingController _controller = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  bool _internalEditMode = false;
  String _internalValue = '';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _internalEditMode = widget.value == null;
    _internalValue = widget.value ?? '';
    _controller.text = _internalValue;
    _controller.addListener(_onControllerChanged);
    _focusNode.addListener(_onFocusChange);
  }

  void _onControllerChanged() {
    if (!_internalEditMode) return;
    final text = _controller.text;
    if (text == _internalValue) return;
    _internalValue = text;
    widget.onChange?.call(
      text,
      const BcChangeMeta(
        reason: BcChangeReason.input,
        source: BcEventSource.keyboard,
      ),
    );
    _detectToken(text);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _hideOverlay();
    }
  }

  @override
  void didUpdateWidget(BcMentions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value != null) {
        _internalEditMode = false;
        _internalValue = widget.value!;
        if (_controller.text != _internalValue) {
          _controller.text = _internalValue;
        }
      } else {
        _internalEditMode = true;
      }
    }
  }

  @override
  void dispose() {
    _hideOverlay();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  String get _currentText =>
      widget.value ?? _internalValue;

  List<BcMentionOption> get _filtered {
    final opts = widget.options ?? const <BcMentionOption>[];
    final q = _query.toLowerCase();
    if (q.isEmpty) return opts;
    return opts
        .where((o) => o.displayLabel.toLowerCase().contains(q) || o.value.toLowerCase().contains(q))
        .toList();
  }

  void _detectToken(String text) {
    final prefix = widget.prefix;
    final idx = text.lastIndexOf(prefix);
    if (idx == -1) {
      _query = '';
      _hideOverlay();
      return;
    }
    final afterPrefix = text.substring(idx + prefix.length);
    final lastWordBoundary = afterPrefix.lastIndexOf(' ');
    final token = lastWordBoundary >= 0
        ? afterPrefix.substring(lastWordBoundary + 1)
        : afterPrefix;

    if (token.contains(RegExp(r'\s'))) {
      _query = '';
      _hideOverlay();
      return;
    }

    final preceding = text.substring(0, idx);
    if (preceding.isNotEmpty && !preceding.endsWith(' ') && !preceding.endsWith('\n')) {
      final lastSpace = preceding.lastIndexOf(' ');
      final lastNewline = preceding.lastIndexOf('\n');
      final lastBoundary = [lastSpace, lastNewline].fold<int>(-1, (a, b) => a > b ? a : b);
      if (lastBoundary < preceding.length - 1) {
        _query = '';
        _hideOverlay();
        return;
      }
    }

    _query = token;
    if (widget.disabled) {
      _hideOverlay();
      return;
    }
    _showOrUpdateOverlay();
  }

  void _showOrUpdateOverlay() {
    if (_filtered.isEmpty) {
      _hideOverlay();
      return;
    }
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 220,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 0),
          followerAnchor: Alignment.topLeft,
          targetAnchor: Alignment.bottomLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(BcTheme.radius),
            color: BcTheme.popover,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(BcTheme.radius),
                border: Border.all(color: BcTheme.border),
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                children: _filtered
                    .map((option) => _buildSuggestionItem(option))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(BcMentionOption option) {
    return InkWell(
      key: ValueKey<String>('bc_mentions_suggestion_${option.value}'),
      onTap: () => _pickOption(option),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          option.displayLabel,
          style: const TextStyle(
            fontSize: 14,
            color: BcTheme.popoverForeground,
          ),
        ),
      ),
    );
  }

  void _pickOption(BcMentionOption option) {
    final prefix = widget.prefix;
    final text = _currentText;
    final idx = text.lastIndexOf(prefix);

    final String next;
    if (idx == -1) {
      next = '$text$prefix${option.value} ';
    } else {
      next = '${text.substring(0, idx)}$prefix${option.value} ';
    }

    _internalValue = next;
    _controller.text = next;
    _controller.selection = TextSelection.collapsed(offset: next.length);

    widget.onChange?.call(
      next,
      const BcChangeMeta(
        reason: BcChangeReason.valueChange,
        source: BcEventSource.pointer,
      ),
    );
    widget.onSelect?.call(option);

    _query = '';
    _hideOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                widget.label!,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          _buildField(context),
        ],
      ),
    );
  }

  Widget _buildField(BuildContext context) {
    return PlatformWidget(
      material: (context, _) => TextField(
        key: const Key('bc_mentions_field'),
        controller: _controller,
        focusNode: _focusNode,
        enabled: !widget.disabled,
        maxLines: widget.rows,
        minLines: widget.rows,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: widget.placeholder,
          hintStyle: const TextStyle(color: BcTheme.mutedForeground),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: BcTheme.background,
        ),
      ),
      cupertino: (context, _) => CupertinoTextField(
        key: const Key('bc_mentions_field'),
        controller: _controller,
        focusNode: _focusNode,
        enabled: !widget.disabled,
        maxLines: widget.rows,
        minLines: widget.rows,
        style: const TextStyle(fontSize: 14),
        placeholder: widget.placeholder,
        decoration: BoxDecoration(
          border: Border.all(color: BcTheme.border),
          borderRadius: BorderRadius.circular(BcTheme.radius),
          color: BcTheme.background,
        ),
      ),
    );
  }
}
