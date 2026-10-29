library bc_carousel;

import 'dart:async';

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Single slide in a [BcCarousel].
///
/// Mirrors TS `BcCarouselSlide` ({ image?, alt?, caption? }).
class BcCarouselSlide {
  final String? image;
  final String? alt;
  final String? caption;

  const BcCarouselSlide({
    this.image,
    this.alt,
    this.caption,
  });
}

/// Color used for active indicator dots, exposed for test assertions.
class BcCarouselActiveDotColor {
  BcCarouselActiveDotColor._();
  static const Color value = BcTheme.primary;
}

/// Image / content carousel with autoplay, prev/next navigation and
/// indicator dots (ADR-011 Phase 5c — M5 data display).
///
/// Controlled mode: the parent provides [index]; tapping prev/next/dot
/// fires [onSlideChange] but does not change the displayed slide until
/// the parent updates the prop. Uncontrolled mode: [index] is null and
/// [defaultIndex] seeds the initial state; interactions update internally.
///
/// When [autoplay] is true a periodic [Timer] advances to the next slide
/// on each [interval] tick. The timer pauses when [autoplay] is false and
/// is cancelled on dispose.
class BcCarousel extends StatefulWidget {
  final List<BcCarouselSlide> slides;
  final int? index;
  final int defaultIndex;
  final bool arrows;
  final bool dots;
  final bool autoplay;
  final Duration interval;
  final double aspectRatio;
  final void Function(int index, BcChangeMeta meta)? onSlideChange;

  const BcCarousel({
    super.key,
    required this.slides,
    this.index,
    this.defaultIndex = 0,
    this.arrows = true,
    this.dots = true,
    this.autoplay = false,
    this.interval = const Duration(seconds: 4),
    this.aspectRatio = 16 / 9,
    this.onSlideChange,
  });

  @override
  State<BcCarousel> createState() => _BcCarouselState();
}

class _BcCarouselState extends State<BcCarousel> {
  int? _internalIndex;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.index == null) {
      _internalIndex = _clamp(widget.defaultIndex);
    }
    _startTimer();
  }

  @override
  void didUpdateWidget(BcCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index == null && oldWidget.index != null) {
      _internalIndex = _clamp(widget.defaultIndex);
    }
    if (widget.autoplay != oldWidget.autoplay ||
        widget.interval != oldWidget.interval) {
      _timer?.cancel();
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (!widget.autoplay) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted) return;
      _goTo(
        (_current + 1) % widget.slides.length,
        reason: BcChangeReason.programmatic,
        source: BcEventSource.programmatic,
      );
    });
  }

  int _clamp(int v) {
    if (widget.slides.isEmpty) return 0;
    if (v < 0) return 0;
    if (v >= widget.slides.length) return widget.slides.length - 1;
    return v;
  }

  int get _current {
    final c = widget.index ?? _internalIndex ?? widget.defaultIndex;
    return _clamp(c);
  }

  void _goTo(
    int next, {
    BcChangeReason reason = BcChangeReason.select,
    BcEventSource source = BcEventSource.pointer,
  }) {
    if (widget.slides.isEmpty) return;
    final wrapped = (next + widget.slides.length) % widget.slides.length;
    if (wrapped == _current) return;

    widget.onSlideChange?.call(
      wrapped,
      BcChangeMeta(reason: reason, source: source),
    );

    if (widget.index == null) {
      setState(() => _internalIndex = wrapped);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) {
      return const SizedBox.shrink();
    }

    final current = _current;

    return ClipRRect(
      borderRadius: BorderRadius.circular(BcTheme.radius),
      child: Container(
        decoration: BoxDecoration(
          color: BcTheme.muted,
          border: Border.all(color: BcTheme.border),
        ),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: widget.aspectRatio,
              child: Stack(
                children: [
                  for (var i = 0; i < widget.slides.length; i++)
                    _buildSlide(i, current),
                ],
              ),
            ),
            if (widget.arrows && widget.slides.length > 1) ...[
              _buildArrow(
                key: 'bc_carousel_prev',
                icon: Icons.chevron_left,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 8),
                onTap: () => _goTo(current - 1),
              ),
              _buildArrow(
                key: 'bc_carousel_next',
                icon: Icons.chevron_right,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 8),
                onTap: () => _goTo(current + 1),
              ),
            ],
            if (widget.dots && widget.slides.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < widget.slides.length; i++)
                        _buildDot(i, current),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(int i, int current) {
    final slide = widget.slides[i];
    final isActive = i == current;

    return Positioned.fill(
      key: Key('bc_carousel_slide_$i'),
      child: Offstage(
        offstage: !isActive,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (slide.image != null)
              Image.network(
                slide.image!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: BcTheme.muted,
                  child: SizedBox.expand(),
                ),
              ),
            if (slide.caption != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: BcTheme.foreground.withValues(alpha: 0.6),
                  child: Text(
                    slide.caption!,
                    style: const TextStyle(
                      color: BcTheme.background,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrow({
    required String key,
    required IconData icon,
    required Alignment alignment,
    required EdgeInsets padding,
    required VoidCallback onTap,
  }) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: padding,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Material(
              color: BcTheme.background.withValues(alpha: 0.8),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: Key(key),
                onTap: onTap,
                child: Icon(icon, size: 18, color: BcTheme.foreground),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int i, int current) {
    final isActive = i == current;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: GestureDetector(
        key: Key('bc_carousel_dot_$i'),
        onTap: () => _goTo(i),
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? BcCarouselActiveDotColor.value
                : BcTheme.background.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
