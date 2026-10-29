library bc_view_report;

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Enterprise report view that renders sections with headers and body
/// content, respects section visibility, and re-renders on data update.
///
/// (ADR-011 Phase 5c — M5 data display).
///
/// Sections are rendered in order. A section with `visible: false` is
/// skipped entirely. Empty body sections render header-only (no error).
class BcViewReport extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<BcReportSection> sections;
  final DateTime? generatedAt;
  final bool printable;
  final EdgeInsets padding;

  const BcViewReport({
    super.key,
    this.title = '',
    this.subtitle,
    required this.sections,
    this.generatedAt,
    this.printable = false,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final visibleSections =
        sections.where((s) => s.visible).toList(growable: false);

    return Container(
      key: const Key('bc_view_report'),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          if (subtitle != null || generatedAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      key: const Key('bc_view_report_subtitle'),
                      style: const TextStyle(
                        fontSize: 13,
                        color: BcTheme.mutedForeground,
                      ),
                    ),
                  if (generatedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _formatDate(generatedAt!),
                        key: const Key('bc_view_report_generated_at'),
                        style: const TextStyle(
                          fontSize: 11,
                          color: BcTheme.mutedForeground,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          if (title.isNotEmpty || subtitle != null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: BcTheme.border),
            ),
          ...visibleSections.asMap().entries.map((entry) {
            return _buildSection(entry.key, entry.value);
          }),
          if (printable)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: PlatformElevatedButton(
                key: const Key('bc_view_report_print'),
                onPressed: () {},
                child: const Text('Print'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    if (title.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            key: const Key('bc_view_report_title'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: BcTheme.foreground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(int index, BcReportSection section) {
    return Container(
      key: Key('bc_view_report_section_${section.id}'),
      margin: EdgeInsets.only(
        bottom: index < sections.where((s) => s.visible).length - 1 ? 20 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.title != null)
            Text(
              section.title!,
              key: Key('bc_view_report_section_title_${section.id}'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: BcTheme.foreground,
              ),
            ),
          if (section.content != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                section.content!,
                key: Key('bc_view_report_section_body_${section.id}'),
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: BcTheme.foreground,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
