library bc_export;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Export format identifier.
///
/// Mirrors TS `BcExportFormat` union.
enum BcExportFormat {
  csv,
  xlsx,
  json,
  pdf,
  xml;

  String get label {
    switch (this) {
      case BcExportFormat.csv:
        return 'CSV';
      case BcExportFormat.xlsx:
        return 'Excel';
      case BcExportFormat.json:
        return 'JSON';
      case BcExportFormat.pdf:
        return 'PDF';
      case BcExportFormat.xml:
        return 'XML';
    }
  }

  IconData get icon {
    switch (this) {
      case BcExportFormat.csv:
        return Icons.table_chart_outlined;
      case BcExportFormat.xlsx:
        return Icons.grid_on_outlined;
      case BcExportFormat.json:
        return Icons.code;
      case BcExportFormat.pdf:
        return Icons.picture_as_pdf_outlined;
      case BcExportFormat.xml:
        return Icons.description_outlined;
    }
  }

  String get id {
    switch (this) {
      case BcExportFormat.csv:
        return 'csv';
      case BcExportFormat.xlsx:
        return 'xlsx';
      case BcExportFormat.json:
        return 'json';
      case BcExportFormat.pdf:
        return 'pdf';
      case BcExportFormat.xml:
        return 'xml';
    }
  }
}

/// A single export column with optional permission gating.
///
/// Mirrors TS `BcExportColumn`. When [permitted] is `false` the column is
/// excluded from the export request by the caller (engine enforces this
/// server-side; the field is surfaced so the UI can grey out denied columns).
class BcExportColumn {
  final String field;
  final String? label;
  final bool permitted;

  const BcExportColumn({
    required this.field,
    this.label,
    this.permitted = true,
  });
}

/// Progress metadata for a long-running export.
///
/// Mirrors TS `BcExportProgress`.
class BcExportProgress {
  final int loaded;
  final int total;
  final int percent;

  const BcExportProgress({
    required this.loaded,
    required this.total,
    required this.percent,
  });
}

/// Export button with a dropdown menu of configurable formats.
///
/// Mirrors TS `BcExportContract`. Tapping the trigger opens a menu listing
/// all configured [formats]. Selecting a format invokes [onExport] with the
/// format and a [BcChangeMeta], then closes the menu. An empty [formats]
/// list renders a disabled trigger. When [disabled] is true, the trigger is
/// non-interactive and no [onExport] fires.
///
/// ADR-014 additions: [endpoint] + [columns] + [filter] enable declarative
/// server-side exports (the caller may POST to [endpoint] with the columns).
/// [loading] / [progress] render an inline progress indicator on the trigger.
/// [onExportComplete] / [onProgress] mirror the web callbacks.
///
/// Platform-aware: Material uses a popup overlay; Cupertino uses a bottom
/// action sheet on iOS/macOS.
class BcExport extends StatefulWidget {
  /// Configured export formats. When empty, the trigger is disabled.
  final List<BcExportFormat> formats;

  /// Disables the trigger entirely.
  final bool disabled;

  /// Label text on the trigger button.
  final String label;

  /// Callback when a format is selected. Carries the format and meta.
  final void Function(BcExportFormat format, BcChangeMeta meta)? onExport;

  /// Server-side export endpoint (e.g. `/api/v1/crm/contacts/export`).
  /// When set, the caller can POST `{format, columns, filter, sort}` to
  /// stream the file. The widget itself only fires [onExport]; the actual
  /// fetch is the caller's responsibility (mirrors the web declarative path).
  final String? endpoint;

  /// Permission-gated column list to include in the export request.
  final List<BcExportColumn>? columns;

  /// When true, renders a progress indicator on the trigger.
  final bool loading;

  /// Live progress for the in-flight export. Shown when [loading] is true.
  final BcExportProgress? progress;

  /// Fired when a declarative export completes (blob downloaded).
  final void Function(BcExportFormat format)? onExportComplete;

  /// Fired as an export progresses (for large datasets).
  final void Function(BcExportProgress progress)? onProgress;

  const BcExport({
    super.key,
    this.formats = const [
      BcExportFormat.csv,
      BcExportFormat.xlsx,
      BcExportFormat.pdf,
    ],
    this.disabled = false,
    this.label = 'Export',
    this.onExport,
    this.endpoint,
    this.columns,
    this.loading = false,
    this.progress,
    this.onExportComplete,
    this.onProgress,
  });

