import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/star_background.dart';
import '../../widgets/common_widgets.dart';

class CatchStarGame extends StatefulWidget {
  const CatchStarGame({super.key});

  @override
  State<CatchStarGame> createState() => _CatchStarGameState();
}

class _CatchStarGameState extends State<CatchStarGame> {
  // Ukuran area game
  late double _screenWidth;
  late double _screenHeight;
  static const double _playerWidth = 80;
  static const double _playerHeight = 20;
  static const double _starSize = 30;

  // Posisi pemain (keranjang)
  double _playerX = 0; // 0 = kiri, 1 = kanan (relatif)
  double _actualPlayerLeft = 0;

  // Daftar bintang jatuh
  List<Star> _stars = [];

  // Skor dan nyawa
  int _score = 0;
  int _lives = 3;
  bool _isGameOver = false;

  // Timer untuk spawn bintang
  Timer? _spawnTimer;
  Timer? _moveTimer;

  // Sensor subscription
  StreamSubscription<AccelerometerEvent>? _accelerometerSub;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startSensors();
    _startGameLoop();
  }

  void _startSensors() {
    _accelerometerSub = accelerometerEvents.listen((event) {
      // event.x untuk kemiringan kiri/kanan (nilai -9.8 s/d 9.8)
      // Normalisasi ke -1..1, lalu ke posisi 0..1
      double tilt = event.x / 9.8; // kira-kira -1 s/d 1
      tilt = tilt.clamp(-1.0, 1.0);
      double newPlayerX = (_playerX + tilt * 0.1).clamp(0.0, 1.0);
      if (mounted) {
        setState(() {
          _playerX = newPlayerX;
          _actualPlayerLeft = _playerX * (_screenWidth - _playerWidth);
        });
      }
    });
  }

  void _startGameLoop() {
    // Spawn bintang setiap 0.8 detik
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!_isGameOver && mounted) {
        setState(() {
          _stars.add(Star(
            x: _random.nextDouble(),
            y: 0.0,
            speed: 0.005 + _random.nextDouble() * 0.01,
          ));
        });
      }
    });

    // Update posisi bintang setiap 30ms (~33 fps)
    _moveTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!_isGameOver && mounted) {
        setState(() {
          _updateStars();
        });
      }
    });
  }

  void _updateStars() {
    List<Star> remaining = [];
    for (var star in _stars) {
      star.y += star.speed;
      // Cek tabrakan dengan pemain
      double starLeft = star.x * (_screenWidth - _starSize);
      double starTop = star.y * (_screenHeight - _starSize);
      double playerLeft = _actualPlayerLeft;
      double playerTop = _screenHeight - _playerHeight - 20; // posisi y pemain

      if (starTop + _starSize >= playerTop &&
          starTop <= playerTop + _playerHeight &&
          starLeft + _starSize >= playerLeft &&
          starLeft <= playerLeft + _playerWidth) {
        // Tertangkap
        _score++;
        continue; // bintang ini hilang, tidak ditambahkan ke remaining
      }
      // Jika bintang melewati batas bawah, kurangi nyawa
      else if (star.y >= 1.0) {
        _lives--;
        if (_lives <= 0) {
          _isGameOver = true;
          _stopGame();
        }
        continue;
      }
      remaining.add(star);
    }
    _stars = remaining;
  }

  void _stopGame() {
    _spawnTimer?.cancel();
    _moveTimer?.cancel();
    _accelerometerSub?.cancel();
    if (mounted) setState(() {});
  }

  void _resetGame() {
    setState(() {
      _stars.clear();
      _score = 0;
      _lives = 3;
      _isGameOver = false;
      _playerX = 0.5;
      _actualPlayerLeft = _playerX * (_screenWidth - _playerWidth);
    });
    _startSensors();
    _startGameLoop();
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _moveTimer?.cancel();
    _accelerometerSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    if (_actualPlayerLeft == 0 && _playerX != 0) {
      _actualPlayerLeft = _playerX * (_screenWidth - _playerWidth);
    }

    return Scaffold(
      appBar: AstroAppBar(title: '✨ Tangkap Bintang ✨'),
      body: StarBackground(
        child: GestureDetector(
          onTap: () {
            // Untuk mencegah gesture lain mengganggu
          },
          child: Stack(
            children: [
              // Info skor dan nyawa
              Positioned(
                top: 20,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Skor: $_score', style: const TextStyle(color: AppTheme.solarGold, fontSize: 16)),
                ),
              ),
              Positioned(
                top: 20,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: List.generate(_lives, (index) => const Icon(Icons.favorite, color: AppTheme.marsRed, size: 16)),
                  ),
                ),
              ),
              // Bintang jatuh
              for (var star in _stars)
                Positioned(
                  left: star.x * (_screenWidth - _starSize),
                  top: star.y * (_screenHeight - _starSize),
                  child: const Icon(Icons.star, color: AppTheme.solarGold, size: _starSize),
                ),
              // Pemain (keranjang)
              Positioned(
                left: _actualPlayerLeft,
                bottom: 20,
                child: Container(
                  width: _playerWidth,
                  height: _playerHeight,
                  decoration: BoxDecoration(
                    color: AppTheme.auroraBlue,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: const Center(
                    child: Text('⬆️', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ),
              // Game over overlay
              if (_isGameOver)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('GAME OVER', style: TextStyle(color: AppTheme.marsRed, fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Text('Skor akhir: $_score', style: const TextStyle(color: AppTheme.starlight, fontSize: 18)),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Kembali'),
                                ),
                                ElevatedButton(
                                  onPressed: _resetGame,
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.auroraBlue),
                                  child: const Text('Main Lagi'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              // Petunjuk
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.deepSpace.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Miringkan HP ke kiri/kanan untuk menggerakkan', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Star {
  double x;
  double y;
  double speed;
  Star({required this.x, required this.y, required this.speed});
}