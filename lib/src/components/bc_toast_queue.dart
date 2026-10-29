library bc_toast_queue;

import 'dart:async';

import 'package:flutter/material.dart';

import '../core/types.dart';
import '../theme/bc_theme.dart';

enum BcToastLevel { info, success, warning, error }

enum BcToastQueuePosition {
  topLeft,
  topRight,
  topCenter,
  bottomLeft,
  bottomRight,
  bottomCenter,
}

class BcToastEntry {
  final String id;
  final BcToastLevel level;
  final String message;
  final String? description;
  final Duration? duration;

  const BcToastEntry({
    required this.id,
    required this.message,
    this.level = BcToastLevel.info,
    this.description,
    this.duration,
  });

  BcToastEntry copyWith({
    BcToastLevel? level,
    String? message,
    String? description,
    Duration? duration,
  }) =>
      BcToastEntry(
        id: id,
        level: level ?? this.level,
        message: message ?? this.message,
        description: description ?? this.description,
        duration: duration ?? this.duration,
      );

  @override
  String toString() =>
      'BcToastEntry(id: $id, level: $level, message: $message, '
      'description: $description, duration: $duration)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcToastEntry &&
          id == other.id &&
          level == other.level &&
          message == other.message &&
          description == other.description &&
          duration == other.duration;

  @override
  int get hashCode =>
      Object.hash(id, level, message, description, duration);
}

typedef BcToastDismissHandler = void Function(String id, BcChangeMeta meta);

class BcToastQueueController extends ChangeNotifier {
  List<BcToastEntry> _toasts = [];
  final Duration defaultDuration;
  final int max;

  int _seq = 0;

  BcToastQueueController({
    this.defaultDuration = const Duration(seconds: 4),
    this.max = 50,
  });

  BcToastDismissHandler? onEvicted;

  List<BcToastEntry> get toasts => List.unmodifiable(_toasts);

  String show(BcToastEntry entry) {
    final idx = _toasts.indexWhere((t) => t.id == entry.id);
    if (idx >= 0) {
      _toasts = List.of(_toasts)..[idx] = entry;
    } else {
      _toasts = [..._toasts, entry];
    }

    while (_toasts.length > max) {
      final evicted = _toasts.first;
      _toasts = _toasts.sublist(1);
      onEvicted?.call(
        evicted.id,
        const BcChangeMeta(
          reason: BcChangeReason.clear,
          source: BcEventSource.programmatic,
        ),
      );
    }

    notifyListeners();
    return entry.id;
  }

  String info(String message, {String? description, String? id}) {
    return show(BcToastEntry(
      id: id ?? _nextId(),
      message: message,
      description: description,
      level: BcToastLevel.info,
      duration: defaultDuration,
    ));
  }

  String success(String message, {String? description, String? id}) {
    return show(BcToastEntry(
      id: id ?? _nextId(),
      message: message,
      description: description,
      level: BcToastLevel.success,
      duration: defaultDuration,
    ));
  }

  String warning(String message, {String? description, String? id}) {
    return show(BcToastEntry(
      id: id ?? _nextId(),
      message: message,
      description: description,
      level: BcToastLevel.warning,
      duration: defaultDuration,
    ));
  }

  String error(String message, {String? description, String? id}) {
    return show(BcToastEntry(
      id: id ?? _nextId(),
      message: message,
      description: description,
      level: BcToastLevel.error,
      duration: defaultDuration,
    ));
  }

  void dismiss(String id) {
    final next = _toasts.where((t) => t.id != id).toList();
    if (next.length == _toasts.length) return;
    _toasts = next;
    notifyListeners();
  }

  void clear() {
    if (_toasts.isEmpty) return;
    _toasts = [];
    notifyListeners();
  }

  String _nextId() {
    _seq += 1;
    return 'bc-toast-${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}-$_seq';
  }
}

class BcToastQueue extends StatefulWidget {
  final BcToastQueueController? controller;
  final List<BcToastEntry>? toasts;
  final BcToastQueuePosition position;
  final int maxVisible;
  final String? name;
  final BcToastDismissHandler? onDismiss;

  const BcToastQueue({
    super.key,
    this.controller,
    this.toasts,
    this.position = BcToastQueuePosition.topRight,
    this.maxVisible = 5,
    this.name,
    this.onDismiss,
  });

  @override
  State<BcToastQueue> createState() => _BcToastQueueState();
}

class _BcToastQueueState extends State<BcToastQueue> {
  final Map<String, Timer> _timers = {};
  List<BcToastEntry>? _controlledToasts;

  List<BcToastEntry> get _activeToasts {
    if (widget.controller != null) return widget.controller!.toasts;
    return _controlledToasts ?? const [];
  }

