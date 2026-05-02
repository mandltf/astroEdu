import 'package:flutter/material.dart';
import '../../../models/galaksi_model.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/star_background.dart';
import '../../../controllers/data_controller.dart';
import 'dart:ui'; 

class GalaksiDetailScreen extends StatelessWidget {
  final GalaksiModel item;
  final String itemId;
  final int userId;

  const GalaksiDetailScreen({
    super.key,
    required this.item,
    required this.itemId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    // Mengambil data deskripsi dari wikiData (hasil fetch) atau fallback ke description model
    final extract = item.wikiData?['extract'] ?? item.description;
    
    // Path asset diasumsikan: assets/images/galaksi/nama_galaksi.jpg
    // Kamu bisa menyesuaikan penamaan file-nya di sini
    final String assetPath = 'assets/images/galaksi/${item.name.toLowerCase().replaceAll(' ', '_')}.jpg';

    return Scaffold(
      backgroundColor: AppTheme.deepSpace,
      body: StarBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // AppBar dengan Hero Image dari Assets
            SliverAppBar(
              expandedHeight: 380,
              pinned: true,
              stretch: true,
              backgroundColor: AppTheme.deepSpace,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.3),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                title: Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 1.5,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 12, color: Colors.black)],
                  ),
                ),
                centerTitle: true,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Menampilkan gambar dari Assets
                    Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      // Jika gambar tidak ditemukan di assets, tampilkan fallback (Emoji/Placeholder)
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Color(item.color).withOpacity(0.5),
                                AppTheme.deepSpace,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(item.emoji, style: const TextStyle(fontSize: 100)),
                          ),
                        );
                      },
                    ),
                    // Gradient Bottom Overlay
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.6, 1.0],
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
                    const SizedBox(height: 15),
                    Center(child: _buildTypeTag(item.type)),
                    const SizedBox(height: 30),
                    
                    // Grid Statistik Angka (Massa, Diameter, Bintang, dll)
                    _buildStatGrid(),
                    
                    const SizedBox(height: 35),
                   

                    _sectionTitle(' Deskripsi Ilmiah'),
                    const SizedBox(height: 12),

                    // Gunakan FutureBuilder untuk mengambil data dari DataController
                    FutureBuilder<Map<String, dynamic>?>(
                      future: DataController.instance.getWikiData(item.name, category: 'galaksi'),
                      builder: (context, snapshot) {
                        // 1. Jika data masih dalam proses loading
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildDescriptionCard("Sedang menyinkronkan dengan data Wikipedia...");
                        }
                        
                        // 2. Jika terjadi error atau data tidak ditemukan
                        if (snapshot.hasError || snapshot.data == null) {
                          return _buildDescriptionCard(item.description); // Gunakan deskripsi lokal sebagai cadangan
                        }

                        // 3. Jika data berhasil didapat
                        final wikiExtract = snapshot.data!['extract'];
                        return _buildDescriptionCard(wikiExtract ?? item.description);
                      },
                    ),

                    const SizedBox(height: 12),
                    _buildDescriptionCard(extract),
                    
                    const SizedBox(height: 35),
                    _sectionTitle(' Fakta Galaksi'),
                    const SizedBox(height: 12),
                    // List Fakta
                    ...item.facts.map((fact) => _buildFactTile(fact)).toList(),
                    
                    const SizedBox(height: 100), // Spacing bawah agar tidak mepet
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Tag Tipe Galaksi (Spiral, Elips, dll)
  Widget _buildTypeTag(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.auroraBlue.withOpacity(0.3), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.auroraBlue.withOpacity(0.5)),
      ),
      child: Text(
        type.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.auroraBlue, 
          fontSize: 11, 
          fontWeight: FontWeight.bold, 
          letterSpacing: 2
        ),
      ),
    );
  }

  // Grid Info Angka
  Widget _buildStatGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.4,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            _statCard('Massa Estimasi', item.mass ?? '1.5 × 10¹² M☉', Icons.auto_awesome_motion),
            _statCard('Diameter', item.diameter, Icons.straighten),
            _statCard('Populasi Bintang', item.stars, Icons.brightness_high),
            _statCard('Periode Rotasi', item.rotationPeriod ?? '240 Myr', Icons.sync),
          ],
        );
      },
    );
  }

  // Card Statistik individual dengan efek Blur
  Widget _statCard(String label, String value, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.solarGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.solarGold, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(value, 
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 12, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5
                      ),
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
        Container(width: 4, height: 20, color: AppTheme.auroraBlue),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cardBorder.withOpacity(0.5)),
      ),
      child: Text(
        content,
        style: TextStyle(
          color: Colors.white.withOpacity(0.85), 
          fontSize: 15, 
          height: 1.8,
          letterSpacing: 0.3
        ),
      ),
    );
  }

  Widget _buildFactTile(String fact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.stars, color: AppTheme.auroraBlue, size: 20),
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