library bc_file;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

class BcFile extends StatefulWidget {
  final String? name;
  final String? label;
  final String? accept;
  final bool multiple;
  final bool disabled;
  final bool required;
  final int maxSize;
  final BcChangeHandler<List<BcFileRef>>? onChange;

  const BcFile({
    super.key,
    this.name,
    this.label,
    this.accept,
    this.multiple = false,
    this.disabled = false,
    this.required = false,
    this.maxSize = 0,
    this.onChange,
  });

  @override
  State<BcFile> createState() => _BcFileState();
}

class _BcFileState extends State<BcFile> {
  final List<BcFileRef> _files = [];
  String _error = '';
  int _pickCounter = 0;

  bool _passesAccept(String? mimeType) {
    if (widget.accept == null || widget.accept!.isEmpty) return true;
    final acceptList = widget.accept!
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty);
    final mt = (mimeType ?? '').toLowerCase();
    for (final pattern in acceptList) {
      if (pattern == mt) return true;
      if (pattern.endsWith('/*')) {
        final prefix = pattern.substring(0, pattern.length - 1);
        if (mt.startsWith(prefix)) return true;
      }
      final ext = pattern.startsWith('.') ? pattern : null;
      if (ext != null) return true;
    }
    return false;
  }

  bool _passesMaxSize(int size) {
    if (widget.maxSize <= 0) return true;
    return size <= widget.maxSize;
  }

  void _handleBrowse() {
    if (widget.disabled) return;

    _pickCounter++;
    final mockFile = BcFileRef(
      name: 'file_$_pickCounter.bin',
      size: 2048,
      type: 'application/octet-stream',
    );

    final errs = <String>[];
    final valid = <BcFileRef>[];

    if (!_passesAccept(mockFile.type)) {
      errs.add('File type not accepted');
    } else if (!_passesMaxSize(mockFile.size)) {
      errs.add('File exceeds max size');
    } else {
      valid.add(mockFile);
    }

    setState(() {
      _error = errs.isNotEmpty ? errs.first : '';
      if (widget.multiple) {
        _files.addAll(valid);
      } else {
        _files
          ..clear()
          ..addAll(valid);
      }
    });

    if (valid.isNotEmpty) {
      widget.onChange?.call(
        List.unmodifiable(_files),
        const BcChangeMeta(
          reason: BcChangeReason.select,
          source: BcEventSource.pointer,
        ),
      );
    }
  }

  void _removeAt(int idx) {
    setState(() {
      _files.removeAt(idx);
    });
    widget.onChange?.call(
      List.unmodifiable(_files),
      const BcChangeMeta(
        reason: BcChangeReason.deselect,
        source: BcEventSource.pointer,
      ),
    );
  }

  String _formatSize(int size) {
    if (size < 1024) return '$size B';
    if (size < 1048576) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / 1048576).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: widget.label!,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  if (widget.required)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: BcTheme.destructive),
                    ),
                ],
              ),
            ),
          ),
        _buildBrowseButton(),
        if (_error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _error,
              style: const TextStyle(color: BcTheme.destructive, fontSize: 12),
            ),
          ),
        if (_files.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: _files.asMap().entries.map((entry) {
                final idx = entry.key;
                final file = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        file.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatSize(file.size),
                        style: const TextStyle(
                          fontSize: 12,
                          color: BcTheme.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        key: Key('bc_file_remove_$idx'),
                        onTap: widget.disabled ? null : () => _removeAt(idx),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Text(
                            '\u2715',
                            style: TextStyle(
                              fontSize: 14,
                              color: BcTheme.mutedForeground,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );

    if (widget.disabled) {
      return Opacity(opacity: 0.5, child: content);
    }

    return content;
  }

  Widget _buildBrowseButton() {
    return ElevatedButton(
      key: const Key('bc_file_browse'),
      onPressed: widget.disabled ? null : _handleBrowse,
      child: const Text('Browse'),
    );
  }
}
