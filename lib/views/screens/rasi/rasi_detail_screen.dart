import 'package:flutter/material.dart';
import '../../../models/rasi_model.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/star_background.dart';
import '../../../controllers/data_controller.dart';
import 'dart:ui';

class RasiDetailScreen extends StatefulWidget {
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
  State<RasiDetailScreen> createState() => _RasiDetailScreenState();
}

class _RasiDetailScreenState extends State<RasiDetailScreen> {
  int _activeTab = 0; // 0 untuk Mitologi, 1 untuk Sains

  @override
  Widget build(BuildContext context) {
    final String assetPath = 'assets/images/rasi/${widget.item.name.toLowerCase().replaceAll(' ', '_')}.jpg';

    return Scaffold(
      backgroundColor: AppTheme.deepSpace,
      body: StarBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Gambar Rasi
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
                  widget.item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: 0.8,
                      child: Image.asset(
                        assetPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Center(child: Text(widget.item.emoji, style: const TextStyle(fontSize: 100))),
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
                    
                    // Tab Selector - Mengikuti gaya Planet
                    _buildTabSelector(),
                    
                    const SizedBox(height: 25),

                    // Konten Deskripsi
                    FutureBuilder<Map<String, dynamic>?>(
                      future: DataController.instance.getWikiData(widget.item.name, category: 'rasi bintang'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildDescriptionLoading();
                        }

                        final String fullDesc = snapshot.data?['extract'] ?? widget.item.description;
                        return _buildAnimatedContent(fullDesc);
                      },
                    ),

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

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _tabItem(0, '🏛️ Mitologi'),
          _tabItem(1, '🔭 Sains'),
        ],
      ),
    );
  }

  Widget _tabItem(int index, String title) {
    bool isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.solarGold.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? AppTheme.solarGold.withOpacity(0.5) : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? AppTheme.solarGold : Colors.white60,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedContent(String content) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey<int>(_activeTab),
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppTheme.cardBg.withOpacity(0.4),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppTheme.solarGold.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.solarGold.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _activeTab == 0 ? Icons.auto_stories : Icons.auto_awesome,
                  color: AppTheme.solarGold,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _activeTab == 0 ? "KISAH MITOLOGI" : "DATA ASTRONOMI",
                  style: const TextStyle(
                    color: AppTheme.solarGold,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(
                color: AppTheme.starlight, 
                fontSize: 15, 
                height: 1.8
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
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withOpacity(0.2),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppTheme.solarGold,
          strokeWidth: 2,
        ),
      ),
    );
  }
}