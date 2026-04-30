// lib/views/screens/skymap/skymap_screen.dart
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadSkyMap();
  }

  Future<void> _loadSkyMap() async {
    final pos = await LocationService.instance.getCurrentPosition();
    if (pos != null) {
      final name = LocationService.instance.getLocationName(pos.latitude, pos.longitude);
      setState(() => _locationName = name);
    } else {
      setState(() => _locationName = 'Lokasi tidak diketahui');
    }

    // Simulasi rasi yang terlihat berdasarkan waktu (gunakan data dari constants)
    final allRasi = AppConstants.rasiList;
    // Untuk demo, tampilkan 5 rasi acak
    allRasi.shuffle();
    _visibleConstellations = allRasi.take(5).toList();

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AstroAppBar(title: '🗺️ Peta Langit'),
      body: StarBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppTheme.auroraBlue),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_locationName, style: const TextStyle(color: AppTheme.starlight))),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SectionTitle(title: '✨ Rasi yang Terlihat Malam Ini'),
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Center(child: CircularProgressIndicator())
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