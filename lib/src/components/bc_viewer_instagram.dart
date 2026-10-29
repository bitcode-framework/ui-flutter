library bc_viewer_instagram;

import 'package:flutter/material.dart';
import '../theme/bc_theme.dart';

/// Fallback embed height, mirroring the web adapter's `height: '600px'`
/// default. Used when the host provides no bounded height.
const double _defaultEmbedHeight = 600;

class BcViewerInstagramState extends State<BcViewerInstagram> {
  bool get _isValidUrl {
    final url = widget.url;
    if (url == null || url.isEmpty) return false;
    final lower = url.toLowerCase();
    if (!lower.startsWith('http://') && !lower.startsWith('https://')) {
      return false;
    }
    return lower.contains('instagram.com');
  }

  String get embedUrl {
    final url = widget.url ?? '';
    final trimmed = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    final captionFlag = widget.captioned ? '/captioned' : '';
    return '$trimmed/embed$captionFlag';
  }

  Widget _buildErrorFallback() {
    final e = widget.errorFallback;
    if (e != null) return Center(child: e);
    return const Center(
      key: Key('bc_viewer_instagram_error'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: BcTheme.destructive),
          SizedBox(height: 8),
          Text(
            'Unable to embed Instagram post',
            style: TextStyle(fontSize: 14, color: BcTheme.mutedForeground),
          ),
        ],
      ),
    );
  }

  Widget _buildEmbed() {
    return Container(
      key: const Key('bc_viewer_instagram_embed'),
      width: double.infinity,
      color: BcTheme.muted,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_camera, size: 48, color: BcTheme.primary),
            const SizedBox(height: 8),
            Text(
              widget.title ?? 'Instagram embed',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: BcTheme.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Web parity: the embed box is `width: 100%` / `height: 600px` by
        // default. Fill the host's height when it is bounded; otherwise fall
        // back to that default so the viewer still lays out inside a vertical
        // scroll view, where an unbounded height is invalid.
        final height = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : _defaultEmbedHeight;

        if (!_isValidUrl) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(BcTheme.radius),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: BcTheme.muted,
                border: Border.all(color: BcTheme.border),
              ),
              child: _buildErrorFallback(),
            ),
          );
        }

        final content = ClipRRect(
          borderRadius: BorderRadius.circular(BcTheme.radius),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: BcTheme.background,
              border: Border.all(color: BcTheme.border),
            ),
            child: _buildEmbed(),
          ),
        );

        if (widget.title != null && widget.title!.isNotEmpty) {
          return Semantics(
            label: widget.title,
            child: content,
          );
        }

        return content;
      },
    );
  }
}

class BcViewerInstagram extends StatefulWidget {
  final String? url;
  final bool captioned;
  final String? title;
  final Widget? errorFallback;

  const BcViewerInstagram({
    super.key,
    this.url,
    this.captioned = true,
    this.title,
    this.errorFallback,
  });

  @override
  State<BcViewerInstagram> createState() => BcViewerInstagramState();
}
