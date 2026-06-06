import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // Gemini API Key - dibaca dari .env file
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY']?.trim() ?? '';
  
  // Currency API
  static const String currencyApiUrl = 'https://api.exchangerate-api.com/v4/latest/USD';
  
  // Wikipedia API
  static const String wikipediaApiUrl = 'https://id.wikipedia.org/api/rest_v1/page/summary/';
  static const String wikipediaSearchUrl = 'https://id.wikipedia.org/w/api.php';  // <-- tambahkan ini
  
  // Encryption
  static const String encryptionKey = 'AstroEdu2024SecretKey12345678901';
  static const String encryptionIV = 'AstroEduIV123456';

  // Data statis Planet
  static final List<Map<String, dynamic>> planetList = [
    {'id': 'mercure', 'name': 'Merkurius', 'emoji': '⚫', 'color': 0xFF9CA3AF, 'apiId': 'Merkurius'},
    {'id': 'venus', 'name': 'Venus', 'emoji': '🟡', 'color': 0xFFF59E0B, 'apiId': 'Venus'},
    {'id': 'earth', 'name': 'Bumi', 'emoji': '🌍', 'color': 0xFF3B82F6, 'apiId': 'Bumi'},
    {'id': 'mars', 'name': 'Mars', 'emoji': '🔴', 'color': 0xFFEF4444, 'apiId': 'Mars'},
    {'id': 'jupiter', 'name': 'Jupiter', 'emoji': '🟠', 'color': 0xFFF97316, 'apiId': 'Jupiter'},
    {'id': 'saturn', 'name': 'Saturnus', 'emoji': '🪐', 'color': 0xFFD97706, 'apiId': 'Saturnus'},
    {'id': 'uranus', 'name': 'Uranus', 'emoji': '🟢', 'color': 0xFF06B6D4, 'apiId': 'Uranus'},
    {'id': 'neptune', 'name': 'Neptunus', 'emoji': '🔵', 'color': 0xFF1D4ED8, 'apiId': 'Neptunus'},
  ];

  // Data statis Rasi Bintang
  static final List<Map<String, dynamic>> rasiList = [
    {'id': 'rasi_0', 'name': 'Orion', 'emoji': '⭐', 'color': 0xFF7C3AED, 'apiId': 'Orion_(rasi_bintang)'},
    {'id': 'rasi_1', 'name': 'Scorpius', 'emoji': '🦂', 'color': 0xFFEF4444, 'apiId': 'Scorpius'},
    {'id': 'rasi_2', 'name': 'Ursa Major', 'emoji': '🐻', 'color': 0xFF3B82F6, 'apiId': 'Ursa_Major'},
    {'id': 'rasi_3', 'name': 'Crux', 'emoji': '✝️', 'color': 0xFF10B981, 'apiId': 'Crux'},
    {'id': 'rasi_4', 'name': 'Leo', 'emoji': '🦁', 'color': 0xFFF59E0B, 'apiId': 'Leo_(rasi_bintang)'},
    {'id': 'rasi_5', 'name': 'Canis Major', 'emoji': '🐕', 'color': 0xFF06B6D4, 'apiId': 'Canis_Major'},
  ];

  // Data statis Gerhana
  static final List<Map<String, dynamic>> gerhanaList = [
    {'id': 'gerhana_0', 'name': 'Gerhana Matahari', 'emoji': '🌒', 'color': 0xFFF97316, 'apiId': 'Gerhana_matahari'},
    {'id': 'gerhana_1', 'name': 'Gerhana Bulan', 'emoji': '🌕', 'color': 0xFFB45309, 'apiId': 'Gerhana_bulan'},
  ];

  // Data statis Galaksi
  static final List<Map<String, dynamic>> galaksiList = [
    {'id': 'galaksi_0', 'name': 'Bima Sakti', 'emoji': '🌌', 'color': 0xFF7C3AED, 'apiId': 'Bima_Sakti'},
    {'id': 'galaksi_1', 'name': 'Galaksi Andromeda', 'emoji': '🌀', 'color': 0xFF3B82F6, 'apiId': 'Galaksi_Andromeda'},
    {'id': 'galaksi_2', 'name': 'Awan Magellan Besar', 'emoji': '☁️', 'color': 0xFF10B981, 'apiId': 'Awan_Magellan_Besar'},
    {'id': 'galaksi_3', 'name': 'Galaksi Pusaran', 'emoji': '🌊', 'color': 0xFF06B6D4, 'apiId': 'Galaksi_Pusaran'},
    {'id': 'galaksi_4', 'name': 'Galaksi Mata Hitam', 'emoji': '👁️', 'color': 0xFFEF4444, 'apiId': 'Galaksi_Mata_Hitam'},
  ];

  // Random facts
  static final List<String> randomFacts = [
    'Satu hari di Venus = 243 hari Bumi',
    'Matahari mengandung 99.86% massa tata surya',
    'Cahaya dari Matahari membutuhkan 8 menit 20 detik untuk mencapai Bumi',
    'Bima Sakti berputar sekali setiap 225-250 juta tahun',
    'Di luar angkasa, darah akan mendidih tanpa pakaian antariksa',
    'Suhu di Merkurius bisa mencapai 430°C di siang hari',
    'Jupiter memiliki badai raksasa yang berlangsung lebih dari 350 tahun',
    'Saturnus bisa mengapung di air karena kepadatannya lebih rendah',
    'Ada lebih banyak bintang di alam semesta daripada butir pasir di Bumi',
    'Uranus berotasi miring hampir 98 derajat',
    'Antares bisa 700x lebih besar dari Matahari',
    'Sirius adalah bintang paling terang di langit malam',
    'Galaksi Andromeda sedang mendekat ke Bima Sakti',
    'Neptunus memiliki angin terkencang: 2.100 km/jam',
    'Bulan bergerak menjauh 3.8 cm dari Bumi setiap tahun',
  ];
}