// lib/views/screens/home/home_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../../../models/fenomena_model.dart';
import '../../../services/local/database_helper.dart';
import '../../../services/local/auth_service.dart';
import '../../../services/local/location_service.dart';
import '../../../services/local/notification_service.dart';
import '../../../services/local/fenomena_service.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../widgets/star_background.dart';
import '../../widgets/common_widgets.dart';
import '../planet/planet_list_screen.dart';
import '../rasi/rasi_list_screen.dart';
import '../gerhana/gerhana_list_screen.dart';
import '../galaksi/galaksi_list_screen.dart';
import '../buy_star/buy_star_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _user;
  String _fact = '';
  FenomenaModel? _fenomenaHariIni;
  bool _loadingFenomena = true;
  Position? _position;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadLocation();
    _loadFenomenaHariIni();
    _scheduleDailyNotif();
    _refreshFact();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = await AuthService.instance.getCurrentUserId();
    if (userId == null) return;
    final user = await DatabaseHelper.instance.getUserById(userId);
    if (mounted) setState(() {_user = user;});
  }

  Future<void> _loadLocation() async {
    try {
      final pos = await LocationService.instance.getCurrentPosition();
      if (mounted) {
        setState(() {
          _position = pos;
          _loadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _position = null;
          _loadingLocation = false;
        });
      }
    }
  }

  Future<void> _loadFenomenaHariIni() async {
    setState(() => _loadingFenomena = true);
    await Future.delayed(const Duration(milliseconds: 200));
    final fenomena = FenomenaService.instance.getFenomenaHariIni();
    if (mounted) {
      setState(() {
        _fenomenaHariIni = fenomena;
        _loadingFenomena = false;
      });
    }
  }

  Future<void> _scheduleDailyNotif() async {
    await NotificationService.instance.scheduleDailyReminder();
  }

  void _refreshFact() {
    setState(() {
      _fact = AppConstants.randomFacts[Random().nextInt(AppConstants.randomFacts.length)];
    });
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      await _loadLocation();
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin lokasi diperlukan untuk fitur ini'), backgroundColor: AppTheme.marsRed),
          );
        }
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin lokasi ditolak permanen, silakan aktifkan di pengaturan'), backgroundColor: AppTheme.marsRed),
        );
      }
      return;
    }
    await _loadLocation();
  }

  void _showDetailFenomenaDialog() {
    if (_fenomenaHariIni == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('☄️', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _fenomenaHariIni!.nama,
                style: const TextStyle(color: AppTheme.starlight, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_fenomenaHariIni!.deskripsiLengkap, style: const TextStyle(color: Color(0xFFD1D5DB), height: 1.5)),
              const SizedBox(height: 16),
              const Text('🌟 Poin Penting:', style: TextStyle(color: AppTheme.solarGold, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ..._fenomenaHariIni!.poinPelajaran.map(
                (poin) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: AppTheme.auroraBlue)),
                      Expanded(child: Text(poin, style: const TextStyle(color: Color(0xFF9CA3AF)))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Sumber: ${_fenomenaHariIni!.sumber}', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: AppTheme.auroraBlue)),
          ),
        ],
      ),
    );
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
            onRefresh: () async {
              await _loadData();
              await _loadLocation();
              await _loadFenomenaHariIni();
            },
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
                  _buildFenomenaCard(),
                  const SizedBox(height: 20),
                  const SectionTitle(title: ' Jelajahi Materi'),
                  const SizedBox(height: 12),
                  _buildMenuGrid(),
                  const SizedBox(height: 20),
                  _buildFactCard(),
                  const SizedBox(height: 20),
                  _buildBuyStarCard(),
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
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [AppTheme.auroraBlue, AppTheme.cosmicPurple]),
              border: Border.all(color: AppTheme.auroraBlue, width: 2),
            ),
            child: ClipOval(
              child: _user?['photo_path'] != null && File(_user!['photo_path']).existsSync()
                  ? Image.file(File(_user!['photo_path']), fit: BoxFit.cover, width: 50, height: 50)
                  : const Icon(Icons.person, color: Colors.white, size: 28),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting, $name!',
                  style: const TextStyle(color: AppTheme.starlight, fontSize: 17, fontWeight: FontWeight.w700)),
              const Text('Mari pelajari rahasia tata surya bersama',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
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

  // Card Fenomena Hari Ini (tinggi diperkecil, lokasi bisa ditekan)
  Widget _buildFenomenaCard() {
    if (_loadingFenomena) {
      return const Center(child: CircularProgressIndicator());
    }
    final fenomena = _fenomenaHariIni;
    if (fenomena == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: const Text('Tidak ada fenomena astronomi signifikan hari ini.\nTetap pelajari materi lainnya!',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
      );
    }

    // Tentukan teks lokasi
    String locationText = '';
    if (_position != null) {
      locationText = LocationService.instance.getLocationName(_position!.latitude, _position!.longitude);
    } else if (_loadingLocation) {
      locationText = 'Mencari lokasi...';
    } else {
      locationText = 'Aktifkan lokasi';
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D1B4E), Color(0xFF1A2A4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.solarGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.solarGold.withOpacity(0.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flash_on, color: AppTheme.solarGold, size: 10),
                        SizedBox(width: 2),
                        Text('Fenomena Hari Ini',
                            style: TextStyle(color: AppTheme.solarGold, fontSize: 9, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _requestLocationPermission,
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 10, color: AppTheme.nebulaGreen),
                        const SizedBox(width: 2),
                        Text(
                          locationText.length > 20 ? '${locationText.substring(0, 18)}...' : locationText,
                          style: const TextStyle(color: AppTheme.nebulaGreen, fontSize: 8, decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Text('☄️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fenomena.nama,
                          style: const TextStyle(color: AppTheme.starlight, fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          fenomena.deskripsiSingkat,
                          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showDetailFenomenaDialog,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 24)),
                  child: const Text('Pelajari Lebih Lanjut →', style: TextStyle(color: AppTheme.auroraBlue, fontSize: 10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    final menus = [
      {'label': 'Planet', 'image': 'assets/images/planet.png', 'color': const Color(0xFF2563EB)},
      {'label': 'Rasi', 'image': 'assets/images/bintang.png', 'color': const Color(0xFF7C3AED)},
      {'label': 'Gerhana', 'image': 'assets/images/gerhana.png', 'color': const Color(0xFF6B7280)},
      {'label': 'Galaksi', 'image': 'assets/images/galaksi.png', 'color': const Color(0xFF10B981)},
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: menus.map((m) {
        final color = m['color'] as Color;
        return GestureDetector(
          onTap: () {
            switch (m['label']) {
              case 'Planet':
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PlanetListScreen()));
                break;
              case 'Rasi':
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RasiListScreen()));
                break;
              case 'Gerhana':
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GerhanaListScreen()));
                break;
              case 'Galaksi':
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GalaksiListScreen()));
                break;
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.7), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    m['image'] as String,
                    width: 36,
                    height: 36,
                    color: Colors.white, // agar gambar menjadi putih (opsional)
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppTheme.solarGold, width: 2)),
                    ),
                    child: Text(
                      m['label'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFactCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF0D1B3E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                        Icon(Icons.auto_awesome, color: AppTheme.solarGold, size: 12),
                        SizedBox(width: 4),
                        Text('Fakta Astronomi',
                            style: TextStyle(color: AppTheme.solarGold, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _refreshFact,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.solarGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, color: AppTheme.solarGold, size: 14),
                          SizedBox(width: 4),
                          Text('Fakta Lainnya', style: TextStyle(color: AppTheme.solarGold, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.cosmicPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text('💡', style: TextStyle(fontSize: 28))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tahukah Kamu?',
                            style: TextStyle(color: AppTheme.starlight, fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(_fact,
                            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 12, color: AppTheme.auroraBlue),
                  const SizedBox(width: 4),
                  const Text('Sumber: Astronomi & NASA', style: TextStyle(color: AppTheme.auroraBlue, fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ),
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
                Text('Beri nama bintang favoritmu!\nDengan konversi mata uang real-time',
                    style: TextStyle(color: Color(0xFFC4B5FD), fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        ],
      ),
    );
  }
}