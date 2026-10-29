library bc_chip;

import 'package:flutter/material.dart';

import '../core/bc_i18n.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Visual variant for the chip.
enum BcChipVariant {
  defaultVariant,
  primary,
  success,
  warning,
  destructive,
  info;

  Color get background {
    switch (this) {
      case BcChipVariant.defaultVariant:
        return BcTheme.secondary;
      case BcChipVariant.primary:
        return BcTheme.primary;
      case BcChipVariant.success:
        return BcTheme.success;
      case BcChipVariant.warning:
        return BcTheme.warning;
      case BcChipVariant.destructive:
        return BcTheme.destructive;
      case BcChipVariant.info:
        return BcTheme.info;
    }
  }

  Color get foreground {
    switch (this) {
      case BcChipVariant.defaultVariant:
        return BcTheme.secondaryForeground;
      case BcChipVariant.primary:
        return BcTheme.primaryForeground;
      case BcChipVariant.success:
        return BcTheme.successForeground;
      case BcChipVariant.warning:
        return BcTheme.warningForeground;
      case BcChipVariant.destructive:
        return BcTheme.destructiveForeground;
      case BcChipVariant.info:
        return BcTheme.infoForeground;
    }
  }
}

/// Reason the chip was removed.
enum BcChipRemoveReason { removeButton, programmatic }

/// Compact tag/chip with optional avatar and remove control (ADR-007 parity).
///
/// Controlled mode: parent manages [removed]; the chip hides when true.
/// Uncontrolled mode: parent omits [removed] and the chip self-hides after
/// the remove button is tapped, emitting [onRemove] with the reason.
class BcChip extends StatefulWidget {
  final String label;
  final BcChipVariant variant;
  final String? avatar;
  final bool removable;
  final bool disabled;
  final bool? removed;
  final bool defaultRemoved;
  final BcChangeHandler<bool>? onRemove;
  final VoidCallback? onClick;

  const BcChip({
    super.key,
    required this.label,
    this.variant = BcChipVariant.defaultVariant,
    this.avatar,
    this.removable = false,
    this.disabled = false,
    this.removed,
    this.defaultRemoved = false,
    this.onRemove,
    this.onClick,
  });

  @override
  State<BcChip> createState() => _BcChipState();
}

class _BcChipState extends State<BcChip> {
  late bool _internalRemoved;
  bool get _isControlled => widget.removed != null;
  bool get _isRemoved => _isControlled ? widget.removed! : _internalRemoved;

  @override
  void initState() {
    super.initState();
    _internalRemoved = widget.defaultRemoved;
  }

  void _handleRemove() {
    if (widget.disabled) return;
    if (!_isControlled) {
      setState(() => _internalRemoved = true);
    }
    widget.onRemove?.call(
      true,
      const BcChangeMeta(
        reason: BcChangeReason.clear,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isRemoved) return const SizedBox.shrink();

    final variant = widget.variant;
    final isInteractive = widget.onClick != null;

    return MergeSemantics(
      child: Semantics(
        label: widget.label,
        button: isInteractive,
        enabled: !widget.disabled,
        child: Opacity(
          opacity: widget.disabled ? 0.5 : 1.0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: (isInteractive && !widget.disabled) ? widget.onClick : null,
              borderRadius: BorderRadius.circular(9999),
              child: Container(
                key: const Key('bc-chip-root'),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: variant.background,
                  borderRadius: BorderRadius.circular(9999),
                ),
                constraints: const BoxConstraints(minHeight: 28),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.avatar != null) ...[
                      _buildAvatar(),
                      const SizedBox(width: 6),
                    ],
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: variant.foreground,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.removable) ...[
                      const SizedBox(width: 4),
                      _buildRemoveButton(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final avatar = widget.avatar ?? '';
    final isUrl = avatar.startsWith('http') ||
        avatar.startsWith('/') ||
        avatar.startsWith('data:');
    if (isUrl) {
      return ClipOval(
        child: Image.network(
          avatar,
          width: 20,
          height: 20,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsAvatar(avatar),
        ),
      );
    }
    return _initialsAvatar(avatar);
  }

  Widget _initialsAvatar(String s) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0x22000000),
      ),
      child: Text(
        s.isNotEmpty ? s.substring(0, s.length >= 2 ? 2 : 1).toUpperCase() : '',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildRemoveButton() {
    return SizedBox(
      width: 20,
      height: 20,
      child: IconButton(
        key: const Key('bc-chip-remove'),
        icon: const Icon(Icons.close, size: 12),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        onPressed: widget.disabled ? null : _handleRemove,
        tooltip: bcI18n.t('bc.chip.removeIconTitle'),
      ),
    );
  }
}
