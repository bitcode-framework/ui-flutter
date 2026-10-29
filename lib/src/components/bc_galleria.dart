library bc_galleria;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Image gallery with thumbnails, main image and optional lightbox.
///
/// Mirrors TS `BcGalleria` contract and validation contract VAL-M6-023/024.
///
/// VAL-M6-023: renders N thumbnails for N images; the activeIndex image is
/// shown as the main image; tapping a thumbnail selects it. Empty images
/// list renders the emptyState and no thumbnails.
///
/// VAL-M6-024: tapping a thumbnail emits onActiveIndexChange with the new
/// index (clamped to [0, N-1]) and a BcChangeMeta (pointer source). Opening
/// the lightbox emits onLightboxChange with true; closing emits false. When
/// disabled, thumbnails are non-interactive and the lightbox cannot open.
class BcGalleria extends StatefulWidget {
  final List<BcGalleriaItem> images;
  final int? activeIndex;
  final int defaultActiveIndex;
  final bool disabled;
  final bool lightboxEnabled;
  final String emptyText;
  final double aspectRatio;
  final double thumbnailSize;
  final BcChangeHandler<int>? onActiveIndexChange;
  final BcChangeHandler<bool>? onLightboxChange;

  const BcGalleria({
    super.key,
    this.images = const [],
    this.activeIndex,
    this.defaultActiveIndex = 0,
    this.disabled = false,
    this.lightboxEnabled = true,
    this.emptyText = 'No images',
    this.aspectRatio = 16 / 9,
    this.thumbnailSize = 64,
    this.onActiveIndexChange,
    this.onLightboxChange,
  });

  @override
  State<BcGalleria> createState() => _BcGalleriaState();
}

class _BcGalleriaState extends State<BcGalleria> {
  int? _internalActive;
  bool? _internalLightboxOpen;

  @override
  void initState() {
    super.initState();
    if (widget.activeIndex == null) {
      _internalActive = _clamp(widget.defaultActiveIndex);
    }
  }

  int _clamp(int v) {
    if (widget.images.isEmpty) return 0;
    if (v < 0) return 0;
    if (v >= widget.images.length) return widget.images.length - 1;
    return v;
  }

  int get _current => _clamp(
      widget.activeIndex ?? _internalActive ?? widget.defaultActiveIndex);

  bool get _isLightboxOpen =>
      widget.lightboxEnabled &&
      (_internalLightboxOpen ?? false);

  void _selectThumbnail(int index) {
    if (widget.disabled) return;
    final clamped = _clamp(index);
    if (clamped == _current) return;

    widget.onActiveIndexChange?.call(
      clamped,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );

    if (widget.activeIndex == null) {
      setState(() => _internalActive = clamped);
    }
  }

  void _openLightbox() {
    if (widget.disabled || !widget.lightboxEnabled) return;
    widget.onLightboxChange?.call(
      true,
      const BcChangeMeta(
        reason: BcChangeReason.toggle,
        source: BcEventSource.pointer,
      ),
    );
    setState(() => _internalLightboxOpen = true);
  }

  void _closeLightbox() {
    widget.onLightboxChange?.call(
      false,
      const BcChangeMeta(
        reason: BcChangeReason.overlayClick,
        source: BcEventSource.pointer,
      ),
    );
    setState(() => _internalLightboxOpen = false);
  }

  Widget _buildEmpty() {
    return Center(
      key: const ValueKey<String>('bc_galleria_empty'),
      child: Text(
        widget.emptyText,
        style: const TextStyle(
          fontSize: 14,
          color: BcTheme.mutedForeground,
        ),
      ),
    );
  }

  Widget _buildMainImage() {
    final current = _current;
    final item = widget.images[current];

    return GestureDetector(
      key: const Key('bc_galleria_main'),
      onTap: _openLightbox,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            item.src,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: BcTheme.muted,
              child: Center(
                child: Icon(Icons.broken_image_outlined,
                    size: 48, color: BcTheme.mutedForeground),
              ),
            ),
          ),
          if (item.caption != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                color: BcTheme.foreground.withValues(alpha: 0.6),
                child: Text(
                  item.caption!,
                  style: const TextStyle(
                    color: BcTheme.background,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(int index) {
    final item = widget.images[index];
    final isActive = index == _current;
    final thumbSrc = item.thumbnail ?? item.src;

    return GestureDetector(
      key: Key('bc_galleria_thumb_$index'),
      onTap: widget.disabled ? null : () => _selectThumbnail(index),
      child: Container(
        width: widget.thumbnailSize,
        height: widget.thumbnailSize,
        decoration: BoxDecoration(
          border: Border.all(
            color: isActive ? BcTheme.primary : BcTheme.border,
            width: isActive ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(BcTheme.radius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(BcTheme.radius),
          child: Image.network(
            thumbSrc,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: BcTheme.muted,
              child: Center(
                child: Icon(Icons.image_not_supported_outlined,
                    size: 20, color: BcTheme.mutedForeground),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnails() {
    return SizedBox(
      height: widget.thumbnailSize + 4,
      child: ListView.separated(
        key: const ValueKey<String>('bc_galleria_thumbnails'),
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) => _buildThumbnail(index),
      ),
    );
  }

  Widget _buildLightboxOverlay() {
    final current = _current;
    final item = widget.images[current];

    return Positioned.fill(
      key: const Key('bc_galleria_lightbox'),
      child: Material(
        color: BcTheme.backgroundDark.withValues(alpha: 0.9),
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeLightbox,
                child: Center(
                  child: InteractiveViewer(
                    child: Image.network(
                      item.src,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image_outlined,
                            size: 64, color: BcTheme.mutedForeground),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                key: const Key('bc_galleria_lightbox_close'),
                icon: const Icon(Icons.close,
                    color: BcTheme.foregroundDark),
                onPressed: _closeLightbox,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return _buildEmpty();
    }

    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(BcTheme.radius),
              child: Container(
                decoration: BoxDecoration(
                  color: BcTheme.muted,
                  border: Border.all(color: BcTheme.border),
                ),
                child: AspectRatio(
                  aspectRatio: widget.aspectRatio,
                  child: _buildMainImage(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildThumbnails(),
          ],
        ),
        if (_isLightboxOpen) _buildLightboxOverlay(),
      ],
    );
  }
}
