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
    // Panggil generator soal berdasarkan kategori
    switch (widget.category) {
      case 'planet':
        _questions = _generatePlanetQuestions();
        break;
      case 'rasi':
        _questions = _generateRasiQuestions();
        break;
      case 'gerhana':
        _questions = _generateGerhanaQuestions();
        break;
      case 'galaksi':
        _questions = _generateGalaksiQuestions();
        break;
      default:
        _questions = [];
    }
    // Acak urutan soal
    _questions.shuffle();
    // Potong menjadi 6 soal pertama (jika lebih dari 6)
    if (_questions.length > 6) _questions = _questions.sublist(0, 6);
  }

  // ==================== SOAL PLANET ====================
  List<Map<String, dynamic>> _generatePlanetQuestions() {
    return [
      {
        'question': 'Apa nama lain dari planet Merkurius?',
        'options': ['Uttaran', 'Anteroid', 'Utarid', 'Vulcan'],
        'correctIndex': 2,
        'explanation': 'Merkurius dalam bahasa Arab disebut "Utarid". Nama ini sering digunakan dalam literatur astronomi tradisional Indonesia.',
      },
      {
        'question': 'Planet terpanas di tata surya adalah...',
        'options': ['Merkurius', 'Venus', 'Mars', 'Jupiter'],
        'correctIndex': 1,
        'explanation': 'Venus adalah planet terpanas karena atmosfernya yang tebal menjebak panas (efek rumah kaca ekstrem).',
      },
      {
        'question': 'Planet manakah yang dikenal sebagai "Bintang Fajar" atau "Bintang Senja"?',
        'options': ['Mars', 'Jupiter', 'Saturnus', 'Venus'],
        'correctIndex': 3,
        'explanation': 'Venus sering terlihat terang di pagi atau sore hari dan dijuluki Bintang Fajar/Senja.',
      },
      {
        'question': 'Berapa banyak bulan yang dimiliki Bumi?',
        'options': ['0', '1', '2', '3'],
        'correctIndex': 1,
        'explanation': 'Bumi memiliki satu satelit alami yaitu Bulan.',
      },
      {
        'question': 'Planet dengan sistem cincin terindah dan terbesar adalah...',
        'options': ['Jupiter', 'Uranus', 'Neptunus', 'Saturnus'],
        'correctIndex': 3,
        'explanation': 'Saturnus memiliki cincin yang sangat mencolok, terdiri dari es dan batuan.',
      },
      {
        'question': 'Planet terbesar di tata surya adalah...',
        'options': ['Saturnus', 'Jupiter', 'Uranus', 'Neptunus'],
        'correctIndex': 1,
        'explanation': 'Jupiter adalah planet terbesar, massanya 2,5 kali gabungan semua planet lain.',
      },
      {
        'question': 'Planet mana yang dijuluki "Planet Merah"?',
        'options': ['Mars', 'Merkurius', 'Yupiter', 'Venus'],
        'correctIndex': 0,
        'explanation': 'Mars disebut Planet Merah karena permukaannya mengandung oksida besi (karat).',
      },
      {
        'question': 'Planet dengan periode rotasi paling cepat (hari terpendek) adalah...',
        'options': ['Bumi', 'Mars', 'Jupiter', 'Saturnus'],
        'correctIndex': 2,
        'explanation': 'Jupiter berotasi hanya dalam waktu sekitar 10 jam, tercepat di tata surya.',
      },
    ];
  }

  // ==================== SOAL RASI BINTANG ====================
  List<Map<String, dynamic>> _generateRasiQuestions() {
    return [
      {
        'question': 'Rasi bintang apakah yang paling mudah dikenali dengan sabuk tiga bintang?',
        'options': ['Scorpius', 'Orion', 'Leo', 'Ursa Major'],
        'correctIndex': 1,
        'explanation': 'Orion memiliki tiga bintang berjajar yang disebut Sabuk Orion.',
      },
      {
        'question': 'Bintang paling terang di rasi Orion adalah...',
        'options': ['Betelgeuse', 'Rigel', 'Sirius', 'Aldebaran'],
        'correctIndex': 1,
        'explanation': 'Rigel adalah bintang paling terang di Orion, berwarna biru keputihan.',
      },
      {
        'question': 'Rasi bintang apakah yang melambangkan kalajengking?',
        'options': ['Leo', 'Scorpius', 'Cancer', 'Taurus'],
        'correctIndex': 1,
        'explanation': 'Scorpius adalah rasi berbentuk kalajengking, terlihat di belahan selatan.',
      },
      {
        'question': 'Rasi mana yang dikenal dengan "Salib Selatan" dan menjadi ikon langit selatan?',
        'options': ['Crux', 'Centaurus', 'Ara', 'Lupus'],
        'correctIndex': 0,
        'explanation': 'Crux (Salib Selatan) adalah rasi terkecil namun paling dikenal di belahan selatan.',
      },
      {
        'question': 'Rasi bintang manakah yang berisi bintang Polaris (Bintang Utara)?',
        'options': ['Ursa Major', 'Ursa Minor', 'Cassiopeia', 'Cepheus'],
        'correctIndex': 1,
        'explanation': 'Polaris adalah bintang paling terang di rasi Ursa Minor (Beruang Kecil).',
      },
      {
        'question': '"Big Dipper" adalah bagian dari rasi bintang...',
        'options': ['Ursa Minor', 'Ursa Major', 'Draco', 'Hercules'],
        'correctIndex': 1,
        'explanation': 'Big Dipper ( sendok besar ) adalah asterisma dalam rasi Ursa Major.',
      },
    ];
  }

  // ==================== SOAL GERHANA ====================
  List<Map<String, dynamic>> _generateGerhanaQuestions() {
    return [
      {
        'question': 'Apa yang terjadi saat Bulan berada di antara Bumi dan Matahari dalam satu garis lurus?',
        'options': ['Gerhana Bulan', 'Gerhana Matahari', 'Bulan Purnama', 'Bulan Sabit'],
        'correctIndex': 1,
        'explanation': 'Gerhana Matahari terjadi ketika Bulan menutupi Matahari.',
      },
      {
        'question': 'Gerhana Matahari total berlangsung paling lama sekitar...',
        'options': ['1-2 menit', '7-8 menit', '2-3 menit', '10 menit'],
        'correctIndex': 0,
        'explanation': 'Durasi maksimum gerhana Matahari total sekitar 7,5 menit, tetapi biasanya 2-3 menit. Opsi 1-2 menit paling mendekati rata-rata.',
      },
      {
        'question': 'Fenomena "Blood Moon" terjadi saat...',
        'options': ['Gerhana Matahari Cincin', 'Gerhana Bulan Total', 'Gerhana Matahari Sebagian', 'Gerhana Bulan Sebagian'],
        'correctIndex': 1,
        'explanation': 'Bulan tampak merah saat gerhana bulan total karena cahaya matahari dibiaskan atmosfer Bumi.',
      },
      {
        'question': 'Disebut apakah gerhana Matahari yang Bulan terlalu jauh sehingga tidak sepenuhnya menutupi Matahari?',
        'options': ['Gerhana Total', 'Gerhana Cincin', 'Gerhana Sebagian', 'Gerhana Hibrida'],
        'correctIndex': 1,
        'explanation': 'Gerhana cincin terjadi ketika Bulan berada di apogee (jarak terjauh), sehingga tampak lebih kecil.',
      },
      {
        'question': 'Berapa kali gerhana dapat terjadi dalam satu tahun paling banyak?',
        'options': ['4 kali', '5 kali', '7 kali', '9 kali'],
        'correctIndex': 2,
        'explanation': 'Dalam satu tahun bisa terjadi hingga 7 kali gerhana (Matahari dan Bulan).',
      },
      {
        'question': 'Mengapa gerhana Matahari tidak terjadi setiap bulan?',
        'options': ['Karena Bulan terlalu kecil', 'Karena orbit Bulan miring terhadap ekliptika', 'Karena Bumi terlalu jauh', 'Karena Matahari terlalu terang'],
        'correctIndex': 1,
        'explanation': 'Bidang orbit Bulan miring sekitar 5 derajat terhadap bidang orbit Bumi, sehingga bayangan Bulan sering meleset.',
      },
    ];
  }

  // ==================== SOAL GALAKSI ====================
  List<Map<String, dynamic>> _generateGalaksiQuestions() {
    return [
      {
        'question': 'Galaksi tempat tata surya kita berada disebut...',
        'options': ['Andromeda', 'Bima Sakti', 'Triangulum', 'Awan Magellan'],
        'correctIndex': 1,
        'explanation': 'Tata surya kita berada di galaksi Bima Sakti (Milky Way).',
      },
      {
        'question': 'Galaksi spiral terdekat dengan Bima Sakti adalah...',
        'options': ['Galaksi Sombrero', 'Galaksi Pusaran Air', 'Andromeda', 'Galaksi Mata Hitam'],
        'correctIndex': 2,
        'explanation': 'Galaksi Andromeda (M31) berjarak sekitar 2,5 juta tahun cahaya dan sedang mendekat.',
      },
      {
        'question': 'Bentuk galaksi Bima Sakti adalah...',
        'options': ['Spiral biasa', 'Spiral berpalang', 'Elips', 'Tak beraturan'],
        'correctIndex': 1,
        'explanation': 'Bima Sakti adalah galaksi spiral berpalang (barred spiral).',
      },
      {
        'question': 'Objek apakah yang berada di pusat hampir setiap galaksi?',
        'options': ['Bintang neutron', 'Lubang hitam supermasif', 'Nebula', 'Kumparan bintang'],
        'correctIndex': 1,
        'explanation': 'Pusat galaksi aktif biasanya dihuni lubang hitam supermasif.',
      },
      {
        'question': 'Galaksi manakah yang merupakan satelit terdekat Bima Sakti?',
        'options': ['Awan Magellan Besar', 'Andromeda', 'Galaksi Triangulum', 'Galaksi Sombrero'],
        'correctIndex': 0,
        'explanation': 'Awan Magellan Besar adalah galaksi satelit Bima Sakti, berjarak 160.000 tahun cahaya.',
      },
      {
        'question': 'Galaksi dengan pita debu hitam di pusatnya disebut...',
        'options': ['Galaksi Pusaran Air', 'Galaksi Mata Hitam', 'Galaksi Sombrero', 'Galaksi Bunga Matahari'],
        'correctIndex': 1,
        'explanation': 'Galaksi Mata Hitam (Black Eye Galaxy, M64) memiliki jalur debu gelap di depan intinya.',
      },
    ];
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
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AstroAppBar(title: 'Kuis ${widget.category.toUpperCase()}'),
        body: const Center(child: Text('Soal tidak tersedia', style: TextStyle(color: AppTheme.starlight))),
      );
    }
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