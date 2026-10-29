import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_share.dart';

void main() {
  group('BcShare', () {
    Widget buildHarness({
      String? title,
      String? text,
      String? url,
      String label = 'Share',
      bool disabled = false,
      BcChangeHandler<BcShareResult>? onShare,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BcShare(
            title: title,
            text: text,
            url: url,
            label: label,
            disabled: disabled,
            onShare: onShare,
          ),
        ),
      );
    }

    testWidgets('renders trigger button with label (VAL-B4-001)', (tester) async {
      await tester.pumpWidget(buildHarness(label: 'Share'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-share-trigger')), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('tap invokes onShare with pointer source + shared result (VAL-B4-002)',
        (tester) async {
      BcShareResult? captured;
      BcChangeMeta? meta;
      await tester.pumpWidget(buildHarness(
        url: 'https://example.com',
        onShare: (v, m) {
          captured = v;
          meta = m;
        },
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-share-trigger')));
      await tester.pumpAndSettle();
      expect(captured, BcShareResult.shared);
      expect(meta, isNotNull);
      expect(meta!.source, BcEventSource.pointer);
    });

    testWidgets('disabled trigger does not fire onShare (VAL-B4-003)',
        (tester) async {
      bool fired = false;
      await tester.pumpWidget(buildHarness(
        disabled: true,
        onShare: (_, __) => fired = true,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-share-trigger')));
      await tester.pumpAndSettle();
      expect(fired, isFalse);
    });

    testWidgets('custom label renders (VAL-B4-004)', (tester) async {
      await tester.pumpWidget(buildHarness(label: 'Share Link'));
      await tester.pumpAndSettle();
      expect(find.text('Share Link'), findsOneWidget);
    });

    testWidgets('BcSharePayload.message composes text+url (VAL-B4-005)',
        (tester) async {
      const payload = BcSharePayload(
        text: 'Check this out',
        url: 'https://example.com',
      );
      expect(payload.message, 'Check this out https://example.com');
      const urlOnly = BcSharePayload(url: 'https://example.com');
      expect(urlOnly.message, 'https://example.com');
      const textOnly = BcSharePayload(text: 'Just text');
      expect(textOnly.message, 'Just text');
      const empty = BcSharePayload();
      expect(empty.message, isNull);
    });
  });
}
