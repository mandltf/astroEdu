import 'package:flutter/material.dart';
import '../../../models/planet_model.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/star_background.dart';
import '../../../controllers/data_controller.dart'; // Import Controller baru
import 'dart:ui';

class PlanetDetailScreen extends StatelessWidget {
  final PlanetModel planet;
  final String itemId;
  final int userId;

  const PlanetDetailScreen({
    super.key,
    required this.planet,
    required this.itemId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    // Path asset tetap otomatis
    final String assetPath = 'assets/images/planets/${planet.name.toLowerCase().replaceAll(' ', '_')}.jpg';

    return Scaffold(
      backgroundColor: AppTheme.deepSpace,
      body: StarBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // AppBar Imersif
            SliverAppBar(
              expandedHeight: 380,
              pinned: true,
              stretch: true,
              backgroundColor: AppTheme.deepSpace,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                title: Text(
                  planet.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 2,
                    shadows: [Shadow(blurRadius: 15, color: Colors.black)],
                  ),
                ),
                centerTitle: true,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(planet.emoji, style: const TextStyle(fontSize: 120)),
                        );
                      },
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.7, 1.0],
                          colors: [Colors.transparent, AppTheme.deepSpace],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildStatGrid(),
                    
                    const SizedBox(height: 35),
                    _sectionTitle(' Karakteristik'),
                    const SizedBox(height: 12),

                    // --- BAGIAN PERBAIKAN WIKIPEDIA ---
                    FutureBuilder<Map<String, dynamic>?>(
                      // Kita berikan kategori 'planet' untuk membantu pencarian fallback
                      future: DataController.instance.getWikiData(planet.name, category: 'planet'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildDescriptionLoading();
                        }
                        
                        // Ambil ekstrak dari wiki, jika gagal pakai deskripsi lokal
                        final wikiDescription = snapshot.data?['extract'];
                        return _buildDescriptionCard(wikiDescription ?? planet.description);
                      },
                    ),
                    // ----------------------------------
                    
                    const SizedBox(height: 35),
                    _sectionTitle(' Fakta Unik'),
                    const SizedBox(height: 12),
                    ...planet.facts.map((fact) => _buildFactTile(fact)).toList(),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Loading agar tidak patah saat transisi data
  Widget _buildDescriptionLoading() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppTheme.solarGold, strokeWidth: 2),
      ),
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _statCard('Jarak ke Matahari', planet.distance, Icons.wb_sunny_outlined),
        _statCard('Diameter', planet.diameter, Icons.straighten),
        _statCard('Jumlah Bulan', '${planet.moons} Satelit', Icons.nights_stay_outlined),
        _statCard('Gravitasi', planet.gravity ?? '9.81 m/s²', Icons.south_outlined),
        _statCard('Massa', planet.mass ?? 'Unknown', Icons.monitor_weight_outlined),
        _statCard('Suhu Rata-rata', planet.temperature ?? 'N/A', Icons.thermostat_outlined),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.solarGold, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
                    Text(value, 
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, color: AppTheme.solarGold),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cardBorder.withOpacity(0.4)),
      ),
      child: Text(
        content,
        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15, height: 1.8),
      ),
    );
  }

  Widget _buildFactTile(String fact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.rocket_launch, color: AppTheme.solarGold, size: 18),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              fact,
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}