// lib/views/screens/ai/astrobot_screen.dart
import 'package:flutter/material.dart';
import '../../../services/api/gemini_service.dart';
import '../../../services/local/auth_service.dart';
import '../../../services/local/database_helper.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/star_background.dart';
import '../../widgets/common_widgets.dart';

class AstroBotScreen extends StatefulWidget {
  const AstroBotScreen({super.key});

  @override
  State<AstroBotScreen> createState() => _AstroBotScreenState();
}

class _AstroBotScreenState extends State<AstroBotScreen> {
  final TextEditingController _messageCtrl = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserAndHistory();
  }

  Future<void> _loadUserAndHistory() async {
    _userId = await AuthService.instance.getCurrentUserId();
    if (_userId != null) {
      final history = await DatabaseHelper.instance.getChatHistory(_userId!);
      setState(() {
        _messages.clear();
        for (var h in history) {
          _messages.add({
            'role': h['role'],
            'message': h['message'],
          });
        }
        if (_messages.isEmpty) {
          _messages.add({
            'role': 'bot',
            'message': 'Halo! 👋 Aku AstroBot, asisten astronomimu. Tanyakan apa saja tentang planet, bintang, galaksi, atau fenomena langit lainnya! 🚀',
          });
        }
      });
    } else {
      setState(() {
        _messages.add({
          'role': 'bot',
          'message': 'Halo! 👋 Aku AstroBot, asisten astronomimu. Silakan login terlebih dahulu untuk menyimpan riwayat chat.',
        });
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'message': text});
      _messageCtrl.clear();
      _isLoading = true;
    });

    if (_userId != null) {
      await DatabaseHelper.instance.insertChat({
        'user_id': _userId,
        'role': 'user',
        'message': text,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    final conversation = _messages.where((m) => m['role'] != 'system').map((m) => {
      'role': m['role']!,
      'message': m['message']!,
    }).toList();
    final response = await GeminiService.instance.sendMessage(conversation, text);

    setState(() {
      _messages.add({'role': 'bot', 'message': response});
      _isLoading = false;
    });

    if (_userId != null) {
      await DatabaseHelper.instance.insertChat({
        'user_id': _userId,
        'role': 'bot',
        'message': response,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> _clearHistory() async {
    if (_userId != null) {
      await DatabaseHelper.instance.clearChatHistory(_userId!);
      setState(() {
        _messages.clear();
        _messages.add({
          'role': 'bot',
          'message': 'Riwayat chat telah dibersihkan. Ada yang bisa aku bantu? 🌠',
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AstroAppBar(
        title: '🤖 AstroBot',
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearHistory,
            tooltip: 'Hapus riwayat',
          ),
        ],
      ),
      body: StarBackground(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (_, i) {
                  final msg = _messages.reversed.toList()[i];
                  final isUser = msg['role'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isUser ? AppTheme.auroraBlue : AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: isUser ? null : Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Text(
                        msg['message']!,
                        style: TextStyle(
                          color: isUser ? Colors.white : AppTheme.starlight,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageCtrl,
                      style: const TextStyle(color: AppTheme.starlight),
                      decoration: InputDecoration(
                        hintText: 'Tanya tentang astronomi...',
                        filled: true,
                        fillColor: AppTheme.cardBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppTheme.auroraBlue,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}