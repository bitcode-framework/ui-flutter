library bc_report_link;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Generate and display a shareable report link.
///
/// Mirrors TS `BcReportLinkContract`. Tapping the generate button produces
/// a shareable URL from [reportRef] and [baseUrl]. The generated link is
/// displayed inline with a copy button. When [reportRef] is null or empty,
/// an error state is shown instead of a link.
///
/// [onLinkGenerated] fires with the link and meta after generation.
/// [onCopy] fires when the copy button is pressed.
class BcReportLink extends StatefulWidget {
  /// The report reference to generate a link for. Must be non-empty.
  final String? reportRef;

  /// Label for the generate button. Defaults to "Generate Link".
  final String? label;

  /// Base URL for the generated link.
  /// Defaults to a placeholder host when not provided.
  final String? baseUrl;

  /// Disables the generate and copy actions.
  final bool disabled;

  /// Fires after a link is generated. Carries the link and meta.
  final void Function(String link, BcChangeMeta meta)? onLinkGenerated;

  /// Fires when the copy button is pressed. Carries the link and meta.
  final void Function(String link, BcChangeMeta meta)? onCopy;

  const BcReportLink({
    super.key,
    this.reportRef,
    this.label,
    this.baseUrl,
    this.disabled = false,
    this.onLinkGenerated,
    this.onCopy,
  });

  @override
  State<BcReportLink> createState() => _BcReportLinkState();
}

class _BcReportLinkState extends State<BcReportLink> {
  String? _generatedLink;
  String? _errorMessage;
  int _generationCount = 0;

  bool get _isValidRef =>
      widget.reportRef != null && widget.reportRef!.trim().isNotEmpty;

  String get _effectiveBaseUrl =>
      (widget.baseUrl?.isNotEmpty ?? false)
          ? widget.baseUrl!
          : 'https://app.example.com';

  void _generate() {
    if (widget.disabled) return;

    if (!_isValidRef) {
      setState(() {
        _generatedLink = null;
        _errorMessage = 'A valid report reference is required to generate a link.';
      });
      return;
    }

    final ref = widget.reportRef!.trim();
    final base = _effectiveBaseUrl.replaceAll(RegExp(r'/+$'), '');
    final token = _generationCount > 0 ? '?t=${_generationCount + 1}' : '';
    final link = '$base/r/$ref$token';

    _generationCount++;

    setState(() {
      _generatedLink = link;
      _errorMessage = null;
    });

    const meta = BcChangeMeta(
      reason: BcChangeReason.select,
      source: BcEventSource.pointer,
    );
    widget.onLinkGenerated?.call(link, meta);
  }

  void _copy() {
    if (widget.disabled) return;
    if (_generatedLink == null) return;

    Clipboard.setData(ClipboardData(text: _generatedLink!));

    const meta = BcChangeMeta(
      reason: BcChangeReason.select,
      source: BcEventSource.pointer,
    );
    widget.onCopy?.call(_generatedLink!, meta);
  }

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isCupertino =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    final labelText = widget.label ?? 'Generate Link';
    final isDisabled = widget.disabled;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Generate button
        GestureDetector(
          key: const Key('bc-report-link-generate'),
          onTap: isDisabled ? null : _generate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDisabled ? BcTheme.muted : BcTheme.primary,
              borderRadius: BorderRadius.circular(BcTheme.radius),
              border: Border.all(
                color: isDisabled ? BcTheme.border : BcTheme.primary,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCupertino
                      ? CupertinoIcons.link
                      : Icons.link_outlined,
                  size: 18,
                  color: isDisabled
                      ? BcTheme.mutedForeground
                      : BcTheme.primaryForeground,
                ),
                const SizedBox(width: 8),
                Text(
                  labelText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDisabled
                        ? BcTheme.mutedForeground
                        : BcTheme.primaryForeground,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Generated link display
        if (_generatedLink != null && _errorMessage == null) ...[
          const SizedBox(height: 12),
          Container(
            key: const Key('bc-report-link-display'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: BcTheme.muted,
              borderRadius: BorderRadius.circular(BcTheme.radius),
              border: Border.all(color: BcTheme.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _generatedLink!,
                    key: const Key('bc-report-link-text'),
                    style: const TextStyle(
                      fontSize: 13,
                      color: BcTheme.foreground,
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  key: const Key('bc-report-link-copy'),
                  onTap: isDisabled ? null : _copy,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: BcTheme.secondary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      isCupertino
                          ? CupertinoIcons.doc_on_doc
                          : Icons.copy_outlined,
                      size: 16,
                      color: BcTheme.secondaryForeground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Error state
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            key: const Key('bc-report-link-error'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: BcTheme.destructive.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(BcTheme.radius),
              border: Border.all(
                color: BcTheme.destructive.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isCupertino
                      ? CupertinoIcons.exclamationmark_triangle
                      : Icons.error_outline,
                  size: 18,
                  color: BcTheme.destructive,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: BcTheme.destructive,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
