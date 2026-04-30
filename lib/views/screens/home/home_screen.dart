// lib/views/screens/home/home_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';  // <-- tambahkan ini
import '../../../services/local/database_helper.dart';
import '../../../services/local/auth_service.dart';
import '../../../services/local/location_service.dart';
import '../../../services/local/notification_service.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../widgets/star_background.dart';
import '../../widgets/common_widgets.dart';
import '../planet/planet_list_screen.dart';
import '../rasi/rasi_list_screen.dart';
import '../gerhana/gerhana_list_screen.dart';
import '../galaksi/galaksi_list_screen.dart';
import '../buy_star/buy_star_screen.dart';
import '../skymap/skymap_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _user;
  String _fact = '';
  Map<String, dynamic>? _constellation;
  Position? _position;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadLocation();
    _scheduleDailyNotif();
  }

  Future<void> _loadData() async {
    final userId = await AuthService.instance.getCurrentUserId();
    if (userId == null) return;
    final user = await DatabaseHelper.instance.getUserById(userId);
    final fact = AppConstants.randomFacts[Random().nextInt(AppConstants.randomFacts.length)];
    if (mounted) setState(() {
      _user = user;
      _fact = fact;
    });
  }

  Future<void> _loadLocation() async {
    final pos = await LocationService.instance.getCurrentPosition();
    if (mounted) {
      setState(() {
        _position = pos;
        _loadingLocation = false;
        if (pos != null) {
          _constellation = LocationService.instance
              .getRecommendedConstellation(pos.latitude, DateTime.now());
        }
      });
    }
  }

  Future<void> _scheduleDailyNotif() async {
    await NotificationService.instance.scheduleDailyReminder();
  }

  void _refreshFact() {
    setState(() => _fact = AppConstants.randomFacts[Random().nextInt(AppConstants.randomFacts.length)]);
  }

  @override
  Widget build(BuildContext context) {
    final name = _user?['name'] ?? 'Penjelajah';
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 11) greeting = 'Selamat Pagi';
    else if (hour < 15) greeting = 'Selamat Siang';
    else if (hour < 18) greeting = 'Selamat Sore';
    else greeting = 'Selamat Malam';

    return Scaffold(
      body: StarBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async { await _loadData(); await _loadLocation(); },
            color: AppTheme.auroraBlue,
            backgroundColor: AppTheme.cardBg,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(name, greeting),
                  const SizedBox(height: 20),
                  _buildHighlightCard(),
                  const SizedBox(height: 20),
                  const SectionTitle(title: '🚀 Jelajahi Materi'),
                  const SizedBox(height: 12),
                  _buildMenuGrid(),
                  const SizedBox(height: 20),
                  _buildBuyStarCard(),
                  const SizedBox(height: 20),
                  _buildFactCard(),
                  const SizedBox(height: 20),
                  _buildLBSCard(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String greeting) {
    return Row(
      children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [AppTheme.auroraBlue, AppTheme.cosmicPurple]),
            border: Border.all(color: AppTheme.auroraBlue, width: 2),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting, $name! 👋',
                  style: const TextStyle(color: AppTheme.starlight, fontSize: 17, fontWeight: FontWeight.w700)),
              const Text('Selamat belajar astronomi 🌌', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppTheme.auroraBlue),
          onPressed: () {
            NotificationService.instance.showInstantNotification('🌟 AstroEdu', 'Jangan lupa belajar astronomi hari ini!');
          },
        ),
      ],
    );
  }

  Widget _buildHighlightCard() {
    return GradientCard(
      colors: const [Color(0xFF1E3A5F), Color(0xFF0D1B3E)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.solarGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.solarGold.withOpacity(0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flash_on, color: AppTheme.solarGold, size: 12),
                    SizedBox(width: 4),
                    Text('Fenomena Hari Ini', style: TextStyle(color: AppTheme.solarGold, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Text('☄️', style: TextStyle(fontSize: 28)),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hujan Meteor Perseid Aktif!', style: TextStyle(color: AppTheme.starlight, fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('Puncak: 11-13 Agustus, hingga 100 meteor/jam', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GerhanaListScreen())),
            child: const Row(
              children: [
                Text('Lihat Detail', style: TextStyle(color: AppTheme.auroraBlue, fontWeight: FontWeight.w600, fontSize: 13)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: AppTheme.auroraBlue, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    final menus = [
      {'label': 'Planet', 'emoji': '🪐', 'colors': [0xFF1E3A5F, 0xFF2563EB], 'screen': const PlanetListScreen()},
      {'label': 'Rasi', 'emoji': '⭐', 'colors': [0xFF3B0764, 0xFF7C3AED], 'screen': const RasiListScreen()},
      {'label': 'Gerhana', 'emoji': '🌑', 'colors': [0xFF1F2937, 0xFF374151], 'screen': const GerhanaListScreen()},
      {'label': 'Galaksi', 'emoji': '🌌', 'colors': [0xFF064E3B, 0xFF10B981], 'screen': const GalaksiListScreen()},
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: menus.map((m) {
        return GradientCard(
          colors: (m['colors'] as List<int>).map((c) => Color(c)).toList(),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => m['screen'] as Widget)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(m['emoji'] as String, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(m['label'] as String, style: const TextStyle(color: AppTheme.starlight, fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBuyStarCard() {
    return GradientCard(
      colors: const [Color(0xFF1C1C4E), Color(0xFF5B21B6)],
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyStarScreen())),
      child: const Row(
        children: [
          Text('⭐', style: TextStyle(fontSize: 36)),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Beli Bintang', style: TextStyle(color: AppTheme.starlight, fontSize: 18, fontWeight: FontWeight.w700)),
                Text('Beri nama bintang favoritmu!\nDengan konversi mata uang real-time', style: TextStyle(color: Color(0xFFC4B5FD), fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        ],
      ),
    );
  }

  Widget _buildFactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.solarGold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              const Expanded(child: Text('Fakta Astronomi', style: TextStyle(color: AppTheme.solarGold, fontSize: 14, fontWeight: FontWeight.w600))),
              GestureDetector(
                onTap: _refreshFact,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.solarGold.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: AppTheme.solarGold, size: 14),
                      SizedBox(width: 4),
                      Text('Refresh', style: TextStyle(color: AppTheme.solarGold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_fact, style: const TextStyle(color: AppTheme.starlight, fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLBSCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.nebulaGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📍', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text('Rekomendasi Berdasarkan Lokasi', style: TextStyle(color: AppTheme.nebulaGreen, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          if (_loadingLocation)
            const Text('Mencari lokasi...', style: TextStyle(color: Color(0xFF9CA3AF)))
          else if (_position == null)
            const Text('Izin lokasi diperlukan untuk rekomendasi rasi bintang', style: TextStyle(color: Color(0xFF9CA3AF)))
          else ...[
            Text(LocationService.instance.getLocationName(_position!.latitude, _position!.longitude), style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
            const SizedBox(height: 8),
            if (_constellation != null)
              Row(
                children: [
                  Text(_constellation!['emoji'], style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_constellation!['name'], style: const TextStyle(color: AppTheme.starlight, fontSize: 16, fontWeight: FontWeight.w700)),
                        Text(_constellation!['desc'], style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SkyMapScreen())),
              child: const Row(
                children: [
                  Text('Lihat di Peta Langit', style: TextStyle(color: AppTheme.nebulaGreen, fontWeight: FontWeight.w600, fontSize: 13)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: AppTheme.nebulaGreen, size: 16),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}