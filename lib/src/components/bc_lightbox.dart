library bc_lightbox;

import 'package:flutter/material.dart';

import '../core/bc_i18n.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Media type for a [BcLightboxItem].
enum BcLightboxMediaType { image, video }

/// A single media item displayed in the lightbox.
class BcLightboxItem {
  final String src;
  final BcLightboxMediaType type;
  final String? alt;
  final String? caption;

  const BcLightboxItem({
    required this.src,
    this.type = BcLightboxMediaType.image,
    this.alt,
    this.caption,
  });

  /// Convenience constructor for an image item.
  const BcLightboxItem.image(this.src, {this.alt, this.caption})
      : type = BcLightboxMediaType.image;

  /// Convenience constructor for a video item.
  const BcLightboxItem.video(this.src, {this.alt, this.caption})
      : type = BcLightboxMediaType.video;
}

/// Full-screen image/video gallery (ADR-006 Adapt POC, ADR-011).
///
/// Controlled-open widget built on a [PageView] for swipe navigation. The
/// overlay renders a dark scrim with the active media centered, prev/next
/// chevrons, and a close button. Semantics mirror the web contract:
/// role=dialog, aria-modal, keyboard nav (handled by the host on web).
///
/// Consumer drives `open` (controlled) and observes [onOpenChange] /
/// [onIndexChange]. The widget is dependency-free: video playback is
/// delegated to the caller via [videoBuilder] (defaults to a placeholder
/// documenting the requirement for a video plugin).
class BcLightbox extends StatefulWidget {
  /// Controlled open state. When non-null the widget is controlled.
  final bool? open;

  /// Initial open state for uncontrolled mode.
  final bool defaultOpen;

  /// Media items to display.
  final List<BcLightboxItem> items;

  /// Controlled active index. When non-null the widget is controlled.
  final int? index;

  /// Initial active index for uncontrolled mode.
  final int defaultIndex;

  /// Show the close button. Default true.
  final bool closable;

  /// Optional builder to render video items (delegated to caller, e.g. via
  /// `video_player` / `chewie`). Defaults to a placeholder Text.
  final Widget Function(String src)? videoBuilder;

  /// Called when the open state changes (overlay click, close button, escape).
  final void Function(bool open, BcChangeMeta meta)? onOpenChange;

  /// Called when the active index changes (swipe, prev/next).
  final void Function(int index, BcChangeMeta meta)? onIndexChange;

  const BcLightbox({
    super.key,
    this.open,
    this.defaultOpen = false,
    required this.items,
    this.index,
    this.defaultIndex = 0,
    this.closable = true,
    this.videoBuilder,
    this.onOpenChange,
    this.onIndexChange,
  });

  @override
  State<BcLightbox> createState() => _BcLightboxState();
}

class _BcLightboxState extends State<BcLightbox> {
  late int _internalIndex;
  bool _internalOpen = false;

  bool get _isControlledOpen => widget.open != null;
  bool get _isOpen => _isControlledOpen ? widget.open! : _internalOpen;

  bool get _isControlledIndex => widget.index != null;
  int get _currentIndex {
    final max = (widget.items.isEmpty ? 0 : widget.items.length - 1);
    final v = _isControlledIndex ? widget.index! : _internalIndex;
    return v.clamp(0, max);
  }

  @override
  void initState() {
    super.initState();
    _internalIndex = widget.defaultIndex;
    _internalOpen = widget.defaultOpen;
  }

  void _setOpen(bool next, BcChangeReason reason, BcEventSource source) {
    if (!_isControlledOpen) {
      setState(() => _internalOpen = next);
    }
    widget.onOpenChange?.call(next, BcChangeMeta(reason: reason, source: source));
  }

  void _setIndex(int next, BcChangeReason reason, BcEventSource source) {
    final max = (widget.items.isEmpty ? 0 : widget.items.length - 1);
    final clamped = next.clamp(0, max);
    if (!_isControlledIndex) {
      setState(() => _internalIndex = clamped);
    }
    widget.onIndexChange?.call(clamped, BcChangeMeta(reason: reason, source: source));
  }

  Widget _buildItem(BcLightboxItem item) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        if (item.type == BcLightboxMediaType.image)
          Image.network(
            item.src,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              key: const Key('bc-lightbox-media-placeholder'),
              constraints: const BoxConstraints(maxHeight: 300),
              color: BcTheme.muted,
              alignment: Alignment.center,
              child: Text(
                item.alt ?? 'Image',
                key: const Key('bc-lightbox-media'),
                style: const TextStyle(color: BcTheme.mutedForeground),
              ),
            ),
          )
        else
          (widget.videoBuilder ?? _defaultVideoBuilder).call(item.src),
        if (item.caption != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              item.caption!,
              key: const Key('bc-lightbox-caption'),
              style: const TextStyle(color: BcTheme.mutedForeground, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
      ],
      ),
    );
  }

  Widget _defaultVideoBuilder(String src) {
    return Container(
      key: const Key('bc-lightbox-video-placeholder'),
      height: 240,
      width: double.infinity,
      color: Colors.black,
      alignment: Alignment.center,
      child: const Text(
        'Video: provide videoBuilder (e.g. video_player)',
        key: Key('bc-lightbox-media'),
        style: TextStyle(color: BcTheme.mutedForeground, fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOpen) return const SizedBox.shrink();

    final controller = PageController(initialPage: _currentIndex);

    return Semantics(
      label: bcI18n.t('bc.lightbox.dialogAriaLabel'),
      container: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            key: const Key('bc-lightbox-root'),
            color: Colors.black.withValues(alpha: 0.8),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => _setOpen(false, BcChangeReason.overlayClick, BcEventSource.pointer),
                  child: SizedBox(
                    height: constraints.maxHeight.isFinite
                        ? constraints.maxHeight
                        : 400,
                    child: PageView.builder(
                      key: const Key('bc-lightbox-pageview'),
                      controller: controller,
                      itemCount: widget.items.length,
                      onPageChanged: (i) =>
                          _setIndex(i, BcChangeReason.programmatic, BcEventSource.pointer),
                      itemBuilder: (context, i) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildItem(widget.items[i]),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (widget.items.length > 1)
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: IconButton(
                          key: const Key('bc-lightbox-prev'),
                          icon: const Icon(Icons.chevron_left, color: BcTheme.mutedForeground),
                          onPressed: () {
                            final max = widget.items.length - 1;
                            final cur = _currentIndex;
                            _setIndex(cur <= 0 ? max : cur - 1, BcChangeReason.programmatic, BcEventSource.keyboard);
                          },
                        ),
                      ),
                    ),
                  ),
                if (widget.items.length > 1)
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: IconButton(
                          key: const Key('bc-lightbox-next'),
                          icon: const Icon(Icons.chevron_right, color: BcTheme.mutedForeground),
                          onPressed: () {
                            final max = widget.items.length - 1;
                            final cur = _currentIndex;
                            _setIndex(cur >= max ? 0 : cur + 1, BcChangeReason.programmatic, BcEventSource.keyboard);
                          },
                        ),
                      ),
                    ),
                  ),
                if (widget.closable)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: IconButton(
                        key: const Key('bc-lightbox-close'),
                        icon: const Icon(Icons.close, color: BcTheme.mutedForeground),
                        onPressed: () =>
                            _setOpen(false, BcChangeReason.escape, BcEventSource.pointer),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
