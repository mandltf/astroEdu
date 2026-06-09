import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:encrypt/encrypt.dart' as enc;
import 'database_helper.dart';
import '../../utils/constants.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final LocalAuthentication _localAuth = LocalAuthentication();

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

  /// Cek apakah biometrik tersedia dan sudah didaftarkan
  Future<bool> isBiometricAvailable() async {
    try {
      // Cek apakah perangkat mendukung biometrik
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) return false;
      
      // Cek apakah ada biometrik yang terdaftar
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;
      
      // Cek jenis biometrik yang tersedia
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      print('Biometric check error: $e');
      return false;
    }
  }

  /// Login dengan biometrik (Face ID / Fingerprint)
  Future<bool> loginWithBiometric() async {
    try {
      // Cek ketersediaan biometrik
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        print('Biometric not available');
        return false;
      }

      // Cek apakah ada session sebelumnya (user sudah pernah login)
      final userId = await getLastUserId();
      if (userId == null) {
        print('No existing session');
        return false;
      }

      // Lakukan autentikasi biometrik
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Verifikasi identitas untuk masuk ke AstroEdu',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true, // Hanya biometrik (Face ID/Fingerprint), tidak pakai PIN/Pattern
        ),
      );
      
      if (authenticated) {
        await _saveSession(userId);
        return true;
      }
      return false;
    } catch (e) {
      print('Biometric auth error: $e');
      return false;
    }
  }

  Future<void> _saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
    await prefs.setInt('last_user_id', userId);
    await prefs.setBool('is_logged_in', true);
  }

  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (!isLoggedIn) return null;
    return prefs.getInt('user_id');
  }

  Future<int?> getLastUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('last_user_id');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.setBool('is_logged_in', false);
  }

  Future<bool> isBiometricEnabledForUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled_$userId') ?? false;
  }

  Future<void> setBiometricEnabledForUser(int userId, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled_$userId', enabled);
  }

  Future<bool> hasSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    return isLoggedIn;
  }
}