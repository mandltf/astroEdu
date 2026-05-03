import 'package:flutter/material.dart';
import '../../../services/local/auth_service.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/star_background.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  Future<void> _register() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _pwCtrl.text.isEmpty) {
      _showError('Semua field harus diisi');
      return;
    }
    if (_pwCtrl.text != _confirmPwCtrl.text) {
      _showError('Password tidak cocok');
      return;
    }
    if (_pwCtrl.text.length < 6) {
      _showError('Password minimal 6 karakter');
      return;
    }

    setState(() => _loading = true);
    final result = await AuthService.instance.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _pwCtrl.text,
    );
    setState(() => _loading = false);

    if (result == null || result['error'] != null) {
      _showError(result?['error'] ?? 'Pendaftaran gagal');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendaftaran berhasil! Silakan login.'),
            backgroundColor: AppTheme.nebulaGreen,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StarBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: AppTheme.starlight),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text('Buat Akun Baru',
                        style: TextStyle(
                          color: AppTheme.starlight,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
                const SizedBox(height: 24),
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
                      TextField(
                        controller: _nameCtrl,
                        style: const TextStyle(color: AppTheme.starlight),
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          prefixIcon: Icon(Icons.person_outline, color: AppTheme.auroraBlue),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      TextField(
                        controller: _confirmPwCtrl,
                        obscureText: _obscure,
                        style: const TextStyle(color: AppTheme.starlight),
                        decoration: const InputDecoration(
                          labelText: 'Konfirmasi Password',
                          prefixIcon: Icon(Icons.lock_outline, color: AppTheme.cosmicPurple),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _loading
                            ? const SizedBox(height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Daftar Sekarang',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}