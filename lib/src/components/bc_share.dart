library bc_share;

import 'package:flutter/material.dart';

import '../core/bc_i18n.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Reason the share was invoked.
enum BcShareTriggerReason { triggerButton, programmatic }

/// Outcome of a share attempt.
enum BcShareResult { shared, dismissed, unavailable, error }

/// Share intent (ADR-007 parity, ADR-006 Adapt).
///
/// On the Flutter adapter, the trigger button surfaces the share payload via
/// [onShare] and the parent wires it to the platform share API of their choice
/// (e.g. `share_plus`'s `Share.share(...)`, or a custom share sheet). This
/// keeps `bc_ui_flutter` dependency-free — share_plus is an app-level
/// concern (it pulls in platform permission manifests the package shouldn't
/// impose on every consumer).
///
/// The widget still handles all the contract concerns: token-based styling,
/// disabled state, semantics, the result callback. It just delegates the
/// actual platform invocation to [onShare].
class BcShare extends StatelessWidget {
  final String? title;
  final String? text;
  final String? url;
  final String? label;
  final bool disabled;
  final BcChangeHandler<BcShareResult>? onShare;
  final void Function(Object error)? onError;

  /// Convenience accessor: the composed share payload.
  /// Parents pass this to their platform share API, e.g.
  /// `Share.share(payload.message ?? payload.url ?? '')`.
  static BcSharePayload payloadOf(BcShare widget) => BcSharePayload(
        title: widget.title,
        text: widget.text,
        url: widget.url,
      );

  const BcShare({
    super.key,
    this.title,
    this.text,
    this.url,
    this.label,
    this.disabled = false,
    this.onShare,
    this.onError,
  });

  void _handlePress() {
    if (disabled) return;
    // Emit the trigger; parent decides the platform behavior.
    onShare?.call(
      BcShareResult.shared,
      const BcChangeMeta(
        reason: BcChangeReason.submit,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = label ?? bcI18n.t('bc.share.defaultLabel');
    return MergeSemantics(
      child: Semantics(
        label: effectiveLabel,
        button: true,
        enabled: !disabled,
        child: Opacity(
          opacity: disabled ? 0.5 : 1.0,
          child: ElevatedButton.icon(
            key: const Key('bc-share-trigger'),
            onPressed: disabled ? null : _handlePress,
            icon: const Icon(Icons.share, size: 16),
            label: Text(effectiveLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: BcTheme.secondary,
              foregroundColor: BcTheme.secondaryForeground,
              disabledBackgroundColor: BcTheme.secondary.withValues(alpha: 0.5),
              disabledForegroundColor: BcTheme.secondaryForeground,
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}

/// Immutable share payload (title + text + url).
class BcSharePayload {
  final String? title;
  final String? text;
  final String? url;

  const BcSharePayload({this.title, this.text, this.url});

  /// Composed message for platform share APIs that take a single string
  /// (e.g. `Share.share(message)`): "text url" when both, else whichever is
  /// non-empty.
  String? get message {
    final parts = <String>[
      if (text != null && text!.isNotEmpty) text!,
      if (url != null && url!.isNotEmpty) url!,
    ];
    return parts.isEmpty ? null : parts.join(' ');
  }

  @override
  String toString() => 'BcSharePayload(title: $title, text: $text, url: $url)';
}
