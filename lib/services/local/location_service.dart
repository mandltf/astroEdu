import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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

      // Coba pakai last known position dulu (instan)
      _lastPosition = await Geolocator.getLastKnownPosition();
      if (_lastPosition != null) return _lastPosition;

      // Fallback ke current position dengan akurasi rendah (lebih cepat)
      _lastPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        throw Exception('Location timeout');
      });
      return _lastPosition;
    } catch (_) {
      return _lastPosition; // return last known jika gagal
    }
  }


  Future<String> getLocationNameAsync(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return place.locality ?? place.subAdministrativeArea ?? 'Lokasi Kamu';
      }
    } catch (_) {}
    return getLocationName(lat, lng); // fallback
  }

  Future<String> getCountryName(double lat, double lng) async {
    // Cek bounding-box dulu (instan, tanpa internet)
    if (lat >= -11.0 && lat <= 6.0 && lng >= 95.0 && lng <= 141.0) {
      return 'Indonesia';
    }
    if (lat >= -4.2 && lat <= 12.5 && lng >= -79.0 && lng <= -66.8) {
      return 'Colombia';
    }
    // Fallback geocoding jika di luar bounding box yang dikenal
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 3));
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return place.country ?? 'Global';
      }
    } catch (_) {}
    return 'Global';
  }

  String getLocationName(double lat, double lng) {
    if (lat >= -8.5 && lat <= -6.0 && lng >= 106.0 && lng <= 107.5) return 'Jakarta';
    if (lat >= -8.0 && lat <= -6.8 && lng >= 107.0 && lng <= 108.8) return 'Bandung';
    if (lat >= -8.5 && lat <= -6.7 && lng >= 110.0 && lng <= 111.5) return 'Yogyakarta';
    if (lat >= -7.5 && lat <= -6.7 && lng >= 112.0 && lng <= 113.0) return 'Surabaya';
    if (lat >= -9.0 && lat <= -8.0 && lng >= 115.0 && lng <= 115.8) return 'Bali';
    return 'Lokasi kamu (${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)})';
  }
}