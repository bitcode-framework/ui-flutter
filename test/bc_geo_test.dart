import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_geo.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) =>
      MaterialApp(home: Scaffold(body: child));

  group('VAL-M2-030 — picking coordinates emits {lat, lng} with select reason', () {
    testWidgets('tapping the map emits coordinate with select reason and pointer source',
        (tester) async {
      BcGeoCoord? captured;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcGeo(
          width: 300,
          height: 200,
          onValueChange: (coord, meta) {
            captured = coord;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_geo_map')));
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, BcChangeReason.select);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets('picked location renders a marker at chosen coordinates', (tester) async {
      await tester.pumpWidget(harness(
        BcGeo(
          width: 300,
          height: 200,
          onValueChange: (coord, meta) {},
        ),
      ));
      await tester.pumpAndSettle();

      // No marker initially
      expect(find.byKey(const Key('bc_geo_marker')), findsNothing);

      await tester.tap(find.byKey(const Key('bc_geo_map')));
      await tester.pumpAndSettle();

      // After tap, marker appears
      expect(find.byKey(const Key('bc_geo_marker')), findsOneWidget);
    });

    testWidgets('manual coordinate entry via inputs emits lat/lng value', (tester) async {
      BcGeoCoord? captured;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcGeo(
          onValueChange: (coord, meta) {
            captured = coord;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('bc_geo_lat_input')),
        '-6.2',
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('bc_geo_lng_input')),
        '106.8',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_geo_apply')));
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.lat.toStringAsFixed(1), '-6.2');
      expect(captured!.lng.toStringAsFixed(1), '106.8');
      expect(capturedMeta!.reason, BcChangeReason.select);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });
  });

  group('VAL-M2-031 — controlled coordinate renders marker; disabled blocks picking', () {
    testWidgets('controlled value renders marker at given coordinate', (tester) async {
      await tester.pumpWidget(harness(
        const BcGeo(
          value: BcGeoCoord(lat: -6.2, lng: 106.8),
          width: 300,
          height: 200,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_geo_marker')), findsOneWidget);
    });

    testWidgets('disabled blocks map tap and onChange never fires', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        BcGeo(
          disabled: true,
          width: 300,
          height: 200,
          onValueChange: (coord, meta) {
            callCount++;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_geo_map')));
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });

    testWidgets('disabled blocks manual coordinate entry', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        BcGeo(
          disabled: true,
          onValueChange: (coord, meta) {
            callCount++;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('bc_geo_lat_input')),
        '-6.2',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_geo_apply')));
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });
  });
}
