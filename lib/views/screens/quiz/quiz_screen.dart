// lib/views/screens/quiz/quiz_screen.dart
import 'package:flutter/material.dart';
import '../../../services/local/database_helper.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/star_background.dart';
import '../../widgets/common_widgets.dart';

class QuizScreen extends StatefulWidget {
  final String category;
  final List<Map<String, dynamic>> items;
  final int userId;

  const QuizScreen({
    super.key,
    required this.category,
    required this.items,
    required this.userId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Map<String, dynamic>> _questions;
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedOption;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  void _generateQuestions() {
    _questions = widget.items.map((item) {
      return {
        'question': 'Apa yang dimaksud dengan ${item['name']}?',
        'options': widget.items.map((i) => i['name'] as String).toList(),
        'correctIndex': widget.items.indexOf(item),
        'explanation': item['description'],
      };
    }).toList();
    _questions.shuffle();
  }

  void _selectAnswer(int idx) {
    if (_answered) return;
    setState(() {
      _selectedOption = idx;
      _answered = true;
      if (idx == _questions[_currentIndex]['correctIndex']) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    await DatabaseHelper.instance.insertQuizScore({
      'user_id': widget.userId,
      'category': widget.category,
      'score': _score,
      'total': _questions.length,
      'played_at': DateTime.now().toIso8601String(),
    });
    _showResultDialog();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: Text(
          _score >= _questions.length * 0.7 ? '🏆 Luar Biasa!' : '🚀 Terus Belajar!',
          style: const TextStyle(color: AppTheme.starlight),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Skor kamu: $_score / ${_questions.length}',
              style: const TextStyle(color: AppTheme.starlight, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _score >= _questions.length * 0.8
                  ? 'Kamu ahli dalam topik ini!'
                  : _score >= _questions.length * 0.6
                      ? 'Cukup bagus, pelajari lagi yuk!'
                      : 'Baca materi dulu ya biar lebih paham!',
              style: const TextStyle(color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: AppTheme.auroraBlue)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];
    return Scaffold(
      appBar: AstroAppBar(title: '📝 Kuis ${widget.category.toUpperCase()}'),
      body: StarBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _questions.length,
                backgroundColor: AppTheme.cardBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.auroraBlue),
              ),
              const SizedBox(height: 8),
              Text(
                'Soal ${_currentIndex + 1} / ${_questions.length}',
                style: const TextStyle(color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Text(
                  q['question'] as String,
                  style: const TextStyle(color: AppTheme.starlight, fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ...List.generate(
                (q['options'] as List<String>).length,
                (idx) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: () => _selectAnswer(idx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _answered
                          ? (idx == q['correctIndex']
                              ? AppTheme.nebulaGreen
                              : (idx == _selectedOption && idx != q['correctIndex']
                                  ? AppTheme.marsRed
                                  : AppTheme.cardBg))
                          : AppTheme.cardBg,
                      side: BorderSide(
                        color: _answered && idx == q['correctIndex']
                            ? AppTheme.nebulaGreen
                            : (_answered && idx == _selectedOption && idx != q['correctIndex']
                                ? AppTheme.marsRed
                                : AppTheme.cardBorder),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      (q['options'] as List<String>)[idx],
                      style: TextStyle(
                        color: _answered && (idx == q['correctIndex'] || idx == _selectedOption)
                            ? Colors.white
                            : AppTheme.starlight,
                      ),
                    ),
                  ),
                ),
              ),
              if (_answered) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.solarGold.withOpacity(0.3)),
                  ),
                  child: Text(
                    q['explanation'] as String,
                    style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: Text(_currentIndex < _questions.length - 1 ? 'Soal Berikutnya →' : 'Lihat Hasil'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}