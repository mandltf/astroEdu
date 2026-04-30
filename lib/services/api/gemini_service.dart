// lib/services/api/gemini_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';

class GeminiService {
  static final GeminiService instance = GeminiService._();
  GeminiService._();

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  static const String _systemPrompt = '''
Kamu adalah AstroBot, asisten AI khusus astronomi dalam aplikasi AstroEdu. 
Tugas kamu adalah membantu pengguna belajar tentang astronomi dengan cara yang menyenangkan dan informatif.
Kamu harus:
- Menjawab pertanyaan tentang planet, bintang, galaksi, fenomena astronomi, tata surya
- Menggunakan bahasa Indonesia yang mudah dipahami
- Memberikan fakta menarik dan mengaitkan dengan kehidupan sehari-hari
- Jika ditanya di luar topik astronomi, sopan arahkan kembali ke topik astronomi
- Berikan jawaban yang akurat secara ilmiah namun tetap menarik
Format respons: gunakan emoji astronomi yang relevan untuk mempercantik jawaban.
''';

  Future<String> sendMessage(List<Map<String, String>> conversationHistory, String newMessage) async {
    try {
      final messages = <Map<String, dynamic>>[];
      
      messages.add({
        'role': 'user',
        'parts': [{'text': _systemPrompt}]
      });
      messages.add({
        'role': 'model',
        'parts': [{'text': 'Halo! Aku AstroBot, siap membantu kamu menjelajahi alam semesta! 🚀⭐ Ada yang ingin kamu ketahui tentang astronomi?'}]
      });
      
      for (final msg in conversationHistory) {
        messages.add({
          'role': msg['role'] == 'user' ? 'user' : 'model',
          'parts': [{'text': msg['message']}]
        });
      }
      
      messages.add({
        'role': 'user',
        'parts': [{'text': newMessage}]
      });

      final response = await http.post(
        Uri.parse('$_baseUrl?key=${AppConstants.geminiApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': messages,
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ?? 
               'Maaf, aku tidak bisa memberikan respons saat ini.';
      } else {
        return _getOfflineResponse(newMessage);
      }
    } catch (_) {
      return _getOfflineResponse(newMessage);
    }
  }

  String _getOfflineResponse(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('planet')) {
      return '🪐 Tata surya kita memiliki 8 planet: Merkurius, Venus, Bumi, Mars, Jupiter, Saturnus, Uranus, dan Neptunus. Setiap planet memiliki karakteristik unik! Planet mana yang ingin kamu pelajari lebih lanjut?';
    } else if (lower.contains('bintang') || lower.contains('star')) {
      return '⭐ Bintang adalah bola gas panas raksasa yang menghasilkan energi melalui fusi nuklir. Matahari kita adalah bintang berjenis G-type (bintang kuning kerdil). Ada sekitar 100-400 miliar bintang di galaksi Bima Sakti kita!';
    } else if (lower.contains('bulan') || lower.contains('moon')) {
      return '🌙 Bulan adalah satelit alami Bumi yang terbentuk sekitar 4.5 miliar tahun lalu akibat tabrakan benda raksasa dengan Bumi purba. Jarak Bumi-Bulan sekitar 384.400 km, dan Bulan bergerak menjauh 3.8 cm setiap tahun!';
    } else if (lower.contains('galaksi') || lower.contains('galaxy')) {
      return '🌌 Galaksi adalah kumpulan bintang, gas, debu, dan materi gelap yang disatukan oleh gravitasi. Bima Sakti kita mengandung 100-400 miliar bintang! Galaksi terdekat adalah Andromeda yang berjarak 2.5 juta tahun cahaya.';
    } else if (lower.contains('lubang hitam') || lower.contains('black hole')) {
      return '🕳️ Lubang hitam adalah wilayah ruang dengan gravitasi sangat kuat sehingga bahkan cahaya pun tidak bisa lepas! Terbentuk dari bintang masif yang meledak (supernova) atau dari penggabungan galaksi. Di pusat Bima Sakti ada lubang hitam supermasif bernama Sagittarius A*!';
    }
    return '🌠 Pertanyaan menarik! Sayangnya koneksi internet sedang bermasalah. Coba tanyakan tentang planet, bintang, galaksi, atau fenomena astronomi lainnya dan aku akan bantu dengan pengetahuanku tentang alam semesta! 🚀';
  }
}