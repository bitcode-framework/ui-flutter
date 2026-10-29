library bc_viewer_tiktok;

import 'package:flutter/material.dart';
import '../theme/bc_theme.dart';

/// Fallback embed height, mirroring the web adapter's `height: '600px'`
/// default. Used when the host provides no bounded height.
const double _defaultEmbedHeight = 600;

class BcViewerTiktokState extends State<BcViewerTiktok> {
  String get extractedVideoId {
    final input = widget.videoId;
    if (input == null || input.isEmpty) return '';

    final match = RegExp(r'/video/(\d+)').firstMatch(input);
    if (match != null) return match.group(1)!;

    return input;
  }

  bool get _isValidId {
    final id = extractedVideoId;
    return id.isNotEmpty;
  }

  String get embedUrl {
    return 'https://www.tiktok.com/embed/v2/$extractedVideoId';
  }

  Widget _buildErrorFallback() {
    final e = widget.errorFallback;
    if (e != null) return Center(child: e);
    return const Center(
      key: Key('bc_viewer_tiktok_error'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: BcTheme.destructive),
          SizedBox(height: 8),
          Text(
            'Unable to embed TikTok video',
            style: TextStyle(fontSize: 14, color: BcTheme.mutedForeground),
          ),
        ],
      ),
    );
  }

  Widget _buildEmbed() {
    return Container(
      key: const Key('bc_viewer_tiktok_embed'),
      width: double.infinity,
      color: BcTheme.muted,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.music_note, size: 48, color: BcTheme.primary),
            const SizedBox(height: 8),
            Text(
              widget.title ?? 'TikTok video',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: BcTheme.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Video ID: $extractedVideoId',
              style: const TextStyle(
                fontSize: 12,
                color: BcTheme.mutedForeground,
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

        if (!_isValidId) {
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

class BcViewerTiktok extends StatefulWidget {
  final String? videoId;
  final String? title;
  final Widget? errorFallback;

  const BcViewerTiktok({
    super.key,
    this.videoId,
    this.title,
    this.errorFallback,
  });

  @override
  State<BcViewerTiktok> createState() => BcViewerTiktokState();
}
