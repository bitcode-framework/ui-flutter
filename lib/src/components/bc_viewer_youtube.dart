library bc_viewer_youtube;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

class BcViewerYoutubeState extends State<BcViewerYoutube> {
  bool? _internalPlaying;

  bool get isPlaying => widget.playing ?? _internalPlaying ?? false;

  String get extractedVideoId {
    final input = widget.videoId;
    if (input == null || input.isEmpty) return '';

    final patterns = [
      RegExp(r'(?:v=)([A-Za-z0-9_-]{11})'),
      RegExp(r'(?:youtu\.be/)([A-Za-z0-9_-]{11})'),
      RegExp(r'(?:embed/)([A-Za-z0-9_-]{11})'),
    ];

    for (final p in patterns) {
      final match = p.firstMatch(input);
      if (match != null) return match.group(1)!;
    }

    return input;
  }

  bool get _isValid => extractedVideoId.length == 11;

  String get embedUrl {
    final id = extractedVideoId;
    final params = <String>[];
    if (!widget.controls) params.add('controls=0');
    if (widget.autoplay) params.add('autoplay=1');
    if (widget.start > 0) params.add('start=${widget.start}');
    final qs = params.isNotEmpty ? '?${params.join('&')}' : '';
    return 'https://www.youtube-nocookie.com/embed/$id$qs';
  }

  void _togglePlay() {
    if (widget.disabled) return;
    final next = !isPlaying;

    widget.onPlayingChange?.call(
      next,
      const BcChangeMeta(
        reason: BcChangeReason.toggle,
        source: BcEventSource.pointer,
      ),
    );

    if (widget.playing == null) {
      setState(() => _internalPlaying = next);
    }
  }

  Widget _buildErrorFallback() {
    return const Center(
      key: Key('bc_viewer_youtube_error'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: BcTheme.destructive),
          SizedBox(height: 8),
          Text(
            'Invalid or missing video ID',
            style: TextStyle(fontSize: 14, color: BcTheme.mutedForeground),
          ),
        ],
      ),
    );
  }

  Widget _buildEmbed() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          key: const Key('bc_viewer_youtube_embed'),
          width: double.infinity,
          height: double.infinity,
          color: BcTheme.muted,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_circle_filled,
                    size: 64, color: BcTheme.primary),
                const SizedBox(height: 8),
                Text(
                  widget.title ?? 'YouTube video',
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
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              key: const Key('bc_viewer_youtube_play'),
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: BcTheme.primaryForeground,
              ),
              style: IconButton.styleFrom(
                backgroundColor: BcTheme.primary,
              ),
              onPressed: widget.disabled ? null : _togglePlay,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValid) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(BcTheme.radius),
        child: Container(
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
        decoration: BoxDecoration(
          color: BcTheme.background,
          border: Border.all(color: BcTheme.border),
        ),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: _buildEmbed(),
        ),
      ),
    );

    if (widget.title != null && widget.title!.isNotEmpty) {
      return Semantics(
        label: widget.title,
        child: content,
      );
    }

    return content;
  }
}

class BcViewerYoutube extends StatefulWidget {
  final String? videoId;
  final bool controls;
  final bool autoplay;
  final int start;
  final String? title;
  final bool disabled;
  final bool? playing;
  final BcChangeHandler<bool>? onPlayingChange;

  const BcViewerYoutube({
    super.key,
    this.videoId,
    this.controls = true,
    this.autoplay = false,
    this.start = 0,
    this.title,
    this.disabled = false,
    this.playing,
    this.onPlayingChange,
  });

  @override
  State<BcViewerYoutube> createState() => BcViewerYoutubeState();
}
