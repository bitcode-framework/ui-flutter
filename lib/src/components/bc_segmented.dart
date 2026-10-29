library bc_segmented;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';

/// Segmented control option.
class BcSegmentedOption<T extends Object> {
  final T value;
  final String label;
  final IconData? icon;

  const BcSegmentedOption({required this.value, required this.label, this.icon});
}

/// Adaptive segmented control (ADR-011 Section 5).
/// Material: Material segmented button. Cupertino: CupertinoSegmentedControl.
class BcSegmented<T extends Object> extends StatefulWidget {
  final String? name;
  final T? value;
  final T? defaultValue;
  final List<BcSegmentedOption<T>> options;
  final BcChangeHandler<T>? onValueChange;
  final bool disabled;

  const BcSegmented({
    super.key,
    this.name,
    this.value,
    this.defaultValue,
    required this.options,
    this.onValueChange,
    this.disabled = false,
  });

  @override
  State<BcSegmented<T>> createState() => _BcSegmentedState<T>();
}

class _BcSegmentedState<T extends Object> extends State<BcSegmented<T>> {
  late T? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.value ?? widget.defaultValue;
  }

  @override
  void didUpdateWidget(BcSegmented<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _selected = widget.value;
    }
  }

  void _select(T value) {
    setState(() => _selected = value);
    widget.onValueChange?.call(
      value,
      const BcChangeMeta(reason: BcChangeReason.select),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => SegmentedButton<T>(
        segments: widget.options
            .map((o) => ButtonSegment<T>(
                  value: o.value,
                  label: Text(o.label),
                  icon: o.icon != null ? Icon(o.icon) : null,
                ))
            .toList(),
        selected: _selected != null ? <T>{_selected as T} : <T>{},
        emptySelectionAllowed: true,
        onSelectionChanged: widget.disabled
            ? null
            : (set) => set.isNotEmpty ? _select(set.first) : null,
      ),
      cupertino: (context, platform) => Opacity(
        opacity: widget.disabled ? 0.5 : 1.0,
        child: CupertinoSegmentedControl<T>(
          groupValue: _selected,
          onValueChanged: widget.disabled ? (_) {} : _select,
          children: {
            for (final o in widget.options)
              o.value: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(o.label),
              ),
          },
        ),
      ),
    );
  }
}