  @override
  State<BcExport> createState() => _BcExportState();
}

class _BcExportState extends State<BcExport> {
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _menuOverlay;

  bool get _isDisabled => widget.disabled || widget.formats.isEmpty;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _menuOverlay?.remove();
    _menuOverlay = null;
  }

  void _openMenu() {
    if (_isDisabled || _menuOverlay != null) return;

    final platform = Theme.of(context).platform;
    final isCupertino =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    if (isCupertino) {
      _showCupertinoSheet();
      return;
    }

    _menuOverlay = OverlayEntry(builder: _buildMenuOverlay);
    Overlay.of(context).insert(_menuOverlay!);
  }

  void _closeMenu() {
    _removeOverlay();
  }

  void _toggleMenu() {
    if (_menuOverlay != null) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _handleSelect(BcExportFormat format) {
    const meta = BcChangeMeta(
      reason: BcChangeReason.select,
      source: BcEventSource.pointer,
    );
    widget.onExport?.call(format, meta);
    _closeMenu();
  }

  Offset _triggerPosition() {
    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return Offset.zero;
    return renderBox.localToGlobal(Offset.zero);
  }

  Size _triggerSize() {
    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size ?? const Size(120, 40);
  }

  Widget _buildMenuOverlay(BuildContext overlayContext) {
    final triggerPos = _triggerPosition();
    final triggerSize = _triggerSize();

    double menuLeft = triggerPos.dx;
    double menuTop = triggerPos.dy + triggerSize.height + 4;

    final mediaQuery = MediaQuery.of(overlayContext);
    menuTop = menuTop.clamp(0.0, mediaQuery.size.height - 200);
    menuLeft = menuLeft.clamp(0.0, mediaQuery.size.width - 200);

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _closeMenu,
          child: Container(
            color: Colors.transparent,
            constraints: const BoxConstraints.expand(),
          ),
        ),
        Positioned(
          left: menuLeft,
          top: menuTop,
          child: Material(
            color: Colors.transparent,
            child: Container(
              key: const Key('bc-export-menu'),
              constraints: BoxConstraints(
                minWidth: triggerSize.width,
                maxWidth: triggerSize.width + 80,
              ),
              decoration: BoxDecoration(
                color: BcTheme.popover,
                borderRadius: BorderRadius.circular(BcTheme.radius),
                border: Border.all(color: BcTheme.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.formats.map((f) {
                  return InkWell(
                    key: Key('bc-export-item-${f.id}'),
                    onTap: () => _handleSelect(f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(f.icon, size: 18, color: BcTheme.foreground),
                          const SizedBox(width: 8),
                          Text(
                            f.label,
                            style: const TextStyle(
                              fontSize: 14,
                              color: BcTheme.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCupertinoSheet() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(widget.label),
        actions: widget.formats
            .map((f) => CupertinoActionSheetAction(
                  key: Key('bc-export-item-${f.id}'),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _handleSelect(f);
                  },
                  child: Text(f.label),
                ))
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(sheetContext),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Widget _buildTrigger() {
    final isDisabled = _isDisabled;
    final platform = Theme.of(context).platform;
    final isCupertino =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    return GestureDetector(
      key: const Key('bc-export-trigger'),
      behavior: HitTestBehavior.opaque,
      onTap: isDisabled ? null : _toggleMenu,
      child: Container(
        key: _triggerKey,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDisabled ? BcTheme.muted : BcTheme.primary,
          borderRadius: BorderRadius.circular(BcTheme.radius),
          border: Border.all(
            color: isDisabled ? BcTheme.border : BcTheme.primary,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCupertino
                  ? CupertinoIcons.cloud_download
                  : Icons.download_outlined,
              size: 18,
              color: isDisabled
                  ? BcTheme.mutedForeground
                  : BcTheme.primaryForeground,
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDisabled
                    ? BcTheme.mutedForeground
                    : BcTheme.primaryForeground,
              ),
            ),
            const SizedBox(width: 4),
            if (widget.loading)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDisabled
                        ? BcTheme.mutedForeground
                        : BcTheme.primaryForeground,
                  ),
                ),
              )
            else
              Icon(
                isCupertino
                    ? CupertinoIcons.chevron_down
                    : Icons.arrow_drop_down,
                size: isCupertino ? 14 : 20,
                color: isDisabled
                    ? BcTheme.mutedForeground
                    : BcTheme.primaryForeground,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTrigger();
  }
}
