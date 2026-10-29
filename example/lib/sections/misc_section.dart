// Misc demo - BcWatermark, BcColorSwatch, BcColorWheel, BcFile, BcSignature,
// BcBarcode, BcDropZone, BcGeo.
library misc_section;

import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

import '../demo_widgets.dart';

class MiscSection extends StatefulWidget {
  const MiscSection({super.key});

  @override
  State<MiscSection> createState() => _MiscSectionState();
}

class _MiscSectionState extends State<MiscSection> {
  String? _selectedColor;

  @override
  Widget build(BuildContext context) {
    return BcYStack(
      gap: 24,
      children: [
        const SectionHeader(
          title: 'Misc',
          subtitle: 'Watermarks, color pickers, file uploads, signatures, barcodes, and geo.',
        ),

        // -- BcWatermark --
        DemoCard(
          title: 'BcWatermark',
          description: 'Overlays semi-transparent text across child content.',
          child: BcWatermark(
            text: 'CONFIDENTIAL',
            opacity: 0.12,
            rotate: -22,
            child: BcBox(
              padding: 24,
              backgroundColor: BcBoxColorToken.card,
              borderRadius: BcTheme.radius,
              child: const SizedBox(
                width: 260,
                height: 100,
                child: Center(
                  child: Text('Content behind the watermark overlay.'),
                ),
              ),
            ),
          ),
        ),

        // -- BcColorSwatch --
        DemoCard(
          title: 'BcColorSwatch',
          description: 'Grid of selectable color chips.',
          child: BcYStack(
            gap: 8,
            children: [
              BcColorSwatch(
                colors: const [
                  '#EF4444', '#F97316', '#F59E0B', '#EAB308',
                  '#84CC16', '#22C55E', '#10B981', '#14B8A6',
                  '#06B6D4', '#3B82F6', '#6366F1', '#8B5CF6',
                ],
                value: _selectedColor,
                crossAxisCount: 6,
                onValueChange: (v, _) => setState(() => _selectedColor = v),
              ),
              if (_selectedColor != null)
                Text('Selected: $_selectedColor',
                    style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),

        // -- BcColorWheel --
        DemoCard(
          title: 'BcColorWheel',
          description: 'Interactive hue/saturation color wheel. Drag to pick a color.',
          child: BcXStack(
            gap: 16,
            crossAxisAlignment: BcXStackAlign.center,
            children: const [
              BcColorWheel(
                size: 180,
                label: 'Pick a color',
              ),
            ],
          ),
        ),

        // -- BcFile --
        DemoCard(
          title: 'BcFile',
          description: 'File picker with accept filter and multiple selection.',
          child: BcFile(
            label: 'Upload Document',
            accept: 'image/*,application/pdf',
            multiple: true,
            onChange: (files, _) {
              if (files.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${files.length} file(s) selected'),
                    duration: const Duration(milliseconds: 800),
                  ),
                );
              }
            },
          ),
        ),

        // -- BcDropZone --
        DemoCard(
          title: 'BcDropZone',
          description: 'Drag-and-drop file area with dashed border.',
          child: BcDropZone(
            prompt: 'Drop files here',
            hint: 'or click to browse',
            maxFiles: 5,
            onFiles: (files, _) {
              if (files.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${files.length} file(s) dropped'),
                    duration: const Duration(milliseconds: 800),
                  ),
                );
              }
            },
          ),
        ),

        // -- BcSignature --
        DemoCard(
          title: 'BcSignature',
          description: 'Signature pad. Draw with pointer to capture a signature.',
          child: BcSignature(
            label: 'Sign here',
            width: 400,
            height: 160,
          ),
        ),

        // -- BcBarcode --
        DemoCard(
          title: 'BcBarcode',
          description: 'Barcode input (CODE128 default). Type or scan a value.',
          child: BcBarcode(
            label: 'Product SKU',
            placeholder: 'Scan or type barcode...',
            format: 'CODE128',
          ),
        ),

        // -- BcGeo --
        DemoCard(
          title: 'BcGeo',
          description: 'Geographic coordinate picker. Tap the map or enter lat/lng.',
          child: BcGeo(
            label: 'Location',
            width: 400,
            height: 200,
            defaultLat: -6.2088,
            defaultLng: 106.8456,
          ),
        ),

        // -- BcColorArea --
        DemoCard(
          title: 'BcColorArea',
          description: '2D saturation/value drag area. Drag to pick SV given a hue.',
          child: const BcColorArea(hue: 210, width: 200, height: 200),
        ),

        // -- BcColorSlider --
        DemoCard(
          title: 'BcColorSlider',
          description: '1D hue spectrum slider. Drag to pick a hue (0-360).',
          child: const BcColorSlider(label: 'Hue', value: 180),
        ),

        // -- BcFavorites --
        DemoCard(
          title: 'BcFavorites',
          description: 'Star/heart toggle button for favoriting.',
          child: BcFavorites(
            defaultValue: false,
            onValueChange: (v, _) {},
          ),
        ),
      ],
    );
  }
}