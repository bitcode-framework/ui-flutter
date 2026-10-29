library bc_taggroup;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

class BcTagGroupTag {
  final String label;
  final String value;
  final BcTagVariant? variant;

  const BcTagGroupTag({
    required this.label,
    required this.value,
    this.variant,
  });
}

class BcTagGroup extends StatefulWidget {
  final List<BcTagGroupTag> tags;
  final bool removable;
  final bool addable;
  final bool allowDuplicates;
  final int? max;
  final String? label;
  final void Function(List<BcTagGroupTag> tags, BcChangeMeta meta)? onChange;

  const BcTagGroup({
    super.key,
    this.tags = const [],
    this.removable = false,
    this.addable = false,
    this.allowDuplicates = false,
    this.max,
    this.label,
    this.onChange,
  });

  @override
  State<BcTagGroup> createState() => _BcTagGroupState();
}

class _BcTagGroupState extends State<BcTagGroup> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _removeTag(BcTagGroupTag tag) {
    final updated = widget.tags.where((t) => t.value != tag.value).toList();
    widget.onChange?.call(
      updated,
      const BcChangeMeta(
        reason: BcChangeReason.clear,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _addTag() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (!widget.allowDuplicates) {
      final exists = widget.tags.any((t) =>
          t.label.toLowerCase() == text.toLowerCase());
      if (exists) {
        _controller.clear();
        return;
      }
    }

    final value = text.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    final newTag = BcTagGroupTag(label: text, value: value);
    final updated = [...widget.tags, newTag];

    widget.onChange?.call(
      updated,
      const BcChangeMeta(
        reason: BcChangeReason.submit,
        source: BcEventSource.pointer,
      ),
    );

    _controller.clear();
  }

  Color _variantColor(BcTagVariant? variant) {
    switch (variant) {
      case BcTagVariant.success:
        return BcTheme.success;
      case BcTagVariant.warning:
        return BcTheme.warning;
      case BcTagVariant.destructive:
        return BcTheme.destructive;
      case BcTagVariant.info:
        return BcTheme.info;
      case BcTagVariant.defaultVariant:
      case null:
        return BcTheme.accentForeground;
    }
  }

  Color _variantBg(BcTagVariant? variant) {
    switch (variant) {
      case BcTagVariant.success:
        return BcTheme.success.withValues(alpha: 0.1);
      case BcTagVariant.warning:
        return BcTheme.warning.withValues(alpha: 0.1);
      case BcTagVariant.destructive:
        return BcTheme.destructive.withValues(alpha: 0.1);
      case BcTagVariant.info:
        return BcTheme.info.withValues(alpha: 0.1);
      case BcTagVariant.defaultVariant:
      case null:
        return BcTheme.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleTags = widget.max != null && widget.tags.length > widget.max!
        ? widget.tags.take(widget.max!).toList()
        : widget.tags;
    final hiddenCount = widget.max != null && widget.tags.length > widget.max!
        ? widget.tags.length - widget.max!
        : 0;

    return Semantics(
      container: true,
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final tag in visibleTags) _buildTag(tag),
          if (hiddenCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                '+$hiddenCount more',
                style: const TextStyle(
                  fontSize: 12,
                  color: BcTheme.mutedForeground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (widget.addable) _buildAddInput(),
        ],
      ),
    );
  }

  Widget _buildTag(BcTagGroupTag tag) {
    return Container(
      key: Key('bc_taggroup_tag_${tag.value}'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _variantBg(tag.variant),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag.label,
            style: TextStyle(
              fontSize: 12,
              color: _variantColor(tag.variant),
            ),
          ),
          if (widget.removable) ...[
            const SizedBox(width: 4),
            GestureDetector(
              key: Key('bc_taggroup_remove_${tag.value}'),
              onTap: () => _removeTag(tag),
              child: Icon(
                Icons.close,
                size: 12,
                color: _variantColor(tag.variant),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddInput() {
    return SizedBox(
      width: 120,
      child: TextField(
        key: const Key('bc_taggroup_input'),
        controller: _controller,
        focusNode: _focusNode,
        style: const TextStyle(fontSize: 12, color: BcTheme.foreground),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          hintText: 'Add tag',
          hintStyle: TextStyle(fontSize: 12, color: BcTheme.mutedForeground),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            borderSide: BorderSide(color: BcTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            borderSide: BorderSide(color: BcTheme.primary),
          ),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _addTag(),
      ),
    );
  }
}
