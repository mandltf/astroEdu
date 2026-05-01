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

  String getLocationName(double lat, double lng) {
    // Simple approximation for Indonesian cities
    if (lat >= -8.5 && lat <= -6.0 && lng >= 106.0 && lng <= 107.5) return 'Jakarta';
    if (lat >= -8.0 && lat <= -6.8 && lng >= 107.0 && lng <= 108.8) return 'Bandung';
    if (lat >= -8.5 && lat <= -6.7 && lng >= 110.0 && lng <= 111.5) return 'Yogyakarta';
    if (lat >= -7.5 && lat <= -6.7 && lng >= 112.0 && lng <= 113.0) return 'Surabaya';
    if (lat >= -9.0 && lat <= -8.0 && lng >= 115.0 && lng <= 115.8) return 'Bali';
    return 'Lokasi kamu (${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)})';
  }
}