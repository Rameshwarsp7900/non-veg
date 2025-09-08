import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initializationSettings);
  }

  static Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Diet Reminders',
          channelDescription: 'Daily reminders about dietary restrictions',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleEventReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_reminder',
          'Event Reminders',
          channelDescription: 'Reminders for special dietary events',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = TZDateTime.now(tz.local);
    var scheduledDate = TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }
}

// Timezone imports (these would be imported from timezone package)
class TZDateTime {
  final DateTime dateTime;
  
  TZDateTime(dynamic local, int year, int month, int day, int hour, int minute)
      : dateTime = DateTime(year, month, day, hour, minute);
  
  TZDateTime.from(DateTime dateTime, dynamic local) : dateTime = dateTime;
  
  static TZDateTime now(dynamic local) => TZDateTime.from(DateTime.now(), local);
  
  bool isBefore(TZDateTime other) => dateTime.isBefore(other.dateTime);
  TZDateTime add(Duration duration) => TZDateTime.from(dateTime.add(duration), null);
  
  int get year => dateTime.year;
  int get month => dateTime.month;
  int get day => dateTime.day;
}

class tz {
  static const local = null;
}