library bc_toggle_group;

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

class BcToggleGroupOption {
  final String label;
  final String value;
  final bool disabled;

  const BcToggleGroupOption({
    required this.label,
    required this.value,
    this.disabled = false,
  });
}

enum BcToggleGroupSize { sm, md, lg }

class BcToggleGroup extends StatefulWidget {
  final String? name;
  final List<BcToggleGroupOption>? options;
  final Object? value;
  final Object? defaultValue;
  final bool multiple;
  final BcToggleGroupSize size;
  final bool disabled;
  final BcChangeHandler<Object>? onChange;

  const BcToggleGroup({
    super.key,
    this.name,
    this.options,
    this.value,
    this.defaultValue,
    this.multiple = false,
    this.size = BcToggleGroupSize.md,
    this.disabled = false,
    this.onChange,
  });

  @override
  State<BcToggleGroup> createState() => _BcToggleGroupState();
}

class _BcToggleGroupState extends State<BcToggleGroup> {
  String _internalSingle = '';
  List<String> _internalMulti = const [];

  @override
  void initState() {
    super.initState();
    _initFromDefault();
  }

  void _initFromDefault() {
    final dv = widget.defaultValue;
    if (dv is String) {
      _internalSingle = dv;
    } else if (dv is List<String>) {
      _internalMulti = List<String>.from(dv);
    } else if (dv is List) {
      _internalMulti = dv.map((e) => e.toString()).toList();
    } else if (widget.multiple) {
      _internalMulti = const [];
    } else {
      _internalSingle = '';
    }
  }

  @override
  void didUpdateWidget(BcToggleGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.defaultValue != oldWidget.defaultValue) {
      _initFromDefault();
    }
  }

  String get _activeSingle {
    final v = widget.value;
    if (v != null) {
      if (v is String) return v;
      if (v is List && v.isNotEmpty) return v.first.toString();
      return '';
    }
    return _internalSingle;
  }

  List<String> get _activeMulti {
    final v = widget.value;
    if (v is List) return v.map((e) => e.toString()).toList();
    if (v is String && v.isNotEmpty) return [v];
    return _internalMulti;
  }

  bool _isActive(String value) {
    return widget.multiple
        ? _activeMulti.contains(value)
        : _activeSingle == value;
  }

  EdgeInsets _paddingForSize() {
    switch (widget.size) {
      case BcToggleGroupSize.sm:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case BcToggleGroupSize.lg:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case BcToggleGroupSize.md:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    }
  }

  double _fontSizeForSize() {
    switch (widget.size) {
      case BcToggleGroupSize.sm:
        return 12;
      case BcToggleGroupSize.lg:
        return 16;
      case BcToggleGroupSize.md:
        return 14;
    }
  }

  void _toggle(BcToggleGroupOption option) {
    if (widget.disabled || option.disabled) return;

    if (widget.multiple) {
      final current = List<String>.from(_activeMulti);
      final idx = current.indexOf(option.value);
      if (idx != -1) {
        current.removeAt(idx);
        if (widget.value == null) {
          setState(() => _internalMulti = current);
        }
        widget.onChange?.call(
          current,
          const BcChangeMeta(
            reason: BcChangeReason.deselect,
            source: BcEventSource.pointer,
          ),
        );
      } else {
        current.add(option.value);
        if (widget.value == null) {
          setState(() => _internalMulti = current);
        }
        widget.onChange?.call(
          current,
          const BcChangeMeta(
            reason: BcChangeReason.select,
            source: BcEventSource.pointer,
          ),
        );
      }
    } else {
      final current = _activeSingle;
      final next = current == option.value ? '' : option.value;
      if (widget.value == null) {
        setState(() => _internalSingle = next);
      }
      widget.onChange?.call(
        next,
        BcChangeMeta(
          reason: next.isEmpty ? BcChangeReason.deselect : BcChangeReason.select,
          source: BcEventSource.pointer,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final opts = widget.options ?? const <BcToggleGroupOption>[];

    return Container(
      decoration: BoxDecoration(
        color: BcTheme.muted,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < opts.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            _buildToggle(opts[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildToggle(BcToggleGroupOption option) {
    final isActive = _isActive(option.value);
    final isDisabled = widget.disabled || option.disabled;

    return PlatformWidget(
      material: (context, _) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : () => _toggle(option),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: _paddingForSize(),
            decoration: BoxDecoration(
              color: isActive ? BcTheme.background : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: BcTheme.foreground.withValues(alpha: 0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Opacity(
              opacity: isDisabled ? 0.5 : 1.0,
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: _fontSizeForSize(),
                  fontWeight: FontWeight.w500,
                  color: isActive ? BcTheme.foreground : BcTheme.mutedForeground,
                ),
              ),
            ),
          ),
        ),
      ),
      cupertino: (context, _) => GestureDetector(
        onTap: isDisabled ? null : () => _toggle(option),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: _paddingForSize(),
          decoration: BoxDecoration(
            color: isActive ? BcTheme.background : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Opacity(
            opacity: isDisabled ? 0.5 : 1.0,
            child: Text(
              option.label,
              style: TextStyle(
                fontSize: _fontSizeForSize(),
                fontWeight: FontWeight.w500,
                color: isActive ? BcTheme.foreground : BcTheme.mutedForeground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
