// Primitives demo - BcBox, BcCenter, BcCircle, BcSquare, BcKbd, BcSlot,
// BcVisuallyHidden, BcAspectRatio, BcBackdrop, BcLoadingOverlay, BcStack.
library primitives_section;

import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

import '../demo_widgets.dart';

class PrimitivesSection extends StatefulWidget {
  const PrimitivesSection({super.key});

  @override
  State<PrimitivesSection> createState() => _PrimitivesSectionState();
}

class _PrimitivesSectionState extends State<PrimitivesSection> {
  bool _backdropVisible = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return BcYStack(
      gap: 24,
      children: [
        const SectionHeader(
          title: 'Primitives',
          subtitle: 'Low-level layout and surface primitives.',
        ),

        // -- BcBox --
        DemoCard(
          title: 'BcBox',
          description: 'Generic container with padding, border, and background tokens.',
          child: BcYStack(
            gap: 12,
            children: [
              BcBox(
                padding: 16,
                border: true,
                borderRadius: BcTheme.radius,
                backgroundColor: BcBoxColorToken.card,
                child: const Text('Bordered card'),
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

        // -- BcCenter --
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
                child: Text('Centered',
                    style: TextStyle(color: BcTheme.primaryForeground)),
              ),
            ),
          ),
        ),

        // -- BcCircle --
        DemoCard(
          title: 'BcCircle',
          description: 'Constrains child to circular bounds with clip.',
          child: BcXStack(
            gap: 16,
            crossAxisAlignment: BcXStackAlign.center,
            children: [
              BcCircle(
                size: 64,
                child: Container(
                  color: BcTheme.primary,
                  alignment: Alignment.center,
                  child: const Text('64',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              BcCircle(
                size: 96,
                child: Container(
                  color: BcTheme.secondary,
                  alignment: Alignment.center,
                  child: const Text('96',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              BcCircle(
                size: 48,
                child: Container(
                  color: BcTheme.success,
                  alignment: Alignment.center,
                  child: const Text('48', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),

        // -- BcSquare --
        DemoCard(
          title: 'BcSquare',
          description: 'Constrains child to a square (optionally rounded).',
          child: BcXStack(
            gap: 16,
            crossAxisAlignment: BcXStackAlign.center,
            children: [
              BcSquare(
                size: 72,
                child: Container(
                  color: BcTheme.primary,
                  alignment: Alignment.center,
                  child: const Text('sharp',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              BcSquare(
                size: 72,
                rounded: true,
                child: Container(
                  color: BcTheme.secondary,
                  alignment: Alignment.center,
                  child: const Text('rounded',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),

        // -- BcKbd --
        DemoCard(
          title: 'BcKbd',
          description: 'Keyboard key styling for single keys and combos.',
          child: BcYStack(
            gap: 12,
            crossAxisAlignment: BcYStackAlign.start,
            children: [
              BcXStack(
                gap: 8,
                crossAxisAlignment: BcXStackAlign.center,
                children: [
                  const Text('Single: '),
                  const BcKbd(keys: ['Esc']),
                ],
              ),
              BcXStack(
                gap: 8,
                crossAxisAlignment: BcXStackAlign.center,
                children: [
                  const Text('Combo: '),
                  const BcKbd(keys: ['Ctrl', 'K']),
                ],
              ),
              BcXStack(
                gap: 8,
                crossAxisAlignment: BcXStackAlign.center,
                children: [
                  const Text('Small: '),
                  const BcKbd(keys: ['Shift', 'Tab'], size: BcKbdSize.sm),
                ],
              ),
            ],
          ),
        ),

        // -- BcSlot --
        DemoCard(
          title: 'BcSlot',
          description: 'Children passthrough / composition anchor (no styling).',
          child: BcSlot(
            name: 'demo',
            children: const [
              Text('First slot child'),
              Text('Second slot child'),
              Text('Third slot child'),
            ],
          ),
        ),

        // -- BcVisuallyHidden --
        DemoCard(
          title: 'BcVisuallyHidden',
          description: 'Content hidden visually but available to screen readers.',
          child: BcXStack(
            gap: 8,
            crossAxisAlignment: BcXStackAlign.center,
            children: const [
              Icon(Icons.search, size: 24),
              Text('Search'),
              BcVisuallyHidden(
                child: Text('Hidden from sighted users, read by assistive tech'),
              ),
            ],
          ),
        ),

        // -- BcAspectRatio --
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
                ratio: 4 / 3,
                child: BcBox(
                  backgroundColor: BcBoxColorToken.secondary,
                  borderRadius: BcTheme.radius,
                  child: const Center(
                    child: Text('4:3', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
        ),

        // -- BcBackdrop --
        DemoCard(
          title: 'BcBackdrop',
          description: 'Overlay scrim. Tap the toggle to show the dim layer.',
          child: BcYStack(
            gap: 8,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _backdropVisible = true),
                child: const Text('Show Backdrop'),
              ),
              if (_backdropVisible)
                BcBackdrop(
                  visible: true,
                  opacity: 0.5,
                  dismissible: true,
                  onDismiss: (_) => setState(() => _backdropVisible = false),
                  child: const Center(
                    child: Text('Tap scrim to dismiss',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
            ],
          ),
        ),

        // -- BcLoadingOverlay --
        DemoCard(
          title: 'BcLoadingOverlay',
          description: 'Full-screen loading spinner overlay.',
          child: BcYStack(
            gap: 8,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() => _loading = true);
                  Future.delayed(const Duration(seconds: 2),
                      () => setState(() => _loading = false));
                },
                child: const Text('Show Loading (2s)'),
              ),
              const SizedBox(
                height: 80,
                child: BcLoadingOverlay(
                  loading: false,
                  message: 'Loading...',
                ),
              ),
              if (_loading)
                const BcLoadingOverlay(
                  loading: true,
                  message: 'Please wait...',
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // -- BcStack --
        DemoCard(
          title: 'BcStack',
          description: 'Z-axis stack positioning container. Later children paint above earlier ones.',
          child: SizedBox(
            height: 160,
            child: BcStack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: BcTheme.primary.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: BcTheme.destructive.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: BcTheme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BcTheme.border),
                  ),
                  alignment: Alignment.center,
                  child: const Text('Top'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}