import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_map.dart';

void main() {
  group('BcMap', () {
    Widget buildHarness({
      BcMapLatLng? center,
      double zoom = 13,
      List<BcMapMarker> markers = const [],
      double height = 400,
      Widget Function(BuildContext context)? mapBuilder,
      void Function(BcMapMarker marker, BcChangeMeta meta)? onMarkerClick,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BcMap(
            center: center,
            zoom: zoom,
            markers: markers,
            height: height,
            mapBuilder: mapBuilder,
            onMarkerClick: onMarkerClick,
          ),
        ),
      );
    }

    final markers = [
      const BcMapMarker(id: 'm1', lat: 40.7128, lng: -74.0060, label: 'NYC'),
      const BcMapMarker(id: 'm2', lat: 34.0522, lng: -118.2437),
    ];

    testWidgets('placeholder renders root + title + meta (VAL-C-009)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        center: const BcMapLatLng(lat: 40.7128, lng: -74.0060),
        markers: markers,
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-map-root')), findsOneWidget);
      expect(find.byKey(const Key('bc-map-placeholder')), findsOneWidget);
      expect(find.byKey(const Key('bc-map-title')), findsOneWidget);
      expect(find.byKey(const Key('bc-map-meta')), findsOneWidget);
    });

    testWidgets('renders marker list (VAL-C-010)', (tester) async {
      await tester.pumpWidget(buildHarness(markers: markers));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-map-marker-m1')), findsOneWidget);
      expect(find.byKey(const Key('bc-map-marker-m2')), findsOneWidget);
      expect(find.textContaining('NYC'), findsOneWidget);
    });

    testWidgets('mapBuilder replaces placeholder (VAL-C-011)', (tester) async {
      await tester.pumpWidget(buildHarness(
        markers: markers,
        mapBuilder: (_) => const ColoredBox(
          key: Key('custom-map'),
          color: Color(0xFF000000),
          child: SizedBox.expand(),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('custom-map')), findsOneWidget);
      expect(find.byKey(const Key('bc-map-placeholder')), findsNothing);
    });

    testWidgets('marker tap fires onMarkerClick + pointer (VAL-C-012)',
        (tester) async {
      BcMapMarker? captured;
      BcChangeMeta? meta;
      await tester.pumpWidget(buildHarness(
        markers: markers,
        onMarkerClick: (m, mt) {
          captured = m;
          meta = mt;
        },
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-map-marker-m1')));
      await tester.pumpAndSettle();
      expect(captured, isNotNull);
      expect(captured!.id, 'm1');
      expect(meta, isNotNull);
      expect(meta!.source, BcEventSource.pointer);
    });

    testWidgets('renders interactive map semantics label (VAL-C-013)',
        (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();
      final semantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'interactive map',
      );
      expect(semantics, findsOneWidget);
    });

    testWidgets('empty markers renders without error (VAL-C-014)',
        (tester) async {
      await tester.pumpWidget(buildHarness(markers: const []));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-map-markers')), findsOneWidget);
    });
  });
}
