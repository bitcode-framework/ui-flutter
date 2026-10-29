library bc_print_preview;

import 'package:flutter/material.dart';

import '../core/bc_i18n.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Reason the print action fired.
enum BcPrintTriggerReason { triggerButton, programmatic }

/// Preview pane + print trigger (ADR-007 contract parity).
///
/// On Flutter, the preview is rendered via an [HtmlElementView] on web or a
/// simplified read-only text view on mobile. The trigger button invokes
/// the parent-supplied [onPrint] callback (the parent wires it to the
/// platform print API of their choice, e.g. `printing` package).
class BcPrintPreview extends StatelessWidget {
  final String? content;
  final String? title;
  final String? triggerLabel;
  final bool disabled;
  final bool hideToolbar;
  final double height;
  final BcChangeHandler<void>? onPrint;
  final BcChangeHandler<String>? onError;

  const BcPrintPreview({
    super.key,
    this.content,
    this.title,
    this.triggerLabel,
    this.disabled = false,
    this.hideToolbar = false,
    this.height = 600,
    this.onPrint,
    this.onError,
  });

  void _handleTrigger() {
    if (disabled) return;
    onPrint?.call(
      null,
      const BcChangeMeta(
        reason: BcChangeReason.submit,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: bcI18n.t('bc.printPreview.ariaLabel'),
      child: Container(
        key: const Key('bc-print-preview-root'),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: BcTheme.background,
          borderRadius: BorderRadius.circular(BcTheme.radius),
          border: Border.all(color: BcTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!hideToolbar) _buildToolbar(),
            Expanded(
              child: Container(
                key: const Key('bc-print-preview-body'),
                color: BcTheme.muted.withValues(alpha: 0.3),
                height: height,
                padding: const EdgeInsets.all(16),
                child: _buildPreview(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    final effectiveTitle = title ?? bcI18n.t('bc.printPreview.title');
    final effectiveTriggerLabel =
        triggerLabel ?? bcI18n.t('bc.printPreview.triggerLabel');
    return Container(
      key: const Key('bc-print-preview-toolbar'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0x80F1F5F9), // BcTheme.muted at 50% alpha (BcTheme.muted is const 0xFFF1F5F9)
        border: Border(bottom: BorderSide(color: BcTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              effectiveTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: BcTheme.foreground,
              ),
            ),
          ),
          ElevatedButton.icon(
            key: const Key('bc-print-preview-trigger'),
            onPressed: disabled ? null : _handleTrigger,
            icon: const Icon(Icons.print, size: 16),
            label: Text(effectiveTriggerLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: BcTheme.primary,
              foregroundColor: BcTheme.primaryForeground,
              disabledBackgroundColor: BcTheme.primary.withValues(alpha: 0.5),
              disabledForegroundColor: BcTheme.primaryForeground,
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final html = content;
    if (html == null || html.isEmpty) {
      return const Center(
        child: Text(
          'No content to preview',
          style: TextStyle(color: BcTheme.mutedForeground, fontSize: 14),
        ),
      );
    }
    // Plain-text fallback (HTML rendering on Flutter requires a package
    // dependency the consumer chooses; we surface the raw content so the
    // parent can render it with flutter_html or a WebView as they prefer).
    final plainText = _stripHtml(html);
    return SingleChildScrollView(
      child: Text(
        plainText,
        style: const TextStyle(
          fontSize: 13,
          color: BcTheme.foreground,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>'), '')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
