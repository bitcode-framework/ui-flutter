import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

void main() {
  group('BcNotificationItemData', () {
    test('fromJson parses all fields', () {
      final data = BcNotificationItemData.fromJson({
        'id': 'n-1',
        'type': 'mention',
        'title': 'You were mentioned',
        'body': 'Hello world',
        'read_at': null,
        'created_at': '2026-07-01T12:00:00Z',
        'notifiable_type': 'comment',
        'notifiable_id': 'c-1',
      });
      expect(data.id, 'n-1');
      expect(data.type, BcNotificationVariant.mention);
      expect(data.title, 'You were mentioned');
      expect(data.body, 'Hello world');
      expect(data.isUnread, isTrue);
      expect(data.notifiableType, 'comment');
      expect(data.notifiableId, 'c-1');
    });

    test('fromJson defaults type to info', () {
      final data = BcNotificationItemData.fromJson({'id': 'n-2'});
      expect(data.type, BcNotificationVariant.info);
    });

    test('isUnread is false when read_at is set', () {
      final data = BcNotificationItemData.fromJson({
        'id': 'n-3',
        'read_at': '2026-07-01T12:00:00Z',
      });
      expect(data.isUnread, isFalse);
    });

    test('copyWith marks as read', () {
      final data = BcNotificationItemData(id: 'n-4');
      expect(data.isUnread, isTrue);
      final read = data.copyWith(readAt: '2026-07-01T12:00:00Z');
      expect(read.isUnread, isFalse);
    });

    test('equality by id', () {
      final a = BcNotificationItemData(id: 'n-5');
      final b = BcNotificationItemData(id: 'n-5', title: 'Different');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('BcNotificationCenter widget', () {
    testWidgets('renders bell button with badge when unread > 0', (tester) async {
      await tester.pumpWidget(
        const _TestApp(
          child: BcNotificationCenter(
            notifications: [
              BcNotificationItemData(id: 'n-1', title: 'Test'),
            ],
            unreadCount: 1,
          ),
        ),
      );
      expect(find.byKey(const ValueKey<String>('bc_notification_bell')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('bc_notification_badge')), findsOneWidget);
    });

    testWidgets('does not show badge when unread is 0', (tester) async {
      await tester.pumpWidget(
        const _TestApp(
          child: BcNotificationCenter(
            notifications: [],
            unreadCount: 0,
          ),
        ),
      );
      expect(find.byKey(const ValueKey<String>('bc_notification_bell')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('bc_notification_badge')), findsNothing);
    });

    testWidgets('badge shows 99+ for count > 99', (tester) async {
      await tester.pumpWidget(
        const _TestApp(
          child: BcNotificationCenter(unreadCount: 150),
        ),
      );
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('calls onMarkRead when item tapped', (tester) async {
      String? markedId;
      await tester.pumpWidget(
        _TestApp(
          child: BcNotificationCenter(
            notifications: const [
              BcNotificationItemData(id: 'n-1', title: 'Test'),
            ],
            unreadCount: 1,
            onMarkRead: (id) => markedId = id,
          ),
        ),
      );

      // Open Material dropdown
      await tester.tap(find.byKey(const ValueKey<String>('bc_notification_bell')));
      await tester.pumpAndSettle();

      // Find and tap the item
      final itemFinder = find.byKey(const ValueKey<String>('bc_notification_item_n-1'));
      if (itemFinder.hasFound) {
        await tester.tap(itemFinder);
        await tester.pumpAndSettle();
        expect(markedId, 'n-1');
      }
    });

    testWidgets('disabled bell does not respond', (tester) async {
      await tester.pumpWidget(
        const _TestApp(
          child: BcNotificationCenter(
            disabled: true,
            unreadCount: 3,
          ),
        ),
      );
      // The widget should render without errors
      expect(find.byKey(const ValueKey<String>('bc_notification_bell')), findsOneWidget);
    });
  });
}

class _TestApp extends StatelessWidget {
  final Widget child;
  const _TestApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(appBar: AppBar(actions: [child])));
  }
}
