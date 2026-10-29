library bc_geo;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Geographic coordinate picker (ADR-011 Phase 5c).
///
/// Displays a visual map area where the user can tap to pick a location,
/// or manually enter latitude/longitude values. Emits a [BcGeoCoord] via
/// [onValueChange] with `BcChangeReason.select`.
class BcGeo extends StatefulWidget {
  final String? name;
  final String? label;
  final BcGeoCoord? value;
  final BcGeoCoord? defaultValue;
  final bool disabled;
  final bool required;
  final double width;
  final double height;
  final double defaultLat;
  final double defaultLng;
  final BcChangeHandler<BcGeoCoord>? onValueChange;

  const BcGeo({
    super.key,
    this.name,
    this.label,
    this.value,
    this.defaultValue,
    this.disabled = false,
    this.required = false,
    this.width = 400,
    this.height = 250,
    this.defaultLat = 0,
    this.defaultLng = 0,
    this.onValueChange,
  });

  @override
  State<BcGeo> createState() => _BcGeoState();
}

class _BcGeoState extends State<BcGeo> {
  BcGeoCoord? _internal;
  late TextEditingController _latController;
  late TextEditingController _lngController;

  @override
  void initState() {
    super.initState();
    _internal = widget.defaultValue;
    final initial = _effective;
    _latController = TextEditingController(
      text: initial != null ? initial.lat.toStringAsFixed(4) : '',
    );
    _lngController = TextEditingController(
      text: initial != null ? initial.lng.toStringAsFixed(4) : '',
    );
  }

  @override
  void didUpdateWidget(BcGeo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final v = _effective;
      if (v != null) {
        _latController.text = v.lat.toStringAsFixed(4);
        _lngController.text = v.lng.toStringAsFixed(4);
      }
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  BcGeoCoord? get _effective => widget.value ?? _internal;

  void _pickFromMap(TapDownDetails details) {
    if (widget.disabled) return;
    final box = context.findRenderObject() as RenderBox;
    final pos = box.globalToLocal(details.globalPosition);
    final w = box.size.width;
    final h = box.size.height;

    // Map the tap position to lat/lng: center = (0,0), edges = ±90 lat / ±180 lng
    final lng = ((pos.dx / w) * 360 - 180).clamp(-180.0, 180.0);
    final lat = (90 - (pos.dy / h) * 180).clamp(-90.0, 90.0);

    final coord = BcGeoCoord(
      lat: double.parse(lat.toStringAsFixed(4)),
      lng: double.parse(lng.toStringAsFixed(4)),
    );
    setState(() {
      _internal = coord;
      _latController.text = coord.lat.toStringAsFixed(4);
      _lngController.text = coord.lng.toStringAsFixed(4);
    });
    widget.onValueChange?.call(
      coord,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _applyManual() {
    if (widget.disabled) return;
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    if (lat == null || lng == null) return;

    final coord = BcGeoCoord(lat: lat, lng: lng);
    setState(() => _internal = coord);
    widget.onValueChange?.call(
      coord,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _effective;
    final hasMarker = current != null;

    final mapArea = GestureDetector(
      key: const Key('bc_geo_map'),
      onTapDown: _pickFromMap,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: BcTheme.muted,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: BcTheme.border),
        ),
        child: Stack(
          children: [
            // Grid lines to give the map visual context
            CustomPaint(
              size: Size.infinite,
              painter: _GeoGridPainter(
                color: BcTheme.border.withValues(alpha: 0.5),
              ),
            ),
            if (hasMarker)
              Positioned(
                left: _lngToX(current.lng, widget.width) - 12,
                top: _latToY(current.lat, widget.height) - 24,
                child: const Icon(
                  Icons.location_on,
                  key: Key('bc_geo_marker'),
                  size: 28,
                  color: Colors.red,
                ),
              ),
            if (!hasMarker && !widget.disabled)
              const Center(
                child: Text(
                  'Tap to pick location',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );

    final latField = SizedBox(
      width: 100,
      child: TextField(
        key: const Key('bc_geo_lat_input'),
        controller: _latController,
        enabled: !widget.disabled,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        decoration: const InputDecoration(
          labelText: 'Lat',
          isDense: true,
          border: OutlineInputBorder(),
        ),
      ),
    );

    final lngField = SizedBox(
      width: 100,
      child: TextField(
        key: const Key('bc_geo_lng_input'),
        controller: _lngController,
        enabled: !widget.disabled,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        decoration: const InputDecoration(
          labelText: 'Lng',
          isDense: true,
          border: OutlineInputBorder(),
        ),
      ),
    );

    final applyBtn = ElevatedButton(
      key: const Key('bc_geo_apply'),
      onPressed: widget.disabled ? null : _applyManual,
      child: const Text('Set'),
    );

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
        widget.disabled
            ? Opacity(opacity: 0.4, child: mapArea)
            : mapArea,
        const SizedBox(height: 8),
        Row(
          children: [
            latField,
            const SizedBox(width: 8),
            lngField,
            const SizedBox(width: 8),
            applyBtn,
          ],
        ),
      ],
    );

    return content;
  }

  double _lngToX(double lng, double mapWidth) =>
      ((lng + 180) / 360) * mapWidth;

  double _latToY(double lat, double mapHeight) =>
      ((90 - lat) / 180) * mapHeight;
}

class _GeoGridPainter extends CustomPainter {
  final Color color;

  _GeoGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    // Horizontal lines (latitude)
    for (var i = 1; i < 6; i++) {
      final y = (size.height / 6) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical lines (longitude)
    for (var i = 1; i < 8; i++) {
      final x = (size.width / 8) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
