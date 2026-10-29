library bc_viewer_video;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

class BcViewerVideoState extends State<BcViewerVideo> {
  bool? _internalPlaying;
  double? _internalVolume;
  double? _internalPosition;
  bool? _internalFullscreen;
  bool _loadFailed = false;

  bool get isPlaying => widget.playing ?? _internalPlaying ?? false;

  double get currentVolume => widget.volume ?? _internalVolume ?? 1.0;

  double get currentPosition =>
      widget.position ?? _internalPosition ?? 0.0;

  bool get isFullscreen =>
      widget.fullscreen ?? _internalFullscreen ?? false;

  bool get isMuted => currentVolume <= 0.0;

  double get _durationInSeconds =>
      widget.duration.inMilliseconds.toDouble();

  @override
  void initState() {
    super.initState();
    final src = widget.src;
    _loadFailed = src == null || src.isEmpty;
  }

  @override
  void didUpdateWidget(BcViewerVideo oldWidget) {
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

  void _seekTo(double position) {
    if (widget.disabled) return;
    final clamped = position.clamp(0.0, _durationInSeconds > 0 ? _durationInSeconds : double.maxFinite);

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

  void _toggleMute() {
    if (widget.disabled) return;
    final next = isMuted ? 1.0 : 0.0;

    widget.onVolumeChange?.call(
      next,
      const BcChangeMeta(
        reason: BcChangeReason.toggle,
        source: BcEventSource.pointer,
      ),
    );

    if (widget.volume == null) {
      setState(() => _internalVolume = next);
    }
  }

  void _toggleFullscreen() {
    if (widget.disabled) return;
    final next = !isFullscreen;

    widget.onFullscreenChange?.call(
      next,
      const BcChangeMeta(
        reason: BcChangeReason.toggle,
        source: BcEventSource.pointer,
      ),
    );

    if (widget.fullscreen == null) {
      setState(() => _internalFullscreen = next);
    }
  }

  Widget _buildErrorFallback() {
    return const Center(
      key: Key('bc_viewer_video_error'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: BcTheme.destructive),
          SizedBox(height: 8),
          Text(
            'Unable to load video',
            style: TextStyle(fontSize: 14, color: BcTheme.mutedForeground),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    if (_loadFailed) return _buildErrorFallback();

    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.poster != null && !isPlaying)
          Positioned.fill(
            child: Image.network(
              widget.poster!,
              key: const Key('bc_viewer_video_poster'),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: BcTheme.muted,
                child: const Center(
                  child: Icon(Icons.movie,
                      size: 48, color: BcTheme.mutedForeground),
                ),
              ),
            ),
          )
        else if (!isPlaying)
          Container(
            color: BcTheme.muted,
            child: const Center(
              child: Icon(Icons.movie,
                  size: 48, color: BcTheme.mutedForeground),
            ),
          ),
        if (!isPlaying && !widget.disabled)
          _iconBtn(
            key: 'bc_viewer_video_play_overlay',
            icon: Icons.play_arrow,
            iconSize: 48,
            onTap: _togglePlay,
          ),
      ],
    );
  }

  String _formatDuration(double seconds) {
    if (seconds <= 0) return '0:00';
    final m = (seconds / 60).floor();
    final s = (seconds % 60).floor();
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildControls() {
    if (_loadFailed) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: BcTheme.background.withValues(alpha: 0.9),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                _formatDuration(currentPosition / 1000),
                style: const TextStyle(fontSize: 12, color: BcTheme.foreground),
              ),
              Expanded(
                child: Slider(
                  key: const Key('bc_viewer_video_seek'),
                  value: currentPosition
                      .clamp(0.0, _durationInSeconds > 0 ? _durationInSeconds : 1.0),
                  min: 0.0,
                  max: _durationInSeconds > 0 ? _durationInSeconds : 1.0,
                  onChanged: widget.disabled ? null : _seekTo,
                ),
              ),
              Text(
                _formatDuration(_durationInSeconds / 1000),
                style: const TextStyle(fontSize: 12, color: BcTheme.mutedForeground),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _iconBtn(
                    key: 'bc_viewer_video_play',
                    icon: isPlaying ? Icons.pause : Icons.play_arrow,
                    onTap: widget.disabled ? null : _togglePlay,
                  ),
                  _iconBtn(
                    key: 'bc_viewer_video_mute',
                    icon: isMuted ? Icons.volume_off : Icons.volume_up,
                    onTap: widget.disabled ? null : _toggleMute,
                  ),
                ],
              ),
              _iconBtn(
                key: 'bc_viewer_video_fullscreen',
                icon: isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                onTap: widget.disabled ? null : _toggleFullscreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoWidget = ClipRRect(
      borderRadius: BorderRadius.circular(BcTheme.radius),
      child: Container(
        decoration: BoxDecoration(
          color: BcTheme.background,
          border: Border.all(color: BcTheme.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: _buildVideoArea()),
            _buildControls(),
          ],
        ),
      ),
    );

    if (widget.disabled) {
      return AbsorbPointer(child: videoWidget);
    }

    return videoWidget;
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
        color: BcTheme.foreground,
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

class BcViewerVideo extends StatefulWidget {
  final String? src;
  final String? poster;
  final bool controls;
  final bool disabled;
  final bool? playing;
  final double? volume;
  final double? position;
  final bool? fullscreen;
  final Duration duration;
  final String? type;
  final BcChangeHandler<bool>? onPlayingChange;
  final BcChangeHandler<double>? onSeekChange;
  final BcChangeHandler<double>? onVolumeChange;
  final BcChangeHandler<bool>? onFullscreenChange;

  const BcViewerVideo({
    super.key,
    this.src,
    this.poster,
    this.controls = true,
    this.disabled = false,
    this.playing,
    this.volume,
    this.position,
    this.fullscreen,
    this.duration = Duration.zero,
    this.type,
    this.onPlayingChange,
    this.onSeekChange,
    this.onVolumeChange,
    this.onFullscreenChange,
  });

  @override
  State<BcViewerVideo> createState() => BcViewerVideoState();
}
