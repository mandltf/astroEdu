import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../services/local/location_service.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../widgets/star_background.dart';
import '../../widgets/common_widgets.dart';

class SkyMapScreen extends StatefulWidget {
  const SkyMapScreen({super.key});

  @override
  State<SkyMapScreen> createState() => _SkyMapScreenState();
}

class _SkyMapScreenState extends State<SkyMapScreen> {
  String _locationName = 'Memuat lokasi...';
  List<Map<String, dynamic>> _visibleConstellations = [];
  bool _loading = true;
  bool _permissionDenied = false; // tambahan

  @override
  void initState() {
    super.initState();
    _loadSkyMap();
  }

  Future<void> _loadSkyMap() async {
    setState(() {
      _loading = true;
      _permissionDenied = false;
    });

    // Cek izin lokasi
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationName = 'Izin lokasi diperlukan';
          _permissionDenied = true;
          _loading = false;
        });
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationName = 'Izin lokasi ditolak permanen';
        _permissionDenied = true;
        _loading = false;
      });
      return;
    }

    // Izin diberikan, coba dapatkan posisi
    final pos = await LocationService.instance.getCurrentPosition();
    if (pos != null) {
      final name = LocationService.instance.getLocationName(pos.latitude, pos.longitude);
      setState(() => _locationName = name);
    } else {
      setState(() => _locationName = 'Lokasi tidak diketahui');
    }

    // Tampilkan rasi bintang acak (tetap)
    final allRasi = AppConstants.rasiList;
    allRasi.shuffle();
    _visibleConstellations = allRasi.take(5).toList();

    setState(() => _loading = false);
  }

  Future<void> _requestLocationPermission() async {
    // Jika izin ditolak, minta ulang atau buka pengaturan
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin lokasi diperlukan untuk fitur ini'), backgroundColor: AppTheme.marsRed),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Arahkan ke pengaturan aplikasi
      await Geolocator.openAppSettings();
      return;
    }
    // Izin diberikan, reload
    await _loadSkyMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AstroAppBar(title: ' Peta Langit'),
      body: StarBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card lokasi bisa ditekan untuk meminta izin
            GestureDetector(
              onTap: () {
                if (_permissionDenied || !_loading && (_locationName.contains('Izin') || _locationName.contains('tidak diketahui'))) {
                  _requestLocationPermission();
                }
              },
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on,
                        color: _permissionDenied ? AppTheme.marsRed : AppTheme.auroraBlue),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_locationName, style: const TextStyle(color: AppTheme.starlight))),
                    if (_permissionDenied)
                      const Icon(Icons.warning_amber_rounded, color: AppTheme.marsRed, size: 18),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SectionTitle(title: '✨ Rasi yang Terlihat Malam Ini'),
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_permissionDenied)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_off, size: 64, color: Color(0xFF9CA3AF)),
                      const SizedBox(height: 16),
                      const Text('Izin lokasi diperlukan untuk melihat rekomendasi rasi bintang\nberdasarkan lokasi Anda',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF9CA3AF))),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _requestLocationPermission,
                        child: const Text('Berikan Izin Lokasi'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _visibleConstellations.length,
                  itemBuilder: (_, i) {
                    final r = _visibleConstellations[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Text(r['emoji'], style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r['name'], style: const TextStyle(color: AppTheme.starlight, fontWeight: FontWeight.w700)),
                                Text('Lihat di langit malam', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.star, color: AppTheme.auroraBlue),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}