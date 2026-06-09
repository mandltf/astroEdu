import 'dart:io';

import 'package:flutter/material.dart'; 
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import '../../models/fenomena_model.dart';
import '../../utils/timezone_helper.dart';
import 'fenomena_service.dart';
import 'location_service.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    // Request runtime notification permission on Android 13+ before initializing plugin
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          await Permission.notification.request();
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Permission request error: $e');
    }

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
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000; 

    const androidDetails = AndroidNotificationDetails(
      'astroedu_channel',
      'AstroEdu Notifications',
      channelDescription: 'Notifikasi fenomena astronomi dan pembelajaran',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF3B82F6), 
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(id, title, body, details);
  }

  Future<void> scheduleDailyReminder({Position? position}) async {
    _setLocalTimezone(_resolveTimezoneName(position));

    String negara = 'Global';
    try {
      final currentPosition = position ?? await LocationService.instance.getCurrentPosition();
      if (currentPosition != null) {
        negara = await LocationService.instance.getCountryName(currentPosition.latitude, currentPosition.longitude);
      }
    } catch (_) {}

    final fenomena = await FenomenaService.instance.getFenomenaHariIni(negara);
    final title = fenomena != null
        ? '🔭 Fenomena Hari Ini: ${fenomena.nama}'
        : '🌟 Waktunya Belajar Astronomi!';
    final body = fenomena != null
        ? 'Jangan lewatkan ${fenomena.nama}. Buka AstroEdu untuk detail waktu pengamatan.'
        : 'Cek fenomena langit malam ini dan baca materi terbaru di AstroEdu';

    const androidDetails = AndroidNotificationDetails(
      'astroedu_daily',
      'AstroEdu Daily',
      channelDescription: 'Pengingat belajar astronomi harian',
      importance: Importance.defaultImportance,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      1,
      title,
      body,
      _nextInstanceOfTime(20, 0),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleAstronomyReminders({Position? position}) async {
    final timezoneName = _resolveTimezoneName(position);
    _setLocalTimezone(timezoneName);

    String? negara;
    try {
      final currentPosition = position ?? await LocationService.instance.getCurrentPosition();
      if (currentPosition != null) {
        negara = await LocationService.instance.getCountryName(currentPosition.latitude, currentPosition.longitude);
      }
    } catch (_) {}

    final allFenomena = await FenomenaService.instance.semuaFenomena;
    final filteredFenomena = negara == null
        ? allFenomena
        : allFenomena.where((fenomena) =>
            fenomena.negara.toLowerCase() == negara!.toLowerCase() || fenomena.negara.toLowerCase() == 'global').toList();

    for (final fenomena in filteredFenomena) {
      final eventUtc = _parseEventDateTimeUtc(fenomena.tanggal, fenomena.waktuTerbaikUtc);
      if (eventUtc == null) continue;

      final eventLocal = tz.TZDateTime.from(eventUtc, tz.local);
      final dayBeforeLocal = eventLocal.subtract(const Duration(days: 1));

      await _scheduleIfFuture(
        _buildReminderId(fenomena, 'day_before'),
        dayBeforeLocal,
        '⏰ Pengingat Fenomena Besok',
        '${fenomena.nama} akan terjadi besok pukul ${_formatTime(eventLocal)} ${_timezoneLabel(timezoneName)}.',
      );

      await _scheduleIfFuture(
        _buildReminderId(fenomena, 'event_time'),
        eventLocal,
        '🔭 Fenomena Sedang Berlangsung',
        '${fenomena.nama} sedang terjadi sekarang. Buka AstroEdu untuk detail pengamatan.',
      );
    }
  }

  Future<void> scheduleEclipseReminder(String eclipseName, DateTime date, {Position? position}) async {
    if (date.isBefore(DateTime.now())) return; 

    _setLocalTimezone(_resolveTimezoneName(position));

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
        date.millisecondsSinceEpoch ~/ 1000, 
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

  Future<void> _scheduleIfFuture(int id, tz.TZDateTime scheduleTime, String title, String body) async {
    final now = tz.TZDateTime.now(tz.local);
    if (!scheduleTime.isAfter(now)) return;

    const androidDetails = AndroidNotificationDetails(
      'astroedu_events',
      'AstroEdu Events',
      channelDescription: 'Pengingat fenomena astronomi',
      importance: Importance.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.cancel(id);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduleTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  tz.TZDateTime? _parseEventDateTimeUtc(String date, String time) {
    final dateParts = date.split('-');
    final timeParts = time.split(':');
    if (dateParts.length != 3 || timeParts.length < 2) return null;

    final year = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final day = int.tryParse(dateParts[2]);
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (year == null || month == null || day == null || hour == null || minute == null) return null;

    return tz.TZDateTime.utc(year, month, day, hour, minute);
  }

  int _buildReminderId(FenomenaModel fenomena, String suffix) {
    final idSource = '${fenomena.nama}|${fenomena.tanggal}|${fenomena.waktuTerbaikUtc}|$suffix';
    return idSource.hashCode & 0x7fffffff;
  }

  String _formatTime(tz.TZDateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _timezoneLabel(String timezoneName) {
    switch (timezoneName) {
      case 'Asia/Jakarta':
        return 'WIB';
      case 'Asia/Makassar':
        return 'WITA';
      case 'Asia/Jayapura':
        return 'WIT';
      case 'Europe/London':
        return 'London';
      case 'America/Bogota':
        return 'Bogota';
      default:
        return 'UTC';
    }
  }

  String _resolveTimezoneName(Position? position) {
    if (position == null) return 'UTC';

    final timezoneCode = TimezoneHelper.getUserTimezone(position.latitude, position.longitude);
    switch (timezoneCode) {
      case 'WIB':
        return 'Asia/Jakarta';
      case 'WITA':
        return 'Asia/Makassar';
      case 'WIT':
        return 'Asia/Jayapura';
      case 'London':
        return 'Europe/London';
      case 'UTC':
        if (position.longitude >= -79.0 && position.longitude <= -66.0) {
          return 'America/Bogota';
        }
        return 'UTC';
      default:
        return 'UTC';
    }
  }

  void _setLocalTimezone(String timezoneName) {
    tz.setLocalLocation(tz.getLocation(timezoneName));
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