// Print demo - BcExport, BcPrint, BcReportLink.
library print_section;

import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

import '../demo_widgets.dart';

class PrintSection extends StatelessWidget {
  const PrintSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BcYStack(
      gap: 24,
      children: [
        const SectionHeader(
          title: 'Print',
          subtitle: 'Export buttons, print triggers, and shareable report links.',
        ),

        // -- BcExport --
        DemoCard(
          title: 'BcExport',
          description: 'Export button with a dropdown of formats (CSV, Excel, JSON, PDF, XML).',
          child: BcExport(
            label: 'Export Data',
            formats: const [
              BcExportFormat.csv,
              BcExportFormat.xlsx,
              BcExportFormat.json,
              BcExportFormat.pdf,
              BcExportFormat.xml,
            ],
            onExport: (format, _) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Exporting as ${format.label}...'),
                  duration: const Duration(milliseconds: 1000),
                ),
              );
            },
          ),
        ),

        // -- BcPrint --
        DemoCard(
          title: 'BcPrint',
          description: 'Print button with three visual variants.',
          child: BcYStack(
            gap: 12,
            children: [
              BcXStack(
                gap: 12,
                wrap: WrapAlignment.start,
                crossAxisAlignment: BcXStackAlign.center,
                children: [
                  BcPrint(
                    label: 'Print (default)',
                    target: 'report-001',
                    variant: BcPrintVariant.defaultVariant,
                    onPrint: (target, _) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Printing $target...'),
                          duration: const Duration(milliseconds: 1000),
                        ),
                      );
                    },
                  ),
                  BcPrint(
                    label: 'Print (outline)',
                    target: 'report-001',
                    variant: BcPrintVariant.outline,
                    onPrint: (target, _) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Printing $target...'),
                          duration: const Duration(milliseconds: 1000),
                        ),
                      );
                    },
                  ),
                ],
              ),
              BcXStack(
                gap: 12,
                wrap: WrapAlignment.start,
                crossAxisAlignment: BcXStackAlign.center,
                children: [
                  BcPrint(
                    label: 'Print (ghost)',
                    target: 'report-001',
                    variant: BcPrintVariant.ghost,
                    onPrint: (target, _) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Printing $target...'),
                          duration: const Duration(milliseconds: 1000),
                        ),
                      );
                    },
                  ),
                  BcPrint(
                    label: 'Print (confirm)',
                    target: 'report-001',
                    confirm: true,
                    onPrint: (target, _) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Confirmed print of $target'),
                          duration: const Duration(milliseconds: 1000),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // -- BcReportLink --
        DemoCard(
          title: 'BcReportLink',
          description: 'Generate and copy a shareable report link.',
          child: BcReportLink(
            reportRef: 'quarterly-report-2026Q2',
            label: 'Generate Share Link',
            baseUrl: 'https://bitcode.io/r',
            onLinkGenerated: (link, _) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Generated: $link'),
                  duration: const Duration(milliseconds: 1200),
                ),
              );
            },
            onCopy: (link, _) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link copied to clipboard'),
                  duration: Duration(milliseconds: 1000),
                ),
              );
            },
          ),
        ),

        // -- BcPrintArea --
        DemoCard(
          title: 'BcPrintArea',
          description: 'Semantic region marker that isolates content for @media print.',
          child: BcPrintArea(
            child: BcYStack(
              gap: 8,
              children: const [
                Text('Invoice #2026-001', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Customer: Acme Corp'),
                Text('Total: \$1,250.00'),
              ],
            ),
          ),
        ),

        // -- BcPrintPreview --
        DemoCard(
          title: 'BcPrintPreview',
          description: 'Print preview pane with trigger button (iframe on web).',
          child: SizedBox(
            height: 240,
            child: BcPrintPreview(
              content: '<h1>Sample Report</h1><p>This is printable content.</p>',
              title: 'Report Preview',
              triggerLabel: 'Print Report',
            ),
          ),
        ),
      ],
    );
  }
}