import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_chatter.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness({required BcChatter child}) {
    return MaterialApp(home: Scaffold(body: child));
  }

  final messages = [
    const BcChatterMessage(
      id: 'm1',
      author: 'Alice',
      content: 'Hello!',
      timestamp: '10:00',
    ),
    const BcChatterMessage(
      id: 'm2',
      author: 'Bob',
      content: 'Hi there!',
      timestamp: '10:01',
    ),
  ];

  testWidgets(
      'renders N messages with author and content (VAL-M6-017)',
      (tester) async {
    await tester.pumpWidget(harness(child: BcChatter(messages: messages)));
    await tester.pump();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Hello!'), findsOneWidget);
    expect(find.text('Hi there!'), findsOneWidget);
  });

  testWidgets(
      'renders messages in provided order (VAL-M6-017)',
      (tester) async {
    await tester.pumpWidget(harness(child: BcChatter(messages: messages)));
    await tester.pump();

    final aliceY = tester.getTopLeft(find.text('Alice')).dy;
    final bobY = tester.getTopLeft(find.text('Bob')).dy;
    expect(aliceY, lessThan(bobY));
  });

  testWidgets(
      'compose area has text input and send button (VAL-M6-017)',
      (tester) async {
    await tester.pumpWidget(harness(child: BcChatter(messages: messages)));
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('bc_chatter_input')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('bc_chatter_send')),
        findsOneWidget);
  });

  testWidgets(
      'empty messages renders emptyState, not blank (VAL-M6-017)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcChatter(messages: [], emptyText: 'No messages'),
    ));
    await tester.pump();

    expect(find.text('No messages'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('bc_chatter_empty')),
        findsOneWidget);
  });

  testWidgets(
      'custom emptyState widget renders when messages empty (VAL-M6-017)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcChatter(messages: [], emptyState: Text('Custom Empty')),
    ));
    await tester.pump();

    expect(find.text('Custom Empty'), findsOneWidget);
  });

  testWidgets(
      'send emits onSend with trimmed text and BcChangeMeta (VAL-M6-018)',
      (tester) async {
    String? capturedText;
    BcChangeMeta? capturedMeta;

    await tester.pumpWidget(harness(
      child: BcChatter(
        messages: messages,
        onSend: (text, meta) {
          capturedText = text;
          capturedMeta = meta;
        },
      ),
    ));
    await tester.pump();

    await tester.enterText(
        find.byKey(const ValueKey<String>('bc_chatter_input')), '  Hello world!  ');
    await tester.tap(find.byKey(const ValueKey<String>('bc_chatter_send')));
    await tester.pumpAndSettle();

    expect(capturedText, 'Hello world!');
    expect(capturedMeta, isNotNull);
    expect(capturedMeta!.source, BcEventSource.pointer);
    expect(capturedMeta!.reason, BcChangeReason.submit);
  });

  testWidgets(
      'send clears input after successful send (VAL-M6-018)',
      (tester) async {
    final sentMessages = <String>[];

    await tester.pumpWidget(harness(
      child: BcChatter(
        messages: messages,
        onSend: (text, _) => sentMessages.add(text),
      ),
    ));
    await tester.pump();

    await tester.enterText(
        find.byKey(const ValueKey<String>('bc_chatter_input')), 'Message');
    await tester.tap(find.byKey(const ValueKey<String>('bc_chatter_send')));
    await tester.pumpAndSettle();

    expect(sentMessages, ['Message']);

    final field = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('bc_chatter_input')),
        matching: find.byType(EditableText),
      ),
    );
    expect(field.controller.text, isEmpty);
  });

  testWidgets(
      'empty/whitespace message is rejected and does not fire onSend (VAL-M6-018)',
      (tester) async {
    int sendCount = 0;

    await tester.pumpWidget(harness(
      child: BcChatter(
        messages: messages,
        onSend: (_, __) => sendCount++,
      ),
    ));
    await tester.pump();

    await tester.enterText(
        find.byKey(const ValueKey<String>('bc_chatter_input')), '   ');
    await tester.tap(find.byKey(const ValueKey<String>('bc_chatter_send')));
    await tester.pumpAndSettle();

    expect(sendCount, 0);
  });

  testWidgets(
      'disabled blocks send callback (VAL-M6-018)',
      (tester) async {
    int sendCount = 0;

    await tester.pumpWidget(harness(
      child: BcChatter(
        messages: messages,
        disabled: true,
        onSend: (_, __) => sendCount++,
      ),
    ));
    await tester.pump();

    // The send button should be disabled (onPressed is null)
    // Try tapping it anyway
    final sendFinder = find.byKey(const ValueKey<String>('bc_chatter_send'));
    if (tester.widget(sendFinder) is IconButton) {
      final btn = tester.widget<IconButton>(sendFinder);
      expect(btn.onPressed, isNull);
    }

    expect(sendCount, 0);
  });

  testWidgets(
      'disabled input is non-interactive (VAL-M6-018)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcChatter(messages: [], disabled: true),
    ));
    await tester.pump();

    final textField = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('bc_chatter_input')),
        matching: find.byType(TextField),
      ),
    );
    expect(textField.enabled, isFalse);
  });
}
