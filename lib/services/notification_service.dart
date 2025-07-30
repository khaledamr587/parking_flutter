import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../constants/app_constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    
    await _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Schedule a reservation reminder notification
  Future<void> scheduleReservationReminder(
    int reservationId,
    String parkingName,
    DateTime startTime,
  ) async {
    final reminderTime = startTime.subtract(
      Duration(minutes: AppConstants.notificationReminderMinutes),
    );

    if (reminderTime.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        reservationId,
        'Parking Reminder',
        'Your parking reservation at $parkingName starts in ${AppConstants.notificationReminderMinutes} minutes',
        tz.TZDateTime.from(reminderTime, tz.local),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'parking_reminders',
            'Parking Reminders',
            channelDescription: 'Notifications for parking reservation reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'reservation_reminder_$reservationId',
      );
    }
  }

  // Schedule an expiry notification
  Future<void> scheduleExpiryNotification(
    int reservationId,
    String parkingName,
    DateTime endTime,
  ) async {
    final expiryTime = endTime.subtract(
      Duration(minutes: AppConstants.notificationExpiryMinutes),
    );

    if (expiryTime.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        reservationId + 10000, // Different ID to avoid conflicts
        'Parking Expiry',
        'Your parking reservation at $parkingName expires in ${AppConstants.notificationExpiryMinutes} minutes',
        tz.TZDateTime.from(expiryTime, tz.local),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'parking_expiry',
            'Parking Expiry',
            channelDescription: 'Notifications for parking reservation expiry',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'reservation_expiry_$reservationId',
      );
    }
  }

  // Show immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general',
          'General',
          channelDescription: 'General notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    await _notifications.cancel(id + 10000); // Also cancel expiry notification
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap based on payload
    if (response.payload != null) {
      if (response.payload!.startsWith('reservation_reminder_')) {
        final reservationId = int.parse(
          response.payload!.replaceAll('reservation_reminder_', ''),
        );
        // Navigate to reservation details
        _handleReservationNavigation(reservationId);
      } else if (response.payload!.startsWith('reservation_expiry_')) {
        final reservationId = int.parse(
          response.payload!.replaceAll('reservation_expiry_', ''),
        );
        // Navigate to reservation details
        _handleReservationNavigation(reservationId);
      }
    }
  }

  void _handleReservationNavigation(int reservationId) {
    // This will be handled by the app's navigation system
    // You can use a global navigator key or event bus to handle this
  }

  // Show success notification
  Future<void> showSuccessNotification(String message) async {
    await showNotification(
      title: 'Success',
      body: message,
      payload: 'success',
    );
  }

  // Show error notification
  Future<void> showErrorNotification(String message) async {
    await showNotification(
      title: 'Error',
      body: message,
      payload: 'error',
    );
  }

  // Show payment notification
  Future<void> showPaymentNotification({
    required String amount,
    required String parkingName,
  }) async {
    await showNotification(
      title: 'Payment Successful',
      body: 'Payment of $amount processed for $parkingName',
      payload: 'payment_success',
    );
  }

  // Show booking confirmation
  Future<void> showBookingConfirmation({
    required String parkingName,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final startTimeStr = '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
    final endTimeStr = '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';
    
    await showNotification(
      title: 'Booking Confirmed',
      body: 'Your parking at $parkingName is confirmed for $startTimeStr - $endTimeStr',
      payload: 'booking_confirmed',
    );
  }
} 