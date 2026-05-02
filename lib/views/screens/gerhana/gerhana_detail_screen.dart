import 'package:flutter/material.dart';
import '../../../models/gerhana_model.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/star_background.dart';
import '../../../controllers/data_controller.dart'; 
import 'dart:ui';

class GerhanaDetailScreen extends StatelessWidget {
  final GerhanaModel item;
  final String itemId;
  final int userId;

  const GerhanaDetailScreen({
    super.key,
    required this.item,
    required this.itemId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final String assetPath = 'assets/images/gerhana/${item.id.toLowerCase().replaceAll(' ', '_')}.jpg';

    // Logika Normalisasi: Mencari artikel induk di Wikipedia
    // Contoh: "Gerhana Matahari Cincin" akan tetap mencari "Gerhana matahari"
    final String wikiSearchQuery = item.name.toLowerCase().contains('matahari') 
        ? 'Gerhana matahari' 
        : 'Gerhana bulan';

    return Scaffold(
      backgroundColor: AppTheme.deepSpace,
      body: StarBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 380,
              pinned: true,
              stretch: true,
              backgroundColor: AppTheme.deepSpace,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 22,
                    shadows: [Shadow(blurRadius: 20, color: Colors.orangeAccent)],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => 
                          Center(child: Text(item.emoji, style: const TextStyle(fontSize: 120))),
                    ),
                    Center(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(item.color).withOpacity(0.3),
                              blurRadius: 100,
                              spreadRadius: 20,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSafetyBanner(item.safety),
                    
                    const SizedBox(height: 30),
                    _buildStatGrid(),
                    
                    const SizedBox(height: 35),
                    _sectionTitle('📖 Mekanisme Fenomena'),
                    const SizedBox(height: 12),

                    // --- INTEGRASI FUTUREBUILDER DENGAN NORMALISASI QUERY ---
                    FutureBuilder<Map<String, dynamic>?>(
                      future: DataController.instance.getWikiData(wikiSearchQuery, category: 'gerhana'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildDescriptionLoading();
                        }

                        final wikiDescription = snapshot.data?['extract'];
                        
                        // Jika Wikipedia memberikan hasil, kita tampilkan. 
                        // Jika tidak (atau offline), gunakan deskripsi lokal.
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDescriptionCard(wikiDescription ?? item.description),
                            
                            // Jika kita menggunakan data umum dari Wikipedia, 
                            // tambahkan catatan kecil jika item ini adalah tipe spesifik
                            if (wikiDescription != null && item.name.length > wikiSearchQuery.length)
                              Padding(
                                padding: const EdgeInsets.only(top: 12, left: 8),
                                child: Text(
                                  "* Menampilkan informasi umum $wikiSearchQuery.",
                                  style: const TextStyle(color: Colors.white38, fontSize: 10, fontStyle: FontStyle.italic),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    
                    const SizedBox(height: 35),
                    _sectionTitle('🧐 Tahukah Anda?'),
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

  Widget _buildDescriptionLoading() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppTheme.auroraBlue,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildSafetyBanner(String safetyText) {
    bool isSafe = safetyText.toLowerCase().contains('aman');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSafe ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isSafe ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isSafe ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            color: isSafe ? Colors.greenAccent : Colors.orangeAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Panduan Keamanan: $safetyText",
              style: TextStyle(
                color: isSafe ? Colors.greenAccent : Colors.orangeAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _statCard('Durasi Maksimal', item.duration, Icons.timer_outlined),
        _statCard('Frekuensi', item.frequency, Icons.update),
      ],
    );
  }

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
              Icon(icon, color: AppTheme.auroraBlue, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                    Text(value, 
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cardBorder.withOpacity(0.5)),
      ),
      child: Text(
        content,
        style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 15, height: 1.8),
      ),
    );
  }

  Widget _buildFactTile(String fact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔭', style: TextStyle(fontSize: 16)),
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