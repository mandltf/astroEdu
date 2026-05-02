import 'package:flutter/material.dart';
import '../../../models/galaksi_model.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/star_background.dart';
import '../../../controllers/data_controller.dart';

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
    final String assetPath = 'assets/images/galaksi/${item.name.toLowerCase().replaceAll(' ', '_')}.jpg';

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
                    fontSize: 20,
                    letterSpacing: 1.5,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 12, color: Colors.black)],
                  ),
                ),
                centerTitle: true,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [Color(item.color).withOpacity(0.5), AppTheme.deepSpace],
                          ),
                        ),
                        child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 100))),
                      ),
                    ),
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
                    const SizedBox(height: 30),
                    _sectionTitle('🌌 Deskripsi Ilmiah'),
                    const SizedBox(height: 15),
                    _buildDescriptionContent(context),
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

  Widget _buildDescriptionContent(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: () async {
        var data = await DataController.instance.getWikiData(item.name, category: 'galaksi');
        if (data == null || data['extract'] == null) {
          data = await DataController.instance.getWikiData("Galaksi ${item.name}", category: 'galaksi');
        }
        if (data == null && item.name.toLowerCase().contains("magellan")) {
          data = await DataController.instance.getWikiData("Awan Magellan Besar", category: 'galaksi');
        }
        return data;
      }(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }
        final content = snapshot.data?['extract'] ?? item.description;
        return _buildDescriptionCard(content);
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.solarGold.withOpacity(0.3)),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppTheme.solarGold, strokeWidth: 2),
      ),
    );
  }

  Widget _buildDescriptionCard(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.solarGold.withOpacity(0.5)),
      ),
      child: Text(
        content,
        style: TextStyle(
          color: Colors.white.withOpacity(0.85),
          fontSize: 15,
          height: 1.8,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}