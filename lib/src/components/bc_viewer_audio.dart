library bc_viewer_audio;

import 'dart:math';

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';
import 'bc_web_embed.dart';

/// Height reserved for the hosted `<audio>` element on web.
///
/// A DOM host mounted via HtmlElementView has no intrinsic height, so without
/// this the player collapses to 0px and swallows the surrounding layout.
const double _webPlayerHeight = 54;

class BcViewerAudioState extends State<BcViewerAudio> {
  bool? _internalPlaying;
  double? _internalPosition;
  bool _loadFailed = false;

  bool get isPlaying => widget.playing ?? _internalPlaying ?? false;

  double get currentPosition =>
      widget.position ?? _internalPosition ?? 0.0;

  double get _durationInMs =>
      widget.duration.inMilliseconds.toDouble();

  @override
  void initState() {
    super.initState();
    final src = widget.src;
    _loadFailed = src == null || src.isEmpty;
  }

  @override
  void didUpdateWidget(BcViewerAudio oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.src != oldWidget.src) {
      final src = widget.src;
      _loadFailed = src == null || src.isEmpty;
    }
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

  void play() {
    if (widget.disabled) return;
    widget.onPlayingChange?.call(
      true,
      const BcChangeMeta(
        reason: BcChangeReason.input,
        source: BcEventSource.programmatic,
      ),
    );
    if (widget.playing == null) {
      setState(() => _internalPlaying = true);
    }
  }

  void pause() {
    if (widget.disabled) return;
    widget.onPlayingChange?.call(
      false,
      const BcChangeMeta(
        reason: BcChangeReason.input,
        source: BcEventSource.programmatic,
      ),
    );
    if (widget.playing == null) {
      setState(() => _internalPlaying = false);
    }
  }

  void seekTo(double position) {
    if (widget.disabled) return;
    final maxMs = _durationInMs > 0 ? _durationInMs : double.maxFinite;
    final clamped = position.clamp(0.0, maxMs);

    widget.onSeekChange?.call(
      clamped,
      const BcChangeMeta(
        reason: BcChangeReason.input,
        source: BcEventSource.pointer,
      ),
    );

    if (widget.position == null) {
      setState(() => _internalPosition = clamped);
    }
  }

  String _formatDuration(double ms) {
    final seconds = (ms / 1000).floor();
    final m = (seconds / 60).floor();
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildErrorFallback() {
    return const Center(
      key: Key('bc_viewer_audio_error'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: BcTheme.destructive),
          SizedBox(height: 8),
          Text(
            'Unable to load audio',
            style: TextStyle(fontSize: 14, color: BcTheme.mutedForeground),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    final progress = _durationInMs > 0 ? currentPosition / _durationInMs : 0.0;
    final bars = <double>[];
    final rng = Random(42);
    for (var i = 0; i < 40; i++) {
      bars.add(0.3 + rng.nextDouble() * 0.7);
    }

    return Container(
      key: const Key('bc_viewer_audio_waveform'),
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: List.generate(bars.length, (i) {
          final fraction = i / bars.length;
          final played = fraction <= progress;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: bars[i] * 40,
                  decoration: BoxDecoration(
                    color: played
                        ? BcTheme.primary
                        : BcTheme.mutedForeground.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent() {
    if (_loadFailed) return _buildErrorFallback();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null && widget.title!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.title!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: BcTheme.foreground,
              ),
            ),
          ),
        _buildWaveform(),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              _formatDuration(currentPosition),
              style: const TextStyle(fontSize: 12, color: BcTheme.mutedForeground),
            ),
            Expanded(
              child: Slider(
                key: const Key('bc_viewer_audio_seek'),
                value: currentPosition
                    .clamp(0.0, _durationInMs > 0 ? _durationInMs : 1.0),
                min: 0.0,
                max: _durationInMs > 0 ? _durationInMs : 1.0,
                onChanged: widget.disabled ? null : seekTo,
              ),
            ),
            Text(
              _formatDuration(_durationInMs),
              style: const TextStyle(fontSize: 12, color: BcTheme.mutedForeground),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Web parity: the React adapter renders a native <audio> element with
    // `controls`. Host a real DOM <audio> so playback actually works instead of
    // a mock waveform with no sound.
    //
    // The host element needs an explicit height: the web adapter's `<audio>` is
    // an inline element with intrinsic height, but a DOM host mounted through
    // HtmlElementView has none, and a zero-height box makes any enclosing
    // `Expanded`/`Flexible` collapse the rest of the section.
    if (bcWebEmbedSupported && !_loadFailed) {
      return SizedBox(
        height: _webPlayerHeight,
        child: BcWebMediaElement(
          key: const Key('bc_viewer_audio_element'),
          keyPrefix: 'bc_audio',
          kind: BcWebMediaKind.audio,
          src: widget.src!,
          controls: widget.controls,
          autoplay: isPlaying,
          mimeType: widget.type,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(BcTheme.radius),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: BcTheme.background,
          border: Border.all(color: BcTheme.border),
        ),
        child: Row(
          children: [
            _iconBtn(
              key: 'bc_viewer_audio_play',
              icon: isPlaying ? Icons.pause : Icons.play_arrow,
              iconSize: 32,
              onTap: widget.disabled ? null : _togglePlay,
            ),
            const SizedBox(width: 8),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn({
    required String key,
    required IconData icon,
    required VoidCallback? onTap,
    double iconSize = 24,
  }) {
    return SizedBox(
      width: iconSize + 16,
      height: iconSize + 16,
      child: IconButton(
        key: Key(key),
        icon: Icon(icon, size: iconSize),
        color: BcTheme.primary,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          minWidth: iconSize + 16,
          minHeight: iconSize + 16,
        ),
        onPressed: onTap,
      ),
    );
  }
}

class BcViewerAudio extends StatefulWidget {
  final String? src;
  final String? title;
  final bool controls;
  final bool disabled;
  final bool? playing;
  final double? position;
  final Duration duration;
  final String? type;
  final BcChangeHandler<bool>? onPlayingChange;
  final BcChangeHandler<double>? onSeekChange;

  const BcViewerAudio({
    super.key,
    this.src,
    this.title,
    this.controls = true,
    this.disabled = false,
    this.playing,
    this.position,
    this.duration = Duration.zero,
    this.type,
    this.onPlayingChange,
    this.onSeekChange,
  });

  @override
  State<BcViewerAudio> createState() => BcViewerAudioState();
}
