library bc_view_map;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Enterprise map view that renders markers at geo coordinates,
/// supports marker tap selection, and draws regions/polylines.
///
/// (ADR-011 Phase 5c — M5 data display).
///
/// Uses a [CustomPaint] to project lat/lng into the viewport based on
/// [center] and [zoom]. Tapping a marker fires [onMarkerSelect] with
/// the marker's id and a [BcChangeMeta]. The selected marker receives
/// a distinct visual style (elevation/highlight).
class BcViewMap extends StatefulWidget {
  final List<BcMapMarker> markers;
  final List<BcMapRegion> regions;
  final BcGeoCoord center;
  final double zoom;
  final double height;
  final String? mapTitle;
  final BcChangeHandler<String>? onMarkerSelect;
  final void Function(BcMapRegion region)? onRegionSelect;
  final String? selectedMarkerId;

  const BcViewMap({
    super.key,
    required this.markers,
    this.regions = const [],
    required this.center,
    this.zoom = 1.0,
    this.height = 300,
    this.mapTitle,
    this.onMarkerSelect,
    this.onRegionSelect,
    this.selectedMarkerId,
  });

  @override
  State<BcViewMap> createState() => _BcViewMapState();
}

class _BcViewMapState extends State<BcViewMap> {
  String? _selectedMarkerId;

  @override
  void initState() {
    super.initState();
    _selectedMarkerId = widget.selectedMarkerId;
  }

  @override
  void didUpdateWidget(BcViewMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedMarkerId != oldWidget.selectedMarkerId) {
      _selectedMarkerId = widget.selectedMarkerId;
    }
  }

  Offset _project(BcGeoCoord coord, Size size) {
    final centerLat = widget.center.lat;
    final centerLng = widget.center.lng;
    final scale = widget.zoom * 50000;

    final x = size.width / 2 + (coord.lng - centerLng) * scale;
    final y = size.height / 2 -
        (coord.lat - centerLat) * scale * math.cos(centerLat * math.pi / 180);

    return Offset(x.toDouble(), y.toDouble());
  }

  void _onMarkerTap(BcMapMarker marker) {
    setState(() {
      _selectedMarkerId = marker.id;
    });

    widget.onMarkerSelect?.call(
      marker.id,
      const BcChangeMeta(
        reason: BcChangeReason.valueChange,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('bc_view_map'),
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: BcTheme.muted.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(BcTheme.radius),
        border: Border.all(color: BcTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.mapTitle != null)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                widget.mapTitle!,
                key: const Key('bc_view_map_title'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: BcTheme.foreground,
                ),
              ),
            ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: widget.mapTitle != null
                    ? Radius.zero
                    : const Radius.circular(BcTheme.radius),
                bottom: const Radius.circular(BcTheme.radius),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return GestureDetector(
                    onTapUp: (details) => _handleMapTap(details.localPosition, size),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CustomPaint(
                          key: const Key('bc_view_map_canvas'),
                          size: size,
                          painter: _MapPainter(
                            regions: widget.regions,
                            center: widget.center,
                            zoom: widget.zoom,
                            screenSize: size,
                            project: _project,
                          ),
                        ),
                        ...widget.markers.map((marker) {
                          final pos = _project(
                            BcGeoCoord(lat: marker.lat, lng: marker.lng),
                            size,
                          );
                          return _MapMarkerWidget(
                            key: Key('bc_view_map_marker_${marker.id}'),
                            position: pos,
                            marker: marker,
                            isSelected: _selectedMarkerId == marker.id,
                            onTap: () => _onMarkerTap(marker),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMapTap(Offset localPosition, Size size) {
  }
}

/// Projects a geo coordinate into screen space for this map instance.
typedef _ProjectFn = Offset Function(BcGeoCoord, Size);

class _MapPainter extends CustomPainter {
  final List<BcMapRegion> regions;
  final BcGeoCoord center;
  final double zoom;
  final Size screenSize;
  final _ProjectFn project;

  _MapPainter({
    required this.regions,
    required this.center,
    required this.zoom,
    required this.screenSize,
    required this.project,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    for (final region in regions) {
      _drawRegion(canvas, size, region);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = BcTheme.border.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    const step = 40.0;
    for (var x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawRegion(Canvas canvas, Size size, BcMapRegion region) {
    if (region.points.isEmpty) return;

    final paint = Paint()
      ..color = (region.color ?? BcTheme.primary).withValues(alpha: 0.2)
      ..style = region.type == BcGeoShapeType.polygon
          ? PaintingStyle.fill
          : PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final borderPaint = Paint()
      ..color = region.color ?? BcTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final projectedPoints = region.points.map((p) => project(p, size)).toList();

    if (projectedPoints.isEmpty) return;

    path.moveTo(projectedPoints.first.dx, projectedPoints.first.dy);
    for (var i = 1; i < projectedPoints.length; i++) {
      path.lineTo(projectedPoints[i].dx, projectedPoints[i].dy);
    }

    if (region.type == BcGeoShapeType.polygon) {
      path.close();
      canvas.drawPath(path, paint);
    }
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return regions != oldDelegate.regions ||
        center != oldDelegate.center ||
        zoom != oldDelegate.zoom ||
        screenSize != oldDelegate.screenSize;
  }
}

class _MapMarkerWidget extends StatelessWidget {
  final Offset position;
  final BcMapMarker marker;
  final bool isSelected;
  final VoidCallback onTap;

  const _MapMarkerWidget({
    super.key,
    required this.position,
    required this.marker,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 14,
      top: position.dy - 28,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isSelected ? 32 : 24,
              height: isSelected ? 32 : 24,
              decoration: BoxDecoration(
                color: isSelected ? BcTheme.primary : BcTheme.card,
                shape: BoxShape.circle,
                border: Border.all(
                  color: BcTheme.primary,
                  width: isSelected ? 2 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: BcTheme.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Center(
                child: Icon(
                  Icons.location_on,
                  size: isSelected ? 18 : 14,
                  color: isSelected ? BcTheme.card : BcTheme.primary,
                ),
              ),
            ),
            if (marker.label != null)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: BcTheme.card.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: BcTheme.border),
                ),
                child: Text(
                  marker.label!,
                  key: Key('bc_view_map_marker_label_${marker.id}'),
                  style: const TextStyle(
                    fontSize: 10,
                    color: BcTheme.foreground,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
