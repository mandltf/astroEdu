// lib/utils/timezone_helper.dart
import 'package:intl/intl.dart';

class TimezoneHelper {
  /// Mengkonversi waktu UTC ke zona waktu tertentu
  static String convertToTimezone(String utcTime, String targetTimezone) {
    // Format input: "HH:MM" misal "21:00"
    final parts = utcTime.split(':');
    if (parts.length != 2) return utcTime;
    
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    
    // Offset berdasarkan zona waktu
    int offset;
    switch (targetTimezone) {
      case 'WIB': // UTC+7
        offset = 7;
        break;
      case 'WITA': // UTC+8
        offset = 8;
        break;
      case 'WIT': // UTC+9
        offset = 9;
        break;
      case 'London': // UTC+1 (BST) atau UTC+0 (GMT) - sederhanakan UTC+1
        offset = 1;
        break;
      default:
        offset = 0;
    }
    
    int newHour = (hour + offset) % 24;
    return '${newHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
  
  /// Mendapatkan waktu sekarang dalam zona waktu tertentu
  static String getCurrentTimeInZone(String timezone) {
    final now = DateTime.now().toUtc();
    int offset;
    switch (timezone) {
      case 'WIB': offset = 7; break;
      case 'WITA': offset = 8; break;
      case 'WIT': offset = 9; break;
      case 'London': offset = 1; break;
      default: offset = 0;
    }
    final localTime = now.add(Duration(hours: offset));
    return DateFormat('HH:mm').format(localTime);
  }
  
  /// Mendapatkan nama zona waktu berdasarkan lokasi (sederhana)
  static String getUserTimezone(double latitude, double longitude) {
    // Indonesia
    if (longitude >= 95 && longitude < 120) return 'WIB';
    if (longitude >= 120 && longitude < 135) return 'WITA';
    if (longitude >= 135 && longitude <= 141) return 'WIT';
    return 'UTC';
  }
}