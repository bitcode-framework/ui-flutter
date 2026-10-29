library bc_descriptions;

import 'package:flutter/material.dart';
import '../theme/bc_theme.dart';

/// Layout orientation for label/value rows.
enum BcDescriptionsLayout { horizontal, vertical }

/// Key-value description list (ADR-011 Phase 5c — M1 display).
///
/// Renders [data] as a series of label/value rows. Labels render in the
/// [BcTheme.mutedForeground] token color with a constrained width; values
/// fill the remainder and wrap on overflow. Items appear in map iteration
/// order (insertion order for a [LinkedHashMap]).
///
/// When [data] is empty or null, nothing is rendered. The widget is a pure
/// [StatelessWidget] because it has no internal mutable state.
class BcDescriptions extends StatelessWidget {
  final String? title;
  final Map<String, String>? data;
  final int columns;
  final BcDescriptionsLayout layout;
  final bool bordered;
  final double? labelWidth;

  const BcDescriptions({
    super.key,
    this.title,
    this.data,
    this.columns = 1,
    this.layout = BcDescriptionsLayout.horizontal,
    this.bordered = false,
    this.labelWidth,
  });

  @override
  Widget build(BuildContext context) {
    final entries = data?.entries.toList() ?? const <MapEntry<String, String>>[];

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final rows = <Widget>[];
    for (final entry in entries) {
      rows.add(_buildRow(context, entry.key, entry.value));
    }

    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );

    if (bordered) {
      body = Container(
        decoration: BoxDecoration(
          border: Border.all(color: BcTheme.border),
          borderRadius: BorderRadius.circular(BcTheme.radius),
        ),
        padding: const EdgeInsets.all(16),
        child: body,
      );
    }

    if (title != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title!,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: BcTheme.foreground,
                  ),
            ),
          ),
          body,
        ],
      );
    }

    return body;
  }

  Widget _buildRow(BuildContext context, String label, String value) {
    final valueText = value.isEmpty ? '\u2014' : value;

    if (layout == BcDescriptionsLayout.vertical) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: BcTheme.mutedForeground,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              valueText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BcTheme.foreground,
                  ),
            ),
          ],
        ),
      );
    }

    final labelWidget = labelWidth != null
        ? SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BcTheme.mutedForeground,
                  ),
            ),
          )
        : Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: BcTheme.mutedForeground,
                ),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labelWidget,
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              valueText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BcTheme.foreground,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