  @override
  void initState() {
    super.initState();
    _controlledToasts =
        widget.toasts != null ? List.of(widget.toasts!) : null;
    widget.controller?.addListener(_onControllerChanged);
    if (widget.controller != null) {
      widget.controller!.onEvicted =
          (id, meta) => widget.onDismiss?.call(id, meta);
    }
    _scheduleTimers();
  }

  @override
  void didUpdateWidget(BcToastQueue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }
    if (widget.controller != null) {
      widget.controller!.onEvicted =
          (id, meta) => widget.onDismiss?.call(id, meta);
    }
    if (widget.toasts != null) {
      _controlledToasts = List.of(widget.toasts!);
    }
    _scheduleTimers();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
      _scheduleTimers();
    }
  }

  void _scheduleTimers() {
    final active = _activeToasts;
    final activeIds = active.map((t) => t.id).toSet();

    final stale = _timers.keys.where((id) => !activeIds.contains(id)).toList();
    for (final id in stale) {
      _timers[id]?.cancel();
      _timers.remove(id);
    }

    for (final toast in active) {
      if (_timers.containsKey(toast.id)) continue;
      final dur = toast.duration;
      if (dur == null || dur.inMilliseconds <= 0) continue;

      _timers[toast.id] = Timer(dur, () => _autoDismiss(toast.id));
    }
  }

  void _autoDismiss(String id) {
    _timers.remove(id);
    _dismiss(
      id,
      const BcChangeMeta(
        reason: BcChangeReason.clear,
        source: BcEventSource.programmatic,
      ),
    );
  }

  void _manualDismiss(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
    _dismiss(
      id,
      const BcChangeMeta(
        reason: BcChangeReason.clear,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _dismiss(String id, BcChangeMeta meta) {
    widget.onDismiss?.call(id, meta);

    if (widget.controller != null) {
      widget.controller!.dismiss(id);
    } else if (_controlledToasts != null) {
      setState(() {
        _controlledToasts =
            _controlledToasts!.where((t) => t.id != id).toList();
      });
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    super.dispose();
  }

  Alignment _alignmentForPosition() {
    switch (widget.position) {
      case BcToastQueuePosition.topLeft:
        return Alignment.topLeft;
      case BcToastQueuePosition.topRight:
        return Alignment.topRight;
      case BcToastQueuePosition.topCenter:
        return Alignment.topCenter;
      case BcToastQueuePosition.bottomLeft:
        return Alignment.bottomLeft;
      case BcToastQueuePosition.bottomRight:
        return Alignment.bottomRight;
      case BcToastQueuePosition.bottomCenter:
        return Alignment.bottomCenter;
    }
  }

  bool _isBottomPosition() {
    return widget.position == BcToastQueuePosition.bottomLeft ||
        widget.position == BcToastQueuePosition.bottomRight ||
        widget.position == BcToastQueuePosition.bottomCenter;
  }

  @override
  Widget build(BuildContext context) {
    final toasts = _activeToasts;
    final visible = toasts.length > widget.maxVisible
        ? toasts.sublist(toasts.length - widget.maxVisible)
        : toasts;

    if (visible.isEmpty) {
      return const SizedBox.shrink();
    }

    final aligned =
        _isBottomPosition() ? visible.reversed.toList() : visible;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Align(
          alignment: _alignmentForPosition(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final toast in aligned) _buildToast(toast),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToast(BcToastEntry toast) {
    return BcToast(
      key: ValueKey<String>('bc-toast-${toast.id}'),
      entry: toast,
      onDismiss: () => _manualDismiss(toast.id),
    );
  }
}

class BcToast extends StatelessWidget {
  final BcToastEntry entry;
  final VoidCallback? onDismiss;

  const BcToast({
    super.key,
    required this.entry,
    this.onDismiss,
  });

  Color _accentColor() {
    switch (entry.level) {
      case BcToastLevel.info:
        return BcTheme.info;
      case BcToastLevel.success:
        return BcTheme.success;
      case BcToastLevel.warning:
        return BcTheme.warning;
      case BcToastLevel.error:
        return BcTheme.destructive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      constraints: const BoxConstraints(maxWidth: 360),
      decoration: BoxDecoration(
        color: BcTheme.card,
        borderRadius: BorderRadius.circular(BcTheme.radius),
        border: Border.all(color: BcTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicWidth(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.message,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: BcTheme.cardForeground,
                                fontWeight: FontWeight.w500,
                              ),
                    ),
                    if (entry.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        entry.description!,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: BcTheme.mutedForeground,
                                ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (onDismiss != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 4),
                child: IconButton(
                  key: Key('bc-toast-dismiss-${entry.id}'),
                  icon: const Icon(Icons.close, size: 18),
                  color: BcTheme.mutedForeground,
                  tooltip: 'Dismiss notification',
                  onPressed: onDismiss,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
