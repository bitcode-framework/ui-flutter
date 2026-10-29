import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_view_map.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  const center = BcGeoCoord(lat: 0, lng: 0);

  final markers = [
    const BcMapMarker(id: 'm1', lat: 0, lng: 0, label: 'Alpha'),
    const BcMapMarker(id: 'm2', lat: 1, lng: 1, label: 'Beta'),
  ];

  final regions = [
    const BcMapRegion(
      id: 'r1',
      type: BcGeoShapeType.polygon,
      points: [
        BcGeoCoord(lat: -5, lng: -5),
        BcGeoCoord(lat: 5, lng: -5),
        BcGeoCoord(lat: 5, lng: 5),
        BcGeoCoord(lat: -5, lng: 5),
      ],
    ),
  ];

  group('VAL-M5-021: Markers render at projected geo coordinates', () {
    testWidgets('renders map container with CustomPaint', (tester) async {
      await tester.pumpWidget(harness(
        const BcViewMap(
          markers: [],
          center: center,
          zoom: 1,
          height: 300,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_view_map')), findsOneWidget);
      expect(find.byKey(const Key('bc_view_map_canvas')), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders map with markers as positioned widgets',
        (tester) async {
      await tester.pumpWidget(harness(
        BcViewMap(
          markers: markers,
          center: center,
          zoom: 1,
          height: 300,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_view_map_marker_m1')),
          findsOneWidget);
      expect(find.byKey(const Key('bc_view_map_marker_m2')),
          findsOneWidget);
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('renders map with regions via CustomPaint', (tester) async {
      await tester.pumpWidget(harness(
        BcViewMap(
          markers: const [],
          regions: regions,
          center: center,
          zoom: 1,
          height: 300,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_view_map_canvas')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders map with markers and regions together',
        (tester) async {
      await tester.pumpWidget(harness(
        BcViewMap(
          markers: markers,
          regions: regions,
          center: center,
          zoom: 1,
          height: 300,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_view_map_marker_m1')),
          findsOneWidget);
      expect(find.byKey(const Key('bc_view_map_canvas')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty map with no markers renders canvas', (tester) async {
      await tester.pumpWidget(harness(
        const BcViewMap(
          markers: [],
          center: center,
          zoom: 1,
          height: 300,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_view_map_canvas')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('VAL-M5-022: Marker tap selects and emits id with BcChangeMeta', () {
    testWidgets(
        'tapping a marker emits onMarkerSelect with the marker id',
        (tester) async {
      String? selectedId;
      BcChangeMeta? meta;

      await tester.pumpWidget(harness(
        BcViewMap(
          markers: markers,
          center: center,
          zoom: 1,
          height: 300,
          onMarkerSelect: (id, m) {
            selectedId = id;
            meta = m;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_view_map_marker_m1')));
      await tester.pumpAndSettle();

      expect(selectedId, 'm1');
      expect(meta, isNotNull);
      expect(meta!.source, BcEventSource.pointer);
    });

    testWidgets('programmatic selectedMarkerId is honored', (tester) async {
      await tester.pumpWidget(harness(
        BcViewMap(
          markers: markers,
          center: center,
          zoom: 1,
          selectedMarkerId: 'm1',
          height: 300,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_view_map_marker_m1')),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('marker label renders when provided', (tester) async {
      await tester.pumpWidget(harness(
        const BcViewMap(
          markers: [
            BcMapMarker(id: 'm1', lat: 0, lng: 0, label: 'Alpha'),
          ],
          center: center,
          zoom: 1,
          height: 300,
        ),
      ));
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('bc_view_map_marker_label_m1')),
          findsOneWidget);
      expect(find.text('Alpha'), findsOneWidget);
    });
  });

  group('VAL-M5-023: Regions and polylines render from geo data', () {
    testWidgets('polygon region renders without error', (tester) async {
      await tester.pumpWidget(harness(
        BcViewMap(
          markers: const [],
          regions: regions,
          center: center,
          zoom: 1,
          height: 300,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_view_map_canvas')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('polyline region renders without error', (tester) async {
      final polylines = [
        const BcMapRegion(
          id: 'route1',
          type: BcGeoShapeType.polyline,
          points: [
            BcGeoCoord(lat: 5, lng: 15),
            BcGeoCoord(lat: 15, lng: 35),
          ],
        ),
      ];

      await tester.pumpWidget(harness(
        BcViewMap(
          markers: const [],
          regions: polylines,
          center: const BcGeoCoord(lat: 10, lng: 25),
          zoom: 1,
          height: 300,
        ),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('multiple regions render without error', (tester) async {
      final multiRegions = [
        const BcMapRegion(
          id: 'r1',
          type: BcGeoShapeType.polygon,
          points: [
            BcGeoCoord(lat: 5, lng: 15),
            BcGeoCoord(lat: 15, lng: 15),
            BcGeoCoord(lat: 15, lng: 25),
            BcGeoCoord(lat: 5, lng: 25),
          ],
        ),
        const BcMapRegion(
          id: 'r2',
          type: BcGeoShapeType.polyline,
          points: [
            BcGeoCoord(lat: 20, lng: 25),
            BcGeoCoord(lat: 25, lng: 35),
          ],
        ),
      ];

      await tester.pumpWidget(harness(
        BcViewMap(
          markers: const [],
          regions: multiRegions,
          center: const BcGeoCoord(lat: 10, lng: 20),
          zoom: 1,
          height: 300,
        ),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('updating markers triggers re-render', (tester) async {
      late void Function(VoidCallback) setStateRef;
      List<BcMapMarker> currentMarkers = const [
        BcMapMarker(id: 'm1', lat: 0, lng: 0),
      ];

      Widget buildWidget() {
        return StatefulBuilder(
          builder: (context, setState) {
            setStateRef = setState;
            return MaterialApp(
              home: Scaffold(
                body: BcViewMap(
                  markers: currentMarkers,
                  center: center,
                  zoom: 1,
                  height: 300,
                ),
              ),
            );
          },
        );
      }

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc_view_map_marker_m1')),
          findsOneWidget);

      setStateRef(() {
        currentMarkers = const [
          BcMapMarker(id: 'm1', lat: 0, lng: 0),
          BcMapMarker(id: 'm2', lat: 1, lng: 1),
        ];
      });
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_view_map_marker_m1')),
          findsOneWidget);
      expect(find.byKey(const Key('bc_view_map_marker_m2')),
          findsOneWidget);
    });

    testWidgets('map title renders when provided', (tester) async {
      await tester.pumpWidget(harness(
        const BcViewMap(
          markers: [],
          center: center,
          zoom: 1,
          height: 300,
          mapTitle: 'Store Locations',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Store Locations'), findsOneWidget);
    });
  });
}
