import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';
import '../demo_widgets.dart';

/// Layout widgets: BcBox, BcYStack, BcXStack, BcCenter, BcAspectRatio,
/// BcVisuallyHidden.
class LayoutSection extends StatelessWidget {
  const LayoutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BcYStack(
      gap: 24,
      children: [
        const SectionHeader(
          title: 'Layout',
          subtitle: 'Stacking, boxing, centering, aspect ratio, and visually hidden.',
        ),

        // ── BcYStack ──
        DemoCard(
          title: 'BcYStack',
          description: 'Vertical stack with configurable gap and alignment.',
          child: BcBox(
            padding: 16,
            border: true,
            borderRadius: BcTheme.radius,
            backgroundColor: BcBoxColorToken.muted,
            child: BcYStack(
              gap: 12,
              crossAxisAlignment: BcYStackAlign.center,
              children: [
                _colorChip(BcTheme.primary, 'Primary'),
                _colorChip(BcTheme.secondary, 'Secondary'),
                _colorChip(BcTheme.success, 'Success'),
              ],
            ),
          ),
        ),

        // ── BcXStack ──
        DemoCard(
          title: 'BcXStack',
          description: 'Horizontal stack with configurable gap and wrap.',
          child: BcBox(
            padding: 16,
            border: true,
            borderRadius: BcTheme.radius,
            backgroundColor: BcBoxColorToken.muted,
            child: BcXStack(
              gap: 12,
              crossAxisAlignment: BcXStackAlign.center,
              wrap: WrapAlignment.start,
              children: [
                _colorChip(BcTheme.primary, 'P'),
                _colorChip(BcTheme.secondary, 'S'),
                _colorChip(BcTheme.success, 'OK'),
                _colorChip(BcTheme.warning, '!'),
                _colorChip(BcTheme.destructive, 'X'),
              ],
            ),
          ),
        ),

        // ── BcBox ──
        DemoCard(
          title: 'BcBox',
          description: 'Generic container with padding, border, and background.',
          child: BcYStack(
            gap: 12,
            children: [
              BcBox(
                padding: 16,
                border: true,
                borderRadius: BcTheme.radius,
                backgroundColor: BcBoxColorToken.card,
                child: const Text('Bordered card with padding'),
              ),
              BcBox(
                padding: 16,
                borderRadius: BcTheme.radius,
                backgroundColor: BcBoxColorToken.primary,
                child: Text('Primary background',
                    style: TextStyle(color: BcTheme.primaryForeground)),
              ),
              BcBox(
                padding: 16,
                borderRadius: BcTheme.radius,
                backgroundColor: BcBoxColorToken.muted,
                child: const Text('Muted background'),
              ),
            ],
          ),
        ),

        // ── BcAspectRatio ──
        DemoCard(
          title: 'BcAspectRatio',
          description: 'Constrains child to a given width/height ratio.',
          child: BcYStack(
            gap: 12,
            children: [
              BcAspectRatio(
                ratio: 16 / 9,
                child: BcBox(
                  backgroundColor: BcBoxColorToken.primary,
                  borderRadius: BcTheme.radius,
                  child: const Center(
                    child: Text('16:9',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
              ),
              BcAspectRatio(
                ratio: 1,
                child: BcBox(
                  backgroundColor: BcBoxColorToken.secondary,
                  borderRadius: BcTheme.radius,
                  child: const Center(
                    child: Text('1:1',
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── BcCenter ──
        DemoCard(
          title: 'BcCenter',
          description: 'Centers child both horizontally and vertically.',
          child: BcBox(
            padding: 16,
            border: true,
            borderRadius: BcTheme.radius,
            child: BcCenter(
              minHeight: 100,
              child: BcBox(
                padding: 16,
                backgroundColor: BcBoxColorToken.primary,
                borderRadius: BcTheme.radius,
                child: Text('Centered content',
                    style: TextStyle(color: BcTheme.primaryForeground)),
              ),
            ),
          ),
        ),

        // ── BcVisuallyHidden ──
        DemoCard(
          title: 'BcVisuallyHidden',
          description: 'Content hidden visually but available to screen readers.',
          child: BcXStack(
            gap: 8,
            crossAxisAlignment: BcXStackAlign.center,
            children: [
              const Icon(Icons.search, size: 24),
              const Text('Search'),
              const BcVisuallyHidden(
                child: Text('This text is hidden visually but read by screen readers'),
              ),
            ],
          ),
        ),

        // -- BcFlex --
        DemoCard(
          title: 'BcFlex',
          description: 'Flexible layout container (row/column) with gap, align, justify, wrap.',
          child: BcBox(
            padding: 16,
            border: true,
            borderRadius: BcTheme.radius,
            backgroundColor: BcBoxColorToken.muted,
            child: BcFlex(
              direction: BcFlexDirection.row,
              gap: 2,
              align: BcFlexAlign.center,
              justify: BcFlexJustify.center,
              children: [
                _colorChip(BcTheme.primary, 'A'),
                _colorChip(BcTheme.secondary, 'B'),
                _colorChip(BcTheme.success, 'C'),
              ],
            ),
          ),
        ),

        // -- BcMeterGroup --
        DemoCard(
          title: 'BcMeterGroup',
          description: 'Group of independent progress meters with variant colors.',
          child: BcMeterGroup(
            max: 100,
            ariaLabel: 'Storage usage',
            segments: const [
              BcMeterSegment(label: 'Images', value: 45, variant: BcMeterVariant.defaultVariant),
              BcMeterSegment(label: 'Videos', value: 30, variant: BcMeterVariant.info),
              BcMeterSegment(label: 'Docs', value: 15, variant: BcMeterVariant.success),
              BcMeterSegment(label: 'Other', value: 8, variant: BcMeterVariant.warning),
            ],
          ),
        ),
      ],
    );
  }

  Widget _colorChip(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}
