library bc_viewer_document;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

enum BcViewerDocumentEngine {
  office,
  google,
  native;

  String get label {
    switch (this) {
      case BcViewerDocumentEngine.office:
        return 'office';
      case BcViewerDocumentEngine.google:
        return 'google';
      case BcViewerDocumentEngine.native:
        return 'native';
    }
  }
}

const _supportedExtensions = <String>{
  'pdf',
  'doc',
  'docx',
  'xls',
  'xlsx',
  'ppt',
  'pptx',
  'odt',
  'ods',
  'odp',
  'rtf',
  'csv',
};

/// Fallback viewport height, mirroring the web adapter's `height: '600px'`
/// default. Used only when the host provides no bounded height (for example
/// when the viewer sits inside a vertical scroll view).
const double _defaultHeight = 600;

class BcViewerDocumentState extends State<BcViewerDocument> {
  int? _internalPage;
  bool _isLoading = true;
  bool _loadFailed = false;

  int get currentPage => widget.page ?? _internalPage ?? 1;

  @override
  void initState() {
    super.initState();
    _loadFailed = !_isSupportedFormat();
    if (_loadFailed) {
      _isLoading = false;
    }
  }

  @override
  void didUpdateWidget(BcViewerDocument oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.src != oldWidget.src) {
      _loadFailed = !_isSupportedFormat();
      _isLoading = !_loadFailed;
    }
  }

  bool _isSupportedFormat() {
    final src = widget.src;
    if (src == null || src.isEmpty) return false;
    final lower = src.toLowerCase();
    final dotIndex = lower.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == lower.length - 1) return false;
    final ext = lower.substring(dotIndex + 1);
    if (_supportedExtensions.contains(ext)) return true;
    final queryIndex = ext.indexOf('?');
    if (queryIndex > 0) {
      final extNoQuery = ext.substring(0, queryIndex);
      return _supportedExtensions.contains(extNoQuery);
    }
    return false;
  }

  String get viewerUrl {
    final src = widget.src ?? '';
    final encoded = Uri.encodeComponent(src);
    switch (widget.engine) {
      case BcViewerDocumentEngine.office:
        return 'https://view.officeapps.live.com/op/view.aspx?src=$encoded';
      case BcViewerDocumentEngine.google:
        return 'https://docs.google.com/gview?url=$encoded&embedded=true';
      case BcViewerDocumentEngine.native:
        return src;
    }
  }

  void _onLoadingComplete() {
    if (mounted && _isLoading) {
      setState(() => _isLoading = false);
    }
  }

  void _changePage(int next, {BcEventSource source = BcEventSource.pointer}) {
    if (widget.disabled) return;
    final clamped = next.clamp(1, widget.pageCount);

    widget.onPageChange?.call(
      clamped,
      BcChangeMeta(reason: BcChangeReason.input, source: source),
    );

    if (widget.page == null) {
      setState(() => _internalPage = clamped);
    }
  }

  void setPage(int value) {
    _changePage(value, source: BcEventSource.programmatic);
  }

  Widget _buildLoading() {
    return const Center(
      key: Key('bc_viewer_document_loading'),
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
      key: Key('bc_viewer_document_error'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: BcTheme.destructive),
          SizedBox(height: 8),
          Text(
            'Unsupported document format',
            style: TextStyle(
              fontSize: 14,
              color: BcTheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loadFailed) return _buildErrorFallback();
    if (_isLoading) {
      return Stack(
        children: [
          _buildDocumentView(),
          _buildLoading(),
        ],
      );
    }
    return _buildDocumentView();
  }

  Widget _buildDocumentView() {
    return Container(
      key: const Key('bc_viewer_document_content'),
      width: double.infinity,
      height: double.infinity,
      color: BcTheme.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.description, size: 48, color: BcTheme.primary),
            const SizedBox(height: 8),
            Text(
              widget.title ?? 'Document',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: BcTheme.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Engine: ${widget.engine.label}',
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _onLoadingComplete());

    final page = currentPage;

    // The web adapter gives this viewer a fixed default height (`600px`) and
    // fills it. Mirror that, but degrade gracefully when the host provides no
    // height at all — e.g. inside a vertical scroll view. `Expanded` requires a
    // bounded height, so using it unconditionally blanks the whole subtree.
    return LayoutBuilder(
      builder: (context, constraints) {
        final fillHeight = constraints.hasBoundedHeight;
        final content = _buildFrame(page, fillHeight: fillHeight);

        if (widget.title != null &&
            widget.title!.isNotEmpty &&
            !_loadFailed) {
          return Semantics(label: widget.title, child: content);
        }
        return content;
      },
    );
  }

  Widget _buildFrame(int page, {required bool fillHeight}) {
    final frame = ClipRRect(
      borderRadius: BorderRadius.circular(BcTheme.radius),
      child: Container(
        decoration: BoxDecoration(
          color: BcTheme.muted,
          border: Border.all(color: BcTheme.border),
        ),
        child: Column(
          children: [
            Expanded(child: _buildContent()),
            if (!_loadFailed && widget.pageCount > 0) _buildPageBar(page),
          ],
        ),
      ),
    );

    if (fillHeight) return frame;
    // No height from the host: fall back to the web contract's 600px viewport.
    // The SizedBox gives the inner Column a bounded height, which keeps
    // `Expanded` valid and lets the content fill it.
    return SizedBox(height: _defaultHeight, child: frame);
  }

  Widget _buildPageBar(int page) {
    final atFirst = page <= 1;
    final atLast = page >= widget.pageCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: BcTheme.background,
        border: Border(top: BorderSide(color: BcTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _iconBtn(
            key: 'bc_viewer_document_prev',
            icon: Icons.chevron_left,
            onTap: atFirst || widget.disabled
                ? null
                : () => _changePage(page - 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$page / ${widget.pageCount}',
              style: const TextStyle(
                fontSize: 13,
                color: BcTheme.foreground,
              ),
            ),
          ),
          _iconBtn(
            key: 'bc_viewer_document_next',
            icon: Icons.chevron_right,
            onTap: atLast || widget.disabled
                ? null
                : () => _changePage(page + 1),
          ),
        ],
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

class BcViewerDocument extends StatefulWidget {
  final String? src;
  final BcViewerDocumentEngine engine;
  final String? title;
  final bool disabled;
  final int? page;
  final int pageCount;
  final Widget? errorFallback;
  final BcChangeHandler<int>? onPageChange;

  const BcViewerDocument({
    super.key,
    this.src,
    this.engine = BcViewerDocumentEngine.office,
    this.title,
    this.disabled = false,
    this.page,
    this.pageCount = 0,
    this.errorFallback,
    this.onPageChange,
  });

  @override
  State<BcViewerDocument> createState() => BcViewerDocumentState();
}
