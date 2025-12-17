import 'package:eden_mind_app/features/notifications/notification_service.dart';
import 'package:eden_mind_app/features/notifications/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'notifications_page_test.mocks.dart';

@GenerateMocks([NotificationService])
void main() {
  late MockNotificationService mockService;

  setUp(() {
    mockService = MockNotificationService();

    // Default stubs
    when(mockService.initSampleNotifications()).thenAnswer((_) async {});
    when(mockService.getNotifications()).thenAnswer(
      (_) async => [
        {
          'id': 1,
          'title': 'Test Notification',
          'message': 'This is a test',
          'type': 'tip',
          'createdAt': DateTime.now().toIso8601String(),
          'isRead': false,
          'read': false,
        },
        {
          'id': 2,
          'title': 'Old Notification',
          'message': 'This is old',
          'type': 'reminder',
          'createdAt': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          'isRead': true,
          'read': true,
        },
      ],
    );
    when(mockService.markAsRead(any)).thenAnswer((_) async {});
    when(mockService.markAllAsRead()).thenAnswer((_) async {});
    when(mockService.deleteNotification(any)).thenAnswer((_) async {});
    when(mockService.clearAll()).thenAnswer((_) async {});
  });

  testWidgets('Renders notifications correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: NotificationsPage(notificationService: mockService)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('1 unread'), findsOneWidget);

    expect(find.text('Test Notification'), findsOneWidget);
    expect(find.text('This is a test'), findsOneWidget);
    expect(find.text('Old Notification'), findsOneWidget);
  });

  testWidgets('Marks notification as read', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: NotificationsPage(notificationService: mockService)),
    );
    await tester.pumpAndSettle();

    // Tap the first notification
    await tester.tap(find.text('Test Notification'));
    await tester.pump();

    verify(mockService.markAsRead(1)).called(1);
  });

  testWidgets('Deletes notification', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: NotificationsPage(notificationService: mockService)),
    );
    await tester.pumpAndSettle();

    // Dismiss (swipe)
    await tester.drag(find.text('Test Notification'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    verify(mockService.deleteNotification(1)).called(1);
    expect(find.text('Test Notification'), findsNothing);
  });

  testWidgets('Handles empty state', (WidgetTester tester) async {
    when(mockService.getNotifications()).thenAnswer((_) async => []);

    await tester.pumpWidget(
      MaterialApp(home: NotificationsPage(notificationService: mockService)),
    );
    await tester.pumpAndSettle();

    expect(find.text('No notifications'), findsOneWidget);
  });

  testWidgets('Handles error state', (WidgetTester tester) async {
    when(mockService.getNotifications()).thenThrow(Exception('Network error'));

    await tester.pumpWidget(
      MaterialApp(home: NotificationsPage(notificationService: mockService)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Failed to load notifications'), findsOneWidget);

    // Retry
    when(mockService.getNotifications()).thenAnswer((_) async => []);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('No notifications'), findsOneWidget);
  });
}
