// lib/views/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import '../../../services/local/auth_service.dart';
import '../../../services/local/database_helper.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/star_background.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _quizScores = [];
  List<Map<String, dynamic>> _boughtStars = [];
  String _saran = '';
  String _kesan = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = await AuthService.instance.getCurrentUserId();
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    final user = await DatabaseHelper.instance.getUserById(userId);
    final scores = await DatabaseHelper.instance.getQuizScores(userId);
    final stars = await DatabaseHelper.instance.getBoughtStars(userId);
    final sk = await DatabaseHelper.instance.getSaranKesan(userId);
    setState(() {
      _user = user;
      _quizScores = scores;
      _boughtStars = stars;
      _saran = sk?['saran'] ?? '';
      _kesan = sk?['kesan'] ?? '';
      _loading = false;
    });
  }

  Future<void> _saveSaranKesan() async {
    final userId = _user?['id'];
    if (userId == null) return;
    await DatabaseHelper.instance.saveSaranKesan(userId, _saran, _kesan);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terima kasih atas masukan Anda!')),
    );
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_user == null) {
      return Scaffold(
        body: StarBackground(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Anda belum login', style: TextStyle(color: AppTheme.starlight)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AstroAppBar(title: '👤 Profil Saya'),
      body: StarBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [AppTheme.auroraBlue, AppTheme.cosmicPurple]),
                    ),
                    child: const Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_user!['name'], style: const TextStyle(color: AppTheme.starlight, fontSize: 20, fontWeight: FontWeight.w700)),
                        Text(_user!['email'], style: const TextStyle(color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SectionTitle(title: '📊 Statistik Belajar'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('Kuis', _quizScores.length),
                    _statItem('Bintang Dibeli', _boughtStars.length),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionTitle(title: '⭐ Bintang yang Dibeli'),
              const SizedBox(height: 8),
              _boughtStars.isEmpty
                  ? const Text('Belum ada bintang yang dibeli', style: TextStyle(color: Color(0xFF9CA3AF)))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _boughtStars.length,
                      itemBuilder: (_, i) {
                        final s = _boughtStars[i];
                        return ListTile(
                          leading: const Icon(Icons.star, color: AppTheme.solarGold),
                          title: Text(s['custom_name'], style: const TextStyle(color: AppTheme.starlight)),
                          subtitle: Text('${s['star_name']} - Rp ${(s['price_idr'] as double).toStringAsFixed(0)}'),
                        );
                      },
                    ),
              const SizedBox(height: 24),
              const SectionTitle(title: '💬 Saran & Kesan'),
              const SizedBox(height: 8),
              TextField(
                onChanged: (v) => _saran = v,
                controller: TextEditingController(text: _saran),
                maxLines: 2,
                style: const TextStyle(color: AppTheme.starlight),
                decoration: const InputDecoration(labelText: 'Saran untuk AstroEdu'),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => _kesan = v,
                controller: TextEditingController(text: _kesan),
                maxLines: 2,
                style: const TextStyle(color: AppTheme.starlight),
                decoration: const InputDecoration(labelText: 'Kesan menggunakan AstroEdu'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveSaranKesan,
                child: const Text('Simpan Saran & Kesan'),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.marsRed),
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: const Text('Logout', style: TextStyle(color: AppTheme.marsRed)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, int value) {
    return Column(
      children: [
        Text(value.toString(), style: const TextStyle(color: AppTheme.auroraBlue, fontSize: 20, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
      ],
    );
  }
}