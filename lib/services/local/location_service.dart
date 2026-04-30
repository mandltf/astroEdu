// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService instance = LocationService._();
  LocationService._();

  Position? _lastPosition;

  Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      _lastPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      return _lastPosition;
    } catch (_) {
      return null;
    }
  }

  // Get recommended constellation based on location and time
  Map<String, dynamic> getRecommendedConstellation(double latitude, DateTime now) {
    final month = now.month;
    final isNorthernHemisphere = latitude > 0;

    if (isNorthernHemisphere) {
      switch (month) {
        case 12: case 1: case 2:
          return {'name': 'Orion', 'desc': 'Terlihat jelas di langit selatan malam ini', 'emoji': '⭐'};
        case 3: case 4: case 5:
          return {'name': 'Leo', 'desc': 'Terlihat tinggi di langit selatan', 'emoji': '🦁'};
        case 6: case 7: case 8:
          return {'name': 'Scorpius', 'desc': 'Terlihat rendah di langit selatan', 'emoji': '🦂'};
        default:
          return {'name': 'Ursa Major', 'desc': 'Terlihat di langit utara', 'emoji': '🐻'};
      }
    } else {
      // Southern hemisphere (including Indonesia)
      switch (month) {
        case 4: case 5: case 6:
          return {'name': 'Crux (Salib Selatan)', 'desc': 'Terlihat jelas malam ini dari lokasi kamu!', 'emoji': '✝️'};
        case 7: case 8: case 9:
          return {'name': 'Scorpius', 'desc': 'Terlihat sangat jelas dari Indonesia malam ini', 'emoji': '🦂'};
        case 11: case 12: case 1:
          return {'name': 'Orion', 'desc': 'Terlihat jelas di langit utara malam ini', 'emoji': '⭐'};
        default:
          return {'name': 'Canis Major', 'desc': 'Terlihat di langit, cari bintang Sirius yang terang', 'emoji': '🐕'};
      }
    }
  }

  String getLocationName(double lat, double lng) {
    // Simple approximation for Indonesian cities
    if (lat >= -8.5 && lat <= -6.0 && lng >= 106.0 && lng <= 107.5) return 'Jakarta & sekitarnya';
    if (lat >= -8.0 && lat <= -6.8 && lng >= 107.0 && lng <= 108.8) return 'Bandung & sekitarnya';
    if (lat >= -8.5 && lat <= -6.7 && lng >= 110.0 && lng <= 111.5) return 'Yogyakarta & sekitarnya';
    if (lat >= -7.5 && lat <= -6.7 && lng >= 112.0 && lng <= 113.0) return 'Surabaya & sekitarnya';
    if (lat >= -9.0 && lat <= -8.0 && lng >= 115.0 && lng <= 115.8) return 'Bali';
    return 'Lokasi kamu (${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)})';
  }
}