// lib/views/screens/planet/planet_detail_screen.dart
import 'package:flutter/material.dart';
import '../../../models/planet_model.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/star_background.dart';

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
    final extract = planet.wikiData?['extract'] ?? planet.description;
    return Scaffold(
      body: StarBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppTheme.deepSpace,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(planet.name),
                background: Center(child: Text(planet.emoji, style: const TextStyle(fontSize: 90))),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppTheme.starlight),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _infoCard('📝 Tentang ${planet.name}', extract),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.auroraBlue, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14, height: 1.6)),
        ],
      ),
    );
  }
}