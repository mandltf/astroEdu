// lib/services/local/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'database_helper.dart';
import '../../utils/constants.dart'; // <-- tambahkan import AppConstants

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final LocalAuthentication _localAuth = LocalAuthentication();

  // Encrypt password with AES
  String encryptPassword(String password) {
    final key = enc.Key.fromUtf8(AppConstants.encryptionKey);
    final iv = enc.IV.fromUtf8(AppConstants.encryptionIV);
    final encrypter = enc.Encrypter(enc.AES(key));
    return encrypter.encrypt(password, iv: iv).base64;
  }

  String decryptPassword(String encrypted) {
    final key = enc.Key.fromUtf8(AppConstants.encryptionKey);
    final iv = enc.IV.fromUtf8(AppConstants.encryptionIV);
    final encrypter = enc.Encrypter(enc.AES(key));
    return encrypter.decrypt64(encrypted, iv: iv);
  }

  Future<Map<String, dynamic>?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final existing = await DatabaseHelper.instance.getUserByEmail(email);
    if (existing != null) return {'error': 'Email sudah terdaftar'};

    final encryptedPw = encryptPassword(password);
    final userId = await DatabaseHelper.instance.insertUser({
      'name': name,
      'email': email,
      'password': encryptedPw,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Unlock first item in each category
    for (final cat in ['planet', 'rasi', 'gerhana', 'galaksi']) {
      await DatabaseHelper.instance.unlockItem(userId, cat, 'item_0');
    }

    await _saveSession(userId);
    return {'success': true, 'userId': userId};
  }

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    final user = await DatabaseHelper.instance.getUserByEmail(email);
    if (user == null) return {'error': 'Email tidak ditemukan'};

    final decrypted = decryptPassword(user['password']);
    if (decrypted != password) return {'error': 'Password salah'};

    await _saveSession(user['id']);
    return {'success': true, 'userId': user['id']};
  }

  Future<bool> loginWithBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();

      if (!canCheck || !isSupported) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Scan fingerprint untuk masuk ke AstroEdu',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return authenticated;
    } catch (e) {
      print("Biometric error: $e");
      return false;
    }
  }

  Future<void> _saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
    await prefs.setBool('is_logged_in', true);
  }

  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (!isLoggedIn) return null;
    return prefs.getInt('user_id');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }
}