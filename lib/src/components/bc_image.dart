library bc_image;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Image widget with lazy loading, placeholder, error fallback and tap.
///
/// Mirrors TS `BcImage` contract and validation contract VAL-M6-025/026.
///
/// Loading lifecycle (VAL-M6-025):
///  1. When [lazy] is true the placeholder is shown until the widget enters
///     the viewport (via [VisibilityDetector]-free manual flag driven by the
///     [loadTrigger] callback or a post-frame flip). When [lazy] is false
///     loading begins immediately on mount.
///  2. While loading, [placeholder] (or a default spinner) renders.
///  3. On success the resolved image replaces the placeholder.
///  4. On failure [errorFallback] (or a default broken-image widget) renders.
///
/// Tap (VAL-M6-026): when [interactive] is true (or [onClick] is provided)
/// tapping the image fires [onClick] with a [BcChangeMeta] whose source is
/// pointer. When [disabled] is true (or no handler) tapping does nothing.
/// The image still renders (placeholder/error/content) regardless.
class BcImage extends StatefulWidget {
  final String? src;
  final String? alt;
  final double? width;
  final double? height;
  final BcImageFit fit;
  final bool rounded;
  final bool lazy;
  final bool interactive;
  final bool disabled;
  final Widget? placeholder;
  final Widget? errorFallback;
  final BcChangeHandler<void>? onClick;

  const BcImage({
    super.key,
    this.src,
    this.alt,
    this.width,
    this.height,
    this.fit = BcImageFit.cover,
    this.rounded = false,
    this.lazy = false,
    this.interactive = false,
    this.disabled = false,
    this.placeholder,
    this.errorFallback,
    this.onClick,
  });

  @override
  State<BcImage> createState() => _BcImageState();
}

class _BcImageState extends State<BcImage> {
  bool _isLoading = true;
  bool _loadFailed = false;
  bool _resolved = false;
  bool _enteredView = false;
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

    if (!widget.lazy) {
      _enteredView = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _beginLoadIfNeeded();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _enteredView = true);
          _beginLoadIfNeeded();
        }
      });
    }
  }

  void _beginLoadIfNeeded() {
    if (!_enteredView) return;
    if (_imageProvider == null || _resolved || _loadFailed) return;

    final oldStream = _imageStream;
    final newStream =
        _imageProvider!.resolve(createLocalImageConfiguration(context));

    if (oldStream == newStream) return;

    if (_listener != null && oldStream != null) {
      oldStream.removeListener(_listener!);
    }

    _listener = ImageStreamListener(_onResolveImage, onError: _onResolveError);
    newStream.addListener(_listener!);
    _imageStream = newStream;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.lazy || _enteredView) {
      _beginLoadIfNeeded();
    }
  }

  @override
  void didUpdateWidget(BcImage oldWidget) {
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
        _beginLoadIfNeeded();
      }
    }
    if (widget.lazy != oldWidget.lazy && !widget.lazy) {
      _enteredView = true;
      _beginLoadIfNeeded();
    }
  }

  @override
  void dispose() {
    if (_listener != null && _imageStream != null) {
      _imageStream!.removeListener(_listener!);
    }
    super.dispose();
  }

  bool get _isInteractive =>
      !widget.disabled && (widget.interactive || widget.onClick != null);

  void _onTap() {
    if (!_isInteractive) return;
    widget.onClick?.call(
      null,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
  }

  Widget _buildPlaceholder() {
    final p = widget.placeholder;
    if (p != null) {
      return KeyedSubtree(
        key: const Key('bc_image_placeholder'),
        child: Center(child: p),
      );
    }
    return const Center(
      key: Key('bc_image_placeholder'),
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
      key: Key('bc_image_error'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_outlined,
              size: 40, color: BcTheme.mutedForeground),
          SizedBox(height: 6),
          Text(
            'Failed to load image',
            style: TextStyle(fontSize: 12, color: BcTheme.mutedForeground),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
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
      width: widget.width,
      height: widget.height,
      errorBuilder: (context, error, stackTrace) => _buildErrorFallback(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = _buildContent();

    if (widget.alt != null && widget.alt!.isNotEmpty) {
      content = Semantics(
        label: widget.alt,
        image: true,
        child: ExcludeSemantics(child: content),
      );
    }

    final box = SizedBox(
      width: widget.width,
      height: widget.height,
      child: content,
    );

    final decorated = widget.rounded
        ? ClipRRect(
            borderRadius: BorderRadius.circular(BcTheme.radius),
            child: box,
          )
        : box;

    if (_isInteractive) {
      return GestureDetector(
        key: const Key('bc_image_tap'),
        onTap: _onTap,
        child: decorated,
      );
    }
    return decorated;
  }
}
