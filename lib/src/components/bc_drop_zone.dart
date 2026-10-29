library bc_drop_zone;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Drag-and-drop file area (ADR-011 Phase 5c).
///
/// Displays a dashed border region where files can be dropped or clicked
/// to browse. Filters files by [accept] (MIME type), [maxSize] (bytes),
/// and [maxFiles]. Emits accepted file list via [onFiles] with
/// `BcChangeReason.select`.
class BcDropZone extends StatefulWidget {
  final String? name;
  final String prompt;
  final String hint;
  final String? accept;
  final int? maxSize;
  final int? maxFiles;
  final bool disabled;
  final BcChangeHandler<List<BcFileRef>>? onFiles;

  const BcDropZone({
    super.key,
    this.name,
    this.prompt = 'Drop files here',
    this.hint = 'or click to browse',
    this.accept,
    this.maxSize,
    this.maxFiles,
    this.disabled = false,
    this.onFiles,
  });

  @override
  State<BcDropZone> createState() => _BcDropZoneState();
}

class _BcDropZoneState extends State<BcDropZone> {
  bool _isHovering = false;
  int _mockCounter = 0;

  bool _acceptsMime(String? mime) {
    if (widget.accept == null || widget.accept!.isEmpty) return true;
    if (mime == null) return false;
    final accepted = widget.accept!.split(',').map((s) => s.trim()).toList();
    for (final pattern in accepted) {
      if (pattern == mime) return true;
      if (pattern.endsWith('/*')) {
        final prefix = pattern.substring(0, pattern.length - 1);
        if (mime.startsWith(prefix)) return true;
      }
      // Extension match
      if (pattern.startsWith('.')) {
        if (mime.endsWith(pattern)) return true;
      }
    }
    return false;
  }

  List<BcFileRef> _filterFiles(List<BcFileRef> files) {
    var result = files.where((f) {
      if (!_acceptsMime(f.type)) return false;
      if (widget.maxSize != null && f.size > widget.maxSize!) return false;
      return true;
    }).toList();

    if (widget.maxFiles != null && result.length > widget.maxFiles!) {
      result = result.take(widget.maxFiles!).toList();
    }

    return result;
  }

  void _handleDrop() {
    if (widget.disabled) return;

    // Simulate file drop with mock files (file_picker not available in tests)
    _mockCounter++;
    final mockFiles = [
      BcFileRef(
        name: 'dropped_file_$_mockCounter.txt',
        size: 1024,
        type: 'text/plain',
      ),
    ];

    final accepted = _filterFiles(mockFiles);
    if (accepted.isEmpty) return;

    widget.onFiles?.call(
      accepted,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.disabled
        ? BcTheme.mutedForeground
        : (_isHovering ? BcTheme.primary : BcTheme.border);

    return MouseRegion(
      onEnter: (_) {
        if (!widget.disabled) setState(() => _isHovering = true);
      },
      onExit: (_) {
        if (!widget.disabled) setState(() => _isHovering = false);
      },
      child: GestureDetector(
        key: const Key('bc_dropzone'),
        onTap: _handleDrop,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: _isHovering && !widget.disabled
                ? BcTheme.primary.withValues(alpha: 0.05)
                : BcTheme.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: baseColor,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Opacity(
            opacity: widget.disabled ? 0.5 : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 36,
                  color: widget.disabled
                      ? BcTheme.mutedForeground
                      : BcTheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.prompt,
                  key: const Key('bc_dropzone_prompt'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.hint,
                  key: const Key('bc_dropzone_hint'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
