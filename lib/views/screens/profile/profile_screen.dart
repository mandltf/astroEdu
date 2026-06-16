import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import '../../../services/local/auth_service.dart';
import '../../../services/local/database_helper.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/star_background.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _quizScores = [];
  int _totalAttempts = 0;
  int _uniqueQuizzes = 0;
  double _averageScore = 0.0;
  String _saran = '';
  String _kesan = '';
  bool _loading = true;
  bool _biometricEnabled = false;
  bool _deviceSupportsBiometric = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload profile setiap kali app kembali ke foreground (dari quiz, screen lain, dll)
      loadProfile();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final userId = await AuthService.instance.getCurrentUserId();
    if (userId == null) {
      setState(() {
        _loading = false;
        _user = null;
      });
      return;
    }
    final user = await DatabaseHelper.instance.getUserById(userId);
    final scores = await DatabaseHelper.instance.getQuizScores(userId);
    
    int attempts = scores.length;
    Map<String, Map<String, dynamic>> latestScoresMap = {};
    for (var score in scores) {
      String cat = score['category'];
      if (!latestScoresMap.containsKey(cat)) {
        latestScoresMap[cat] = score;
      }
    }
    
    int uniqueQuizzes = latestScoresMap.length;
    double avgScore = 0.0;
    if (uniqueQuizzes > 0) {
      double totalPercent = 0.0;
      for (var score in latestScoresMap.values) {
        int correct = score['score'];
        int total = score['total'];
        if (total > 0) {
          totalPercent += (correct / total) * 100;
        }
      }
      avgScore = totalPercent / uniqueQuizzes;
    }

    final sk = await DatabaseHelper.instance.getSaranKesan(userId);

    final available = await AuthService.instance.isBiometricAvailable();
    bool enabled = false;
    if (available) {
      enabled = await AuthService.instance.isBiometricEnabledForUser(userId);
    }

    setState(() {
      _user = user;
      _quizScores = scores;
      _totalAttempts = attempts;
      _uniqueQuizzes = uniqueQuizzes;
      _averageScore = avgScore;
      _saran = sk?['saran'] ?? '';
      _kesan = sk?['kesan'] ?? '';
      _deviceSupportsBiometric = available;
      _biometricEnabled = enabled;
      _loading = false;
    });
  }

  Future<void> _updateUserField(String field, String newValue) async {
    final userId = _user?['id'];
    if (userId == null) return;
    await DatabaseHelper.instance.updateUser(userId, {field: newValue});
    await loadProfile();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$field berhasil diubah'), backgroundColor: AppTheme.nebulaGreen),
      );
    }
  }

  Future<void> _editPhoto() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final userId = _user!['id'];
      await DatabaseHelper.instance.updateUser(userId, {'photo_path': pickedFile.path});
      await loadProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil diperbarui'), backgroundColor: AppTheme.nebulaGreen),
      );
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final LocalAuthentication localAuth = LocalAuthentication();
      try {
        final authenticated = await localAuth.authenticate(
          localizedReason: 'Verifikasi identitas untuk mengaktifkan biometrik',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );
        if (!authenticated) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Autentikasi gagal'), backgroundColor: AppTheme.marsRed),
            );
          }
          return;
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Terjadi kesalahan biometrik'), backgroundColor: AppTheme.marsRed),
          );
        }
        return;
      }
    }
    
    final userId = _user?['id'];
    if (userId != null) {
      await AuthService.instance.setBiometricEnabledForUser(userId, value);
      setState(() {
        _biometricEnabled = value;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value ? 'Biometrik diaktifkan' : 'Biometrik dinonaktifkan'), 
            backgroundColor: AppTheme.nebulaGreen
          ),
        );
      }
    }
  }

  Future<void> _showSaranDialog() async {
    TextEditingController controller = TextEditingController(text: _saran);
    bool isEditing = _saran.isEmpty;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.nebulaGreen.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.nebulaGreen.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.feedback_outlined, color: AppTheme.nebulaGreen, size: 28),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Saran untuk mk TPM', style: TextStyle(color: AppTheme.starlight, fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_saran.isNotEmpty && !isEditing) ...[
                      const Text('Saran Anda saat ini:', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                      const SizedBox(height: 8),
                      _buildFeedbackCard('Saran Tersimpan', _saran, Icons.check_circle_outline, AppTheme.nebulaGreen),
                    ],
                    if (isEditing) ...[
                      if (_saran.isNotEmpty) ...[
                        const Text('Ubah Saran:', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                        const SizedBox(height: 8),
                      ],
                      TextField(
                        controller: controller,
                        maxLines: 4,
                        style: const TextStyle(color: AppTheme.starlight),
                        decoration: InputDecoration(
                          hintText: 'Tulis saran Anda di sini...',
                          hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                          filled: true,
                          fillColor: AppTheme.deepSpace.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppTheme.nebulaGreen),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            if (isEditing && _saran.isNotEmpty) {
                              setStateDialog(() => isEditing = false);
                              controller.text = _saran; // Reset input
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          child: Text(isEditing && _saran.isNotEmpty ? 'Batal Edit' : 'Tutup', style: const TextStyle(color: AppTheme.marsRed, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        if (!isEditing)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.nebulaGreen.withOpacity(0.2),
                              foregroundColor: AppTheme.nebulaGreen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              elevation: 0,
                            ),
                            onPressed: () {
                              setStateDialog(() {
                                isEditing = true;
                              });
                            },
                            child: const Text('Edit Saran', style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                        else
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.nebulaGreen,
                              foregroundColor: AppTheme.deepSpace,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            onPressed: () async {
                              final userId = _user!['id'];
                              final saranBaru = controller.text.trim();
                              await DatabaseHelper.instance.saveSaranKesan(userId, saranBaru, _kesan);
                              setState(() => _saran = saranBaru);
                              if (mounted) Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Saran disimpan'), backgroundColor: AppTheme.nebulaGreen),
                              );
                            },
                            child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Future<void> _showKesanDialog() async {
    TextEditingController controller = TextEditingController(text: _kesan);
    bool isEditing = _kesan.isEmpty;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.auroraBlue.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.auroraBlue.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.emoji_emotions_outlined, color: AppTheme.auroraBlue, size: 28),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Kesan untuk mk TPM', style: TextStyle(color: AppTheme.starlight, fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_kesan.isNotEmpty && !isEditing) ...[
                      const Text('Kesan Anda saat ini:', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                      const SizedBox(height: 8),
                      _buildFeedbackCard('Kesan Tersimpan', _kesan, Icons.check_circle_outline, AppTheme.auroraBlue),
                    ],
                    if (isEditing) ...[
                      if (_kesan.isNotEmpty) ...[
                        const Text('Ubah Kesan:', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                        const SizedBox(height: 8),
                      ],
                      TextField(
                        controller: controller,
                        maxLines: 4,
                        style: const TextStyle(color: AppTheme.starlight),
                        decoration: InputDecoration(
                          hintText: 'Tulis kesan Anda di sini...',
                          hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                          filled: true,
                          fillColor: AppTheme.deepSpace.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppTheme.auroraBlue),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            if (isEditing && _kesan.isNotEmpty) {
                              setStateDialog(() => isEditing = false);
                              controller.text = _kesan; // Reset input
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          child: Text(isEditing && _kesan.isNotEmpty ? 'Batal Edit' : 'Tutup', style: const TextStyle(color: AppTheme.marsRed, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        if (!isEditing)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.auroraBlue.withOpacity(0.2),
                              foregroundColor: AppTheme.auroraBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              elevation: 0,
                            ),
                            onPressed: () {
                              setStateDialog(() {
                                isEditing = true;
                              });
                            },
                            child: const Text('Edit Kesan', style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                        else
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.auroraBlue,
                              foregroundColor: AppTheme.starlight,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            onPressed: () async {
                              final userId = _user!['id'];
                              final kesanBaru = controller.text.trim();
                              await DatabaseHelper.instance.saveSaranKesan(userId, _saran, kesanBaru);
                              setState(() => _kesan = kesanBaru);
                              if (mounted) Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Kesan disimpan'), backgroundColor: AppTheme.nebulaGreen),
                              );
                            },
                            child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
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
      appBar: AstroAppBar(title: 'Profil Saya'),
      body: StarBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header Avatar + Nama + Email
              Row(
                children: [
                  GestureDetector(
                    onTap: _editPhoto,
                    child: Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(colors: [AppTheme.auroraBlue, AppTheme.cosmicPurple]),
                      ),
                      child: ClipOval(
                        child: _user!['photo_path'] != null && File(_user!['photo_path']).existsSync()
                            ? Image.file(File(_user!['photo_path']), fit: BoxFit.cover, width: 70, height: 70)
                            : const Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_user!['name'], style: const TextStyle(color: AppTheme.starlight, fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(_user!['email'], style: const TextStyle(color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Statistik Belajar (Jumlah Kuis, Rata-rata)
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
                    _statItem('Jumlah Kuis', _uniqueQuizzes),
                    _statItem('Percobaan', _totalAttempts),
                    _statItem('Rata-rata Nilai', _averageScore.round()),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Menu
              _menuTile(
                icon: Icons.person_outline,
                title: 'Edit Profil',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  ).then((_) => loadProfile()); // refresh setelah kembali
                },
              ),
              _menuTile(
                icon: Icons.feedback_outlined,
                title: _saran.isEmpty ? 'Tulis Saran' : 'Edit Saran',
                onTap: _showSaranDialog,
              ),
              _menuTile(
                icon: Icons.emoji_emotions_outlined,
                title: _kesan.isEmpty ? 'Tulis Kesan' : 'Edit Kesan',
                onTap: _showKesanDialog,
              ),
              if (_deviceSupportsBiometric)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: AppTheme.cardBg,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: SwitchListTile(
                    title: const Text('Login dengan Biometrik', style: TextStyle(color: AppTheme.starlight)),
                    secondary: const Icon(Icons.fingerprint, color: AppTheme.auroraBlue),
                    activeColor: AppTheme.nebulaGreen,
                    value: _biometricEnabled,
                    onChanged: _toggleBiometric,
                  ),
                ),
              _menuTile(
                icon: Icons.logout,
                title: 'Logout',
                onTap: _logout,
                isDestructive: true,
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

  Widget _menuTile({required IconData icon, required String title, required VoidCallback onTap, Widget? trailing, bool isDestructive = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppTheme.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? AppTheme.marsRed : AppTheme.auroraBlue),
        title: Text(title, style: TextStyle(color: isDestructive ? AppTheme.marsRed : AppTheme.starlight)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppTheme.auroraBlue),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFeedbackCard(String title, String content, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.starlight,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              color: AppTheme.starlight,
              height: 1.6,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}