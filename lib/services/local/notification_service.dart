// lib/services/notification_service.dart
import 'package:flutter/material.dart'; // ✅ tambahin ini
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
  }

  Future<void> showInstantNotification(String title, String body) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000; // ✅ biar ga ketimpa

    const androidDetails = AndroidNotificationDetails(
      'astroedu_channel',
      'AstroEdu Notifications',
      channelDescription: 'Notifikasi fenomena astronomi dan pembelajaran',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF3B82F6), // ✅ sekarang aman
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(id, title, body, details);
  }

  Future<void> scheduleDailyReminder() async {
    const androidDetails = AndroidNotificationDetails(
      'astroedu_daily',
      'AstroEdu Daily',
      channelDescription: 'Pengingat belajar astronomi harian',
      importance: Importance.defaultImportance,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      1,
      '🌟 Waktunya Belajar Astronomi!',
      'Cek fenomena langit malam ini dan baca materi terbaru di AstroEdu',
      _nextInstanceOfTime(20, 0),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleEclipseReminder(String eclipseName, DateTime date) async {
    if (date.isBefore(DateTime.now())) return; // ✅ biar aman

    const androidDetails = AndroidNotificationDetails(
      'astroedu_events',
      'AstroEdu Events',
      channelDescription: 'Pengingat fenomena astronomi',
      importance: Importance.high,
    );
    const details = NotificationDetails(android: androidDetails);

    final notifTime = date.subtract(const Duration(hours: 1));

    if (notifTime.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        date.millisecondsSinceEpoch ~/ 1000, // ✅ id unik
        '🌑 Fenomena Langit Segera!',
        '$eclipseName akan terjadi dalam 1 jam! Siapkan teleskopmu!',
        tz.TZDateTime.from(notifTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}