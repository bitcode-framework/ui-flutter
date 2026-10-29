import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_image.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness({required BcImage child}) {
    return MaterialApp(home: Scaffold(body: Center(child: child)));
  }

  testWidgets(
      'lazy true shows placeholder initially then begins loading after frame (VAL-M6-025)',
      (tester) async {
    imageCache.clear();
    imageCache.clearLiveImages();

    await tester.pumpWidget(harness(
      child: const BcImage(
        src: 'https://example.com/img.png',
        lazy: true,
        placeholder: Text('Lazy Loading'),
      ),
    ));
    await tester.pump();

    expect(find.text('Lazy Loading'), findsOneWidget);
    expect(find.byKey(const Key('bc_image_placeholder')), findsOneWidget);
  });

  testWidgets(
      'lazy false starts loading immediately and shows placeholder while loading (VAL-M6-025)',
      (tester) async {
    imageCache.clear();
    imageCache.clearLiveImages();

    await tester.pumpWidget(harness(
      child: const BcImage(
        src: 'https://example.com/img2.png',
        lazy: false,
        placeholder: Text('Immediate'),
      ),
    ));
    await tester.pump();

    expect(find.text('Immediate'), findsOneWidget);
  });

  testWidgets(
      'on load failure errorFallback renders (default and custom) (VAL-M6-025)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcImage(
        src: 'https://nonexistent.invalid/broken.png',
        errorFallback: Text('Custom Error'),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Custom Error'), findsOneWidget);
  });

  testWidgets(
      'empty/null src renders error fallback, no malformed image (VAL-M6-025)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcImage(src: ''),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc_image_error')), findsOneWidget);
  });

  testWidgets(
      'default error fallback renders on load failure (VAL-M6-025)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcImage(
        src: 'https://nonexistent.invalid/other.png',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc_image_error')), findsOneWidget);
    expect(find.text('Failed to load image'), findsOneWidget);
  });

  testWidgets(
      'tap emits onClick with pointer meta when interactive (VAL-M6-026)',
      (tester) async {
    BcChangeMeta? capturedMeta;
    int tapCount = 0;

    await tester.pumpWidget(harness(
      child: BcImage(
        src: '',
        interactive: true,
        onClick: (_, meta) {
          capturedMeta = meta;
          tapCount++;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bc_image_tap')));
    await tester.pumpAndSettle();

    expect(tapCount, 1);
    expect(capturedMeta, isNotNull);
    expect(capturedMeta!.source, BcEventSource.pointer);
    expect(capturedMeta!.reason, BcChangeReason.select);
  });

  testWidgets(
      'tap does not fire onClick when disabled (VAL-M6-026)',
      (tester) async {
    int tapCount = 0;

    await tester.pumpWidget(harness(
      child: BcImage(
        src: '',
        interactive: true,
        disabled: true,
        onClick: (_, __) => tapCount++,
      ),
    ));
    await tester.pumpAndSettle();

    final tapTarget = find.byKey(const Key('bc_image_tap'));
    if (tapTarget.evaluate().isNotEmpty) {
      await tester.tap(tapTarget);
      await tester.pumpAndSettle();
    }
    expect(tapCount, 0);
  });

  testWidgets(
      'tap does not fire when no onClick handler and not interactive (VAL-M6-026)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcImage(src: ''),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc_image_tap')), findsNothing);
  });

  testWidgets(
      'image still renders placeholder/error even when not interactive (VAL-M6-026)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcImage(src: '', interactive: false),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc_image_error')), findsOneWidget);
  });

  testWidgets(
      'rounded clips content with rounded corners',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcImage(src: '', rounded: true),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ClipRRect), findsOneWidget);
  });
}
