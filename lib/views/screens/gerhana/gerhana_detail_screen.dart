import 'package:flutter/material.dart';
import '../../../models/gerhana_model.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/star_background.dart';
import '../../../controllers/data_controller.dart';

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
    final String assetPath = 'assets/images/gerhana/${item.name.toLowerCase().replaceAll(' ', '_')}.jpg';
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
                    fontSize: 20,
                    shadows: [Shadow(blurRadius: 20, color: Colors.black)],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(item.emoji, style: const TextStyle(fontSize: 100)),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(item.color).withOpacity(0.2),
                              blurRadius: 100,
                              spreadRadius: 20,
                            ),
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
                    const SizedBox(height: 10),
                    _sectionTitle('🌑 Mekanisme Fenomena'),
                    const SizedBox(height: 15),
                    _buildDescriptionContent(context, wikiSearchQuery),
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
        Container(width: 4, height: 22, color: AppTheme.solarGold),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionContent(BuildContext context, String query) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: DataController.instance.getWikiData(query, category: 'gerhana'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }
        final content = (snapshot.hasData && snapshot.data!['extract'] != null)
            ? snapshot.data!['extract']
            : item.description;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDescriptionCard(content),
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 8),
              child: Text(
                "* Menampilkan informasi umum $query.",
                style: const TextStyle(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        );
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
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}