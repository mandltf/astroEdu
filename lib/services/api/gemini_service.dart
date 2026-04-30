import 'package:google_generative_ai/google_generative_ai.dart';
import '../../utils/constants.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  static final GeminiService instance = GeminiService._();
  GeminiService._();

  late final GenerativeModel _model;
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    
    // API key diambil dari constants.dart
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: AppConstants.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 1024,
      ),
    );
    _initialized = true;
  }

  Future<String> sendMessage(List<Map<String, String>> conversationHistory, String newMessage) async {
    // Cek API key
    if (AppConstants.geminiApiKey.isEmpty || AppConstants.geminiApiKey == 'YOUR_GEMINI_API_KEY') {
      if (kDebugMode) print('Gemini API key not set. Using offline mode.');
      return _getOfflineResponse(newMessage);
    }

    try {
      await _init();
      // Mulai chat session
      final chat = _model.startChat();
      // Kirim pesan pengguna
      final response = await chat.sendMessage(Content.text(newMessage));
      return response.text ?? 'Maaf, saya tidak bisa menjawab saat ini.';
    } catch (e) {
      if (kDebugMode) print('Gemini error: $e');
      return _getOfflineResponse(newMessage);
    }
  }

  String _getOfflineResponse(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('planet')) {
      return '🪐 Tata surya kita memiliki 8 planet: Merkurius, Venus, Bumi, Mars, Jupiter, Saturnus, Uranus, Neptunus. Setiap planet punya keunikan! Planet mana yang ingin kamu pelajari?';
    } else if (lower.contains('bintang') || lower.contains('star')) {
      return '⭐ Bintang adalah bola gas panas raksasa. Matahari kita juga bintang lho! Ada sekitar 100-400 miliar bintang di galaksi Bima Sakti. Luar biasa! ✨';
    } else if (lower.contains('bulan') || lower.contains('moon')) {
      return '🌙 Bulan adalah satelit alami Bumi. Jaraknya 384.400 km. Bulan terbentuk 4,5 miliar tahun lalu dari tabrakan raksasa. Setiap tahun bulan menjauh 3,8 cm!';
    } else if (lower.contains('galaksi') || lower.contains('galaxy')) {
      return '🌌 Galaksi adalah kumpulan bintang, gas, debu, dan materi gelap. Bima Sakti diameter 100.000 tahun cahaya, di pusatnya ada lubang hitam supermasif!';
    } else if (lower.contains('lubang hitam') || lower.contains('black hole')) {
      return '🕳️ Lubang hitam punya gravitasi sangat kuat, cahaya pun tak bisa lepas. Di pusat Bima Sakti ada Sagittarius A*, massanya 4 juta kali Matahari!';
    }
    return '🌠 Halo! Aku AstroBot. Koneksi internet sedang bermasalah, jadi aku pakai mode darurat. Tanyakan tentang planet, bintang, bulan, galaksi, atau lubang hitam ya! 🚀';
  }
}