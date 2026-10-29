library bc_map;

import 'package:flutter/material.dart';

import '../core/bc_i18n.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Reason a marker was activated.
enum BcMapMarkerClickReason { markerClick, programmatic }

/// Geographic coordinate for the BcMap contract. (BcMapMarker is reused from
/// core/types.dart — the same shape used by BcViewMap.)
class BcMapLatLng {
  final double lat;
  final double lng;
  const BcMapLatLng({required this.lat, required this.lng});
}

/// Interactive map wrapper (ADR-006 Adapt POC, ADR-011).
///
/// Dependency-free: the widget renders a [Container] with the marker list as
/// overlay text. Actual map rendering is delegated to the caller via
/// [mapBuilder] (e.g. wired to `google_maps_flutter`). This keeps
/// `bc_ui_flutter` free of platform map permission manifests — the same
/// delegation strategy used by [BcShare] for share_plus.
///
/// When [mapBuilder] is null a placeholder surface with center/zoom/marker
/// metadata is shown, satisfying the contract surface and widget tests.
class BcMap extends StatelessWidget {
  final BcMapLatLng? center;
  final double zoom;
  final List<BcMapMarker> markers;
  final double height;
  final Widget Function(BuildContext context)? mapBuilder;
  final void Function(BcMapMarker marker, BcChangeMeta meta)? onMarkerClick;

  const BcMap({
    super.key,
    this.center,
    this.zoom = 13,
    this.markers = const [],
    this.height = 400,
    this.mapBuilder,
    this.onMarkerClick,
  });

  void _handleMarkerTap(BcMapMarker m) {
    onMarkerClick?.call(
      m,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: bcI18n.t('bc.map.ariaLabel'),
      container: true,
      child: SizedBox(
        key: const Key('bc-map-root'),
        width: double.infinity,
        height: height,
        child: mapBuilder != null
            ? mapBuilder!(context)
            : Container(
                key: const Key('bc-map-placeholder'),
                color: BcTheme.muted,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Map (provide mapBuilder)',
                      key: Key('bc-map-title'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: BcTheme.foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      key: const Key('bc-map-meta'),
                      'center: ${center != null ? '${center!.lat.toStringAsFixed(4)}, ${center!.lng.toStringAsFixed(4)}' : '0.0000, 0.0000'} · zoom ${zoom.round()}',
                      style: const TextStyle(fontSize: 12, color: BcTheme.mutedForeground),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        key: const Key('bc-map-markers'),
                        children: markers
                            .map((m) => GestureDetector(
                                  key: Key('bc-map-marker-${m.id}'),
                                  onTap: () => _handleMarkerTap(m),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Text(
                                      '• ${m.label ?? m.id} (${m.lat.toStringAsFixed(4)}, ${m.lng.toStringAsFixed(4)})',
                                      style: const TextStyle(fontSize: 12, color: BcTheme.mutedForeground),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
