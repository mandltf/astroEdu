import 'package:flutter/material.dart';
import '../../../services/local/auth_service.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/star_background.dart';
import 'register_screen.dart';
import '../home/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    // Cek apakah perangkat mendukung biometrik
    final available = await AuthService.instance.isBiometricAvailable();
    if (mounted) setState(() => _biometricAvailable = available);
  }

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _pwCtrl.text.isEmpty) {
      _showError('Email dan password harus diisi');
      return;
    }
    setState(() => _loading = true);
    final result = await AuthService.instance.login(
      email: _emailCtrl.text.trim(),
      password: _pwCtrl.text,
    );
    setState(() => _loading = false);
    if (result == null || result['error'] != null) {
      _showError(result?['error'] ?? 'Login gagal');
    } else {
      _toHome();
    }
  }

  Future<void> _biometricLogin() async {
    // Cek apakah ada session tersimpan (user pernah login sebelumnya)
    final hasSession = await AuthService.instance.hasSavedSession();
    if (!hasSession) {
      _showError('Silakan login dengan email terlebih dahulu untuk menyimpan session');
      return;
    }
    
    final success = await AuthService.instance.loginWithBiometric();
    if (success) {
      _toHome();
    } else {
      _showError('Autentikasi biometrik gagal');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.marsRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _toHome() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const MainScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StarBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.auto_awesome, size: 64, color: AppTheme.auroraBlue),
                const SizedBox(height: 16),
                const Text(
                  'AstroEdu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.starlight,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  'Jelajahi Alam Semesta',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.auroraBlue, fontSize: 14),
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Masuk ke Akunmu',
                          style: TextStyle(
                            color: AppTheme.starlight,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppTheme.starlight),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined, color: AppTheme.auroraBlue),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _pwCtrl,
                        obscureText: _obscure,
                        style: const TextStyle(color: AppTheme.starlight),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.auroraBlue),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                                color: AppTheme.auroraBlue),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _loading
                            ? const SizedBox(height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                      // Tombol biometrik muncul jika perangkat mendukung
                      if (_biometricAvailable) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _biometricLogin,
                          icon: const Icon(Icons.fingerprint, color: AppTheme.auroraBlue),
                          label: const Text('Masuk dengan Biometrik',
                              style: TextStyle(color: AppTheme.auroraBlue)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.auroraBlue),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum punya akun?', style: TextStyle(color: Color(0xFF9CA3AF))),
                    TextButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: const Text('Daftar Sekarang',
                          style: TextStyle(color: AppTheme.auroraBlue, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}