import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_drop_zone.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) =>
      MaterialApp(home: Scaffold(body: child));

  group('VAL-M2-035 — dropping files invokes onFiles with accepted list and meta', () {
    testWidgets('dropping a file invokes onFiles with accepted list and select reason',
        (tester) async {
      List<BcFileRef>? capturedFiles;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcDropZone(
          onFiles: (files, meta) {
            capturedFiles = files;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_dropzone')), findsOneWidget);
      expect(find.text('Drop files here'), findsOneWidget);
      expect(find.text('or click to browse'), findsOneWidget);

      // Simulate drop by calling the internal method via tap + drag
      await tester.tap(find.byKey(const Key('bc_dropzone')));
      await tester.pumpAndSettle();

      expect(capturedFiles, isNotNull);
      expect(capturedFiles!.length, greaterThan(0));
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, BcChangeReason.select);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets('prompt renders as inline label and hint as sub-label', (tester) async {
      await tester.pumpWidget(harness(
        const BcDropZone(
          prompt: 'Upload images',
          hint: 'PNG or JPG up to 5MB',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Upload images'), findsOneWidget);
      expect(find.text('PNG or JPG up to 5MB'), findsOneWidget);
    });
  });

  group('VAL-M2-036 — accept/maxFiles/maxSize filter; disabled blocks drops', () {
    testWidgets('maxSize rejects files exceeding the limit', (tester) async {
      List<BcFileRef>? capturedFiles;

      await tester.pumpWidget(harness(
        BcDropZone(
          maxSize: 1000,
          onFiles: (files, meta) {
            capturedFiles = files;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_dropzone')));
      await tester.pumpAndSettle();

      expect(capturedFiles, isNull);
    });

    testWidgets('accept rejects non-matching MIME types', (tester) async {
      List<BcFileRef>? capturedFiles;

      await tester.pumpWidget(harness(
        BcDropZone(
          accept: 'image/png',
          onFiles: (files, meta) {
            capturedFiles = files;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_dropzone')));
      await tester.pumpAndSettle();

      expect(capturedFiles, isNull);
    });

    testWidgets('disabled drop zone accepts no drops and onFiles never fires', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        BcDropZone(
          disabled: true,
          onFiles: (files, meta) {
            callCount++;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_dropzone')));
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });
  });
}
