import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }

  static Future<void> requestPermissions() async {
    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();

    final iosImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Show immediate notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'raptor_fitt_channel',
      'Raptor Fitt Notifications',
      channelDescription: 'Notifications for Raptor Fitt app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Schedule notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'raptor_fitt_channel',
      'Raptor Fitt Notifications',
      channelDescription: 'Notifications for Raptor Fitt app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  // Smart notifications based on user behavior
  static Future<void> sendRecoveryAlert({
    required double recoveryScore,
    required String message,
  }) async {
    await showNotification(
      id: 1,
      title: 'Recovery Alert 💤',
      body: message,
    );
  }

  static Future<void> sendWorkoutReminder() async {
    await showNotification(
      id: 2,
      title: 'Time to Train 💪',
      body: 'Your muscles are ready. Let\'s crush it!',
    );
  }

  static Future<void> sendStreakReminder({required int streak}) async {
    await showNotification(
      id: 3,
      title: 'Keep the Streak Alive 🔥',
      body: 'You\'re on a $streak day streak! Don\'t break it now.',
    );
  }

  static Future<void> sendPRCelebration({
    required String exercise,
    required double weight,
  }) async {
    await showNotification(
      id: 4,
      title: 'New PR! 🎉',
      body: 'You just hit $weight kg on $exercise!',
    );
  }

  static Future<void> sendDeloadRecommendation() async {
    await showNotification(
      id: 5,
      title: 'Time to Deload 🌊',
      body: 'Your body needs recovery. Consider a deload week.',
    );
  }

  // Cancel notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
