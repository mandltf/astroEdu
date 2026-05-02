import 'package:flutter/material.dart';
import '../../../models/rasi_model.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/star_background.dart';
import '../../../controllers/data_controller.dart'; // Import DataController
import 'dart:ui';

class RasiDetailScreen extends StatelessWidget {
  final RasiModel item;
  final String itemId;
  final int userId;

  const RasiDetailScreen({
    super.key,
    required this.item,
    required this.itemId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    // Path asset: rasi bintang biasanya bagus dalam bentuk outline/vector
    final String assetPath = 'assets/images/rasi/${item.name.toLowerCase().replaceAll(' ', '_')}.jpg';

    return Scaffold(
      backgroundColor: AppTheme.deepSpace,
      body: StarBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 350,
              pinned: true,
              stretch: true,
              backgroundColor: AppTheme.deepSpace,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                    fontSize: 20,
                  ),
                ),
                centerTitle: true,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gambar Rasi Bintang
                    Opacity(
                      opacity: 0.8,
                      child: Image.asset(
                        assetPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => 
                          Center(child: Text(item.emoji, style: const TextStyle(fontSize: 100))),
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
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
                    _buildSeasonTag(item.season),
                    const SizedBox(height: 25),
                    
                    _buildObservationGrid(),
                    
                    const SizedBox(height: 35),
                    _sectionTitle('🌌 Mitologi & Sains'),
                    const SizedBox(height: 12),

                    // --- INTEGRASI FUTUREBUILDER WIKIPEDIA ---
                    FutureBuilder<Map<String, dynamic>?>(
                      // Menggunakan kategori 'rasi bintang' untuk fallback pencarian
                      future: DataController.instance.getWikiData(item.name, category: 'rasi bintang'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildDescriptionLoading();
                        }

                        // Gunakan hasil extract Wikipedia, jika gagal gunakan description lokal
                        final wikiDescription = snapshot.data?['extract'];
                        return _buildDescriptionCard(wikiDescription ?? item.description);
                      },
                    ),
                    // ------------------------------------------
                    
                    const SizedBox(height: 35),
                    _sectionTitle('✨ Rahasia Langit'),
                    const SizedBox(height: 12),
                    ...item.facts.map((fact) => _buildFactTile(fact)).toList(),
                    
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

  // Widget Loading Indicator untuk area deskripsi
  Widget _buildDescriptionLoading() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withOpacity(0.2),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppTheme.auroraBlue,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildSeasonTag(String season) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white24),
          color: Colors.white.withOpacity(0.05),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, color: AppTheme.starlight, size: 14),
            const SizedBox(width: 10),
            Text(
              "TERLIHAT PADA: ${season.toUpperCase()}",
              style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationGrid() {
    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _statCard('Bintang Utama', item.brightestStar, Icons.auto_awesome),
        _statCard('Jumlah Bintang', '${item.stars} Bintang', Icons.grain),
        _statCard('Waktu Terbaik', item.bestTime, Icons.schedule),
        _statCard('Visibilitas', item.visibility, Icons.visibility),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.auroraBlue, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
                    Text(value, 
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
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
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDescriptionCard(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withOpacity(0.4),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.cardBorder.withOpacity(0.3)),
      ),
      child: Text(
        content,
        style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 15, height: 1.8),
      ),
    );
  }

  Widget _buildFactTile(String fact) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white.withOpacity(0.02),
          child: Row(
            children: [
              const Icon(Icons.auto_fix_high, color: AppTheme.starlight, size: 16),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  fact,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}