library bc_viewer_pdf;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

class BcViewerPdfState extends State<BcViewerPdf> {
  int? _internalPage;
  double? _internalZoom;

  int get currentPage {
    final raw = widget.page ?? _internalPage ?? widget.defaultPage;
    return _clampPage(raw);
  }

  double get currentZoom {
    final raw = widget.zoom ?? _internalZoom ?? widget.defaultZoom;
    return _clampZoom(raw);
  }

  int _clampPage(int p) {
    if (p < 1) return 1;
    final max = widget.pageCount;
    if (p > max) return max;
    return p;
  }

  double _clampZoom(double z) {
    if (z < widget.minZoom) return widget.minZoom;
    if (z > widget.maxZoom) return widget.maxZoom;
    return z;
  }

  void _goToPage(int next, {BcEventSource source = BcEventSource.pointer}) {
    final clamped = _clampPage(next);
    if (clamped == currentPage) return;

    widget.onPageChange?.call(
      clamped,
      BcChangeMeta(
        reason: BcChangeReason.select,
        source: source,
      ),
    );

    if (widget.page == null) {
      setState(() => _internalPage = clamped);
    }
  }

  void _changeZoom(double next,
      {BcEventSource source = BcEventSource.pointer}) {
    final clamped = _clampZoom(next);

    widget.onZoomChange?.call(
      clamped,
      BcChangeMeta(
        reason: BcChangeReason.input,
        source: source,
      ),
    );

    if (widget.zoom == null) {
      setState(() => _internalZoom = clamped);
    }
  }

  void setZoom(double value) {
    _changeZoom(value, source: BcEventSource.programmatic);
  }

  void setPage(int page) {
    _goToPage(page, source: BcEventSource.programmatic);
  }

  void nextPage() {
    _goToPage(currentPage + 1);
  }

  void prevPage() {
    _goToPage(currentPage - 1);
  }

  @override
  void didUpdateWidget(BcViewerPdf oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.page == null && oldWidget.page != null) {
      _internalPage = _clampPage(widget.defaultPage);
    }
    if (widget.zoom == null && oldWidget.zoom != null) {
      _internalZoom = _clampZoom(widget.defaultZoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = currentPage;
    final zoom = currentZoom;
    final atFirst = page <= 1;
    final atLast = page >= widget.pageCount;

    return ClipRRect(
      borderRadius: BorderRadius.circular(BcTheme.radius),
      child: Container(
        decoration: BoxDecoration(
          color: BcTheme.background,
          border: Border.all(color: BcTheme.border),
        ),
        child: Column(
          children: [
            _buildToolbar(page, zoom, atFirst, atLast),
            Expanded(child: _buildContent(page, zoom)),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(
    int page,
    double zoom,
    bool atFirst,
    bool atLast,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: BcTheme.muted,
        border: Border(bottom: BorderSide(color: BcTheme.border)),
      ),
      child: Row(
        children: [
          _toolbarButton(
            key: 'bc_viewer_pdf_prev',
            icon: Icons.chevron_left,
            onTap: atFirst ? null : prevPage,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Page $page of ${widget.pageCount}',
              key: const Key('bc_viewer_pdf_page_label'),
              style: const TextStyle(
                fontSize: 13,
                color: BcTheme.foreground,
              ),
            ),
          ),
          _toolbarButton(
            key: 'bc_viewer_pdf_next',
            icon: Icons.chevron_right,
            onTap: atLast ? null : nextPage,
          ),
          const Spacer(),
          _toolbarButton(
            key: 'bc_viewer_pdf_zoom_out',
            icon: Icons.zoom_out,
            onTap: () => _changeZoom(zoom - widget.zoomStep),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '${(zoom * 100).round()}%',
              key: const Key('bc_viewer_pdf_zoom_label'),
              style: const TextStyle(
                fontSize: 13,
                color: BcTheme.foreground,
              ),
            ),
          ),
          _toolbarButton(
            key: 'bc_viewer_pdf_zoom_in',
            icon: Icons.zoom_in,
            onTap: () => _changeZoom(zoom + widget.zoomStep),
          ),
        ],
      ),
    );
  }

  Widget _toolbarButton({
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

  Widget _buildContent(int page, double zoom) {
    return Container(
      key: Key('bc_viewer_pdf_page_${page}_zoom_${zoom.toStringAsFixed(2)}'),
      color: BcTheme.background,
      child: Center(
        child: InteractiveViewer(
          minScale: widget.minZoom,
          maxScale: widget.maxZoom,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(minWidth: 200, minHeight: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.picture_as_pdf,
                  size: 48,
                  color: BcTheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: BcTheme.mutedForeground,
                  ),
                ),
                Text(
                  'Page $page',
                  style: const TextStyle(
                    fontSize: 12,
                    color: BcTheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BcViewerPdf extends StatefulWidget {
  final String? src;
  final int? page;
  final int defaultPage;
  final int pageCount;
  final double? zoom;
  final double defaultZoom;
  final double minZoom;
  final double maxZoom;
  final double zoomStep;
  final String title;
  final bool toolbar;
  final BcChangeHandler<int>? onPageChange;
  final BcChangeHandler<double>? onZoomChange;

  const BcViewerPdf({
    super.key,
    this.src,
    this.page,
    this.defaultPage = 1,
    this.pageCount = 1,
    this.zoom,
    this.defaultZoom = 1.0,
    this.minZoom = 0.5,
    this.maxZoom = 3.0,
    this.zoomStep = 0.25,
    this.title = 'PDF document',
    this.toolbar = true,
    this.onPageChange,
    this.onZoomChange,
  });

  @override
  State<BcViewerPdf> createState() => BcViewerPdfState();
}
