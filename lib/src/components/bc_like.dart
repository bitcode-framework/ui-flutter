library bc_like;

import 'package:flutter/material.dart';

import '../core/bc_i18n.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Reason the like state changed.
enum BcLikeChangeReason { toggleOn, toggleOff, programmatic }

/// Like/unlike toggle with optional count (ADR-007 parity).
class BcLike extends StatefulWidget {
  final bool? liked;
  final bool defaultLiked;
  final int? count;
  final bool disabled;
  final String? ariaLabel;
  final BcChangeHandler<bool>? onLikedChange;

  const BcLike({
    super.key,
    this.liked,
    this.defaultLiked = false,
    this.count,
    this.disabled = false,
    this.ariaLabel,
    this.onLikedChange,
  });

  @override
  State<BcLike> createState() => _BcLikeState();
}

class _BcLikeState extends State<BcLike> {
  late bool _internalLiked;
  bool get _isControlled => widget.liked != null;
  bool get _isLiked => _isControlled ? widget.liked! : _internalLiked;

  @override
  void initState() {
    super.initState();
    _internalLiked = widget.defaultLiked;
  }

  void _toggle() {
    if (widget.disabled) return;
    final next = !_isLiked;
    if (!_isControlled) {
      setState(() => _internalLiked = next);
    }
    widget.onLikedChange?.call(
      next,
      BcChangeMeta(
        reason: next ? BcChangeReason.toggle : BcChangeReason.clear,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final liked = _isLiked;
    return MergeSemantics(
      child: Semantics(
        label: widget.ariaLabel ?? bcI18n.t('bc.like.defaultAriaLabel'),
        button: true,
        toggled: liked,
        enabled: !widget.disabled,
        child: Opacity(
          opacity: widget.disabled ? 0.5 : 1.0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.disabled ? null : _toggle,
              borderRadius: BorderRadius.circular(BcTheme.radius),
              child: Container(
                key: const Key('bc-like-root'),
                constraints: const BoxConstraints(minHeight: 36),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      liked ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: liked ? BcTheme.destructive : BcTheme.mutedForeground,
                    ),
                    if (widget.count != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${widget.count}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: BcTheme.mutedForeground,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
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
}
