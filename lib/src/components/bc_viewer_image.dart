library bc_viewer_image;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

enum BcViewerImageFit {
  cover,
  contain,
  fill,
  none;

  BoxFit get boxFit {
    switch (this) {
      case BcViewerImageFit.cover:
        return BoxFit.cover;
      case BcViewerImageFit.contain:
        return BoxFit.contain;
      case BcViewerImageFit.fill:
        return BoxFit.fill;
      case BcViewerImageFit.none:
        return BoxFit.none;
    }
  }
}

class BcViewerImageState extends State<BcViewerImage> {
  double? _internalZoom;
  Offset? _internalPan;
  bool? _internalFullscreen;
  bool _loadFailed = false;
  bool _isLoading = true;
  bool _resolved = false;
  ImageProvider? _imageProvider;
  ImageStream? _imageStream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    final src = widget.src;
    if (src == null || src.isEmpty) {
      _isLoading = false;
      _loadFailed = true;
    } else {
      _imageProvider = NetworkImage(src);
    }
  }

  void _onResolveImage(ImageInfo info, bool syncCall) {
    if (syncCall) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isLoading) {
          setState(() {
            _isLoading = false;
            _resolved = true;
          });
        }
      });
    } else if (mounted && _isLoading) {
      setState(() {
        _isLoading = false;
        _resolved = true;
      });
    }
  }

  void _onResolveError(Object exception, StackTrace? stackTrace) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _loadFailed = true;
          _isLoading = false;
        });
      }
    });
  }

  void _tryResolveImage() {
    if (_imageProvider == null || _resolved || _loadFailed) return;

    final oldStream = _imageStream;
    final newStream =
        _imageProvider!.resolve(createLocalImageConfiguration(context));

    if (oldStream == newStream) return;

    if (_listener != null && oldStream != null) {
      oldStream.removeListener(_listener!);
    }

    _listener = ImageStreamListener(
      _onResolveImage,
      onError: _onResolveError,
    );
    newStream.addListener(_listener!);
    _imageStream = newStream;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tryResolveImage();
  }

  double get currentZoom {
    final raw = widget.zoom ?? _internalZoom ?? 1.0;
    return _clampZoom(raw);
  }

  Offset get currentPan => widget.pan ?? _internalPan ?? Offset.zero;

  bool get currentFullscreen =>
      widget.fullscreen ?? _internalFullscreen ?? false;

  double _clampZoom(double z) {
    if (z < widget.minZoom) return widget.minZoom;
    if (z > widget.maxZoom) return widget.maxZoom;
    return z;
  }

  void setZoom(double value,
      {BcEventSource source = BcEventSource.programmatic}) {
    if (widget.disabled) return;
    final clamped = _clampZoom(value);
    widget.onZoomChange?.call(
      clamped,
      BcChangeMeta(reason: BcChangeReason.input, source: source),
    );
    if (widget.zoom == null) {
      setState(() => _internalZoom = clamped);
    }
  }

  void setPan(Offset offset,
      {BcEventSource source = BcEventSource.programmatic}) {
    if (widget.disabled) return;
    widget.onPanChange?.call(
      offset,
      BcChangeMeta(reason: BcChangeReason.input, source: source),
    );
    if (widget.pan == null) {
      setState(() => _internalPan = offset);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.disabled) return;
    if (currentZoom <= 1.0) return;
    setPan(currentPan + details.delta, source: BcEventSource.pointer);
  }

  void _toggleFullscreen() {
    if (widget.disabled) return;
    final next = !currentFullscreen;
    widget.onFullscreenChange?.call(
      next,
      const BcChangeMeta(
          reason: BcChangeReason.toggle,
          source: BcEventSource.pointer),
    );
    if (widget.fullscreen == null) {
      setState(() => _internalFullscreen = next);
    }
  }

  @override
  void didUpdateWidget(BcViewerImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.src != oldWidget.src) {
      final src = widget.src;
      if (src == null || src.isEmpty) {
        _isLoading = false;
        _loadFailed = true;
        _resolved = false;
        _imageProvider = null;
      } else {
        _isLoading = true;
        _loadFailed = false;
        _resolved = false;
        _imageProvider = NetworkImage(src);
      }
    }
  }

  @override
  void dispose() {
    if (_listener != null && _imageStream != null) {
      _imageStream!.removeListener(_listener!);
    }
    super.dispose();
  }

  Widget _buildPlaceholder() {
    final p = widget.placeholder;
    if (p != null) {
      return KeyedSubtree(
        key: const Key('bc_viewer_image_placeholder'),
        child: Center(child: p),
      );
    }
    return const Center(
      key: Key('bc_viewer_image_placeholder'),
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: BcTheme.mutedForeground,
        ),
      ),
    );
  }

  Widget _buildErrorFallback() {
    final e = widget.errorFallback;
    if (e != null) return Center(child: e);
    return const Center(
      key: Key('bc_viewer_image_error'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_outlined,
              size: 48, color: BcTheme.mutedForeground),
          SizedBox(height: 8),
          Text(
            'Failed to load image',
            style: TextStyle(
                fontSize: 13, color: BcTheme.mutedForeground),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWidget() {
    final src = widget.src;
    if (src == null || src.isEmpty || _loadFailed) {
      return _buildErrorFallback();
    }

    if (_isLoading) {
      return _buildPlaceholder();
    }

    return Image(
      image: _imageProvider!,
      fit: widget.fit.boxFit,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorFallback();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final zoom = currentZoom;
    final pan = currentPan;

    Widget content = GestureDetector(
      key: const Key('bc_viewer_image_content'),
      onPanUpdate: _onPanUpdate,
      child: Transform.translate(
        offset: pan,
        child: Transform.scale(
          scale: zoom,
          child: _buildContentWidget(),
        ),
      ),
    );

    if (widget.alt != null && widget.alt!.isNotEmpty) {
      content = Semantics(
        label: widget.alt,
        image: true,
        child: ExcludeSemantics(child: content),
      );
    }

    final toolbarButtons = <Widget>[];

    if (widget.zoomable && !widget.disabled) {
      toolbarButtons.add(_iconBtn(
        key: 'bc_viewer_image_zoom_in',
        icon: Icons.zoom_in,
        onTap: () => setZoom(zoom + widget.zoomStep,
            source: BcEventSource.pointer),
      ));
      toolbarButtons.add(_iconBtn(
        key: 'bc_viewer_image_zoom_out',
        icon: Icons.zoom_out,
        onTap: () => setZoom(zoom - widget.zoomStep,
            source: BcEventSource.pointer),
      ));
    }

    toolbarButtons.add(_iconBtn(
      key: 'bc_viewer_image_fullscreen',
      icon: currentFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
      onTap: widget.disabled ? null : _toggleFullscreen,
    ));

    return ClipRRect(
      borderRadius: BorderRadius.circular(BcTheme.radius),
      child: Container(
        decoration: BoxDecoration(
          color: BcTheme.muted,
          border: Border.all(color: BcTheme.border),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: content),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: BcTheme.background.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(BcTheme.radius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: toolbarButtons,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn({
    required String key,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        key: Key(key),
        icon: Icon(icon, size: 18),
        color: BcTheme.foreground,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        onPressed: onTap,
      ),
    );
  }
}

class BcViewerImage extends StatefulWidget {
  final String? src;
  final String? alt;
  final BcViewerImageFit fit;
  final bool zoomable;
  final bool disabled;
  final double? zoom;
  final Offset? pan;
  final bool? fullscreen;
  final double minZoom;
  final double maxZoom;
  final double zoomStep;
  final Widget? placeholder;
  final Widget? errorFallback;
  final BcChangeHandler<double>? onZoomChange;
  final BcChangeHandler<Offset>? onPanChange;
  final BcChangeHandler<bool>? onFullscreenChange;

  const BcViewerImage({
    super.key,
    this.src,
    this.alt,
    this.fit = BcViewerImageFit.contain,
    this.zoomable = false,
    this.disabled = false,
    this.zoom,
    this.pan,
    this.fullscreen,
    this.minZoom = 0.5,
    this.maxZoom = 5.0,
    this.zoomStep = 0.5,
    this.placeholder,
    this.errorFallback,
    this.onZoomChange,
    this.onPanChange,
    this.onFullscreenChange,
  });

  @override
  State<BcViewerImage> createState() => BcViewerImageState();
}
