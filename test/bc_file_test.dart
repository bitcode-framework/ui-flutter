import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_file.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) =>
      MaterialApp(home: Scaffold(body: child));

  group('VAL-M2-020 — single file pick emits one-element list with meta', () {
    testWidgets('picking one file emits a length-1 list with select reason and pointer source',
        (tester) async {
      List<BcFileRef>? capturedFiles;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcFile(
          onChange: (files, meta) {
            capturedFiles = files;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_file_browse')), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc_file_browse')));
      await tester.pumpAndSettle();

      expect(capturedFiles, isNotNull);
      expect(capturedFiles!.length, 1);
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, BcChangeReason.select);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets('selected file name renders in the file list', (tester) async {
      await tester.pumpWidget(harness(
        const BcFile(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_file_browse')));
      await tester.pumpAndSettle();

      expect(find.text('file_1.bin'), findsOneWidget);
    });

    testWidgets('multiple=false replaces on second pick', (tester) async {
      List<BcFileRef>? capturedFiles;

      await tester.pumpWidget(harness(
        BcFile(
          multiple: false,
          onChange: (files, meta) {
            capturedFiles = files;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_file_browse')));
      await tester.pumpAndSettle();
      expect(capturedFiles!.length, 1);

      await tester.tap(find.byKey(const Key('bc_file_browse')));
      await tester.pumpAndSettle();
      expect(capturedFiles!.length, 1);
    });
  });

  group('VAL-M2-021 — multiple appends, maxSize/accept filter, disabled', () {
    testWidgets('multiple=true appends to the file list on successive picks',
        (tester) async {
      List<BcFileRef>? capturedFiles;

      await tester.pumpWidget(harness(
        BcFile(
          multiple: true,
          onChange: (files, meta) {
            capturedFiles = files;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_file_browse')));
      await tester.pumpAndSettle();
      expect(capturedFiles!.length, 1);

      await tester.tap(find.byKey(const Key('bc_file_browse')));
      await tester.pumpAndSettle();
      expect(capturedFiles!.length, 2);
    });

    testWidgets('maxSize rejects files exceeding the limit', (tester) async {
      List<BcFileRef>? capturedFiles;

      await tester.pumpWidget(harness(
        BcFile(
          multiple: true,
          maxSize: 1000,
          onChange: (files, meta) {
            capturedFiles = files;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_file_browse')));
      await tester.pumpAndSettle();

      expect(capturedFiles, isNull);
    });

    testWidgets('accept filter rejects non-matching MIME types', (tester) async {
      List<BcFileRef>? capturedFiles;

      await tester.pumpWidget(harness(
        BcFile(
          multiple: true,
          accept: 'image/png',
          onChange: (files, meta) {
            capturedFiles = files;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_file_browse')));
      await tester.pumpAndSettle();

      expect(capturedFiles, isNull);
    });

    testWidgets('disabled blocks browse and fires no onChange', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        BcFile(
          disabled: true,
          onChange: (files, meta) {
            callCount++;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_file_browse')));
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });
  });
}
