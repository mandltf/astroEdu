import 'dart:async';
import 'dart:math';
import 'dart:ui';
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
  late double _screenWidth;
  late double _screenHeight;

  static const double _blackHoleSize = 120.0;
  static const double _starSize = 32.0;
  static const double _speedFactor = 1.4;
  static const int _winScore = 10;

  double _blackHoleX = 0.5;
  double _actualLeft = 0.0;

  List<Star> _stars = [];
  int _score = 0;
  int _lives = 5;

  bool _isGameStarted = false;
  bool _isDialogVisible = true; 
  bool _isGameOver = false;
  bool _isWin = false;

  Timer? _spawnTimer;
  Timer? _moveTimer;
  StreamSubscription<AccelerometerEvent>? _accelerometerSub;

  final Random _random = Random();
  double _filteredTilt = 0;

  final String _fact =
      "Lubang hitam memiliki gravitasi sangat kuat sehingga "
      "bintang pun bisa 'dimakan'!"
      "Sekarang, kamu jadi lubang hitam. Miringkan HP untuk memakan bintang jatuh!";

  @override
  void initState() {
    super.initState();
    // Inisialisasi awal agar tidak error saat build pertama
    _actualLeft = 0.0;
  }

  void _startGame() {
    setState(() {
      _isGameStarted = true;
      _isDialogVisible = false;
      _isGameOver = false;
      _isWin = false;
      _score = 0;
      _lives = 5;
      _stars.clear();
      _blackHoleX = 0.5;
      _actualLeft = _blackHoleX * (_screenWidth - _blackHoleSize);
    });

    _startSensors();
    _startGameLoop();
  }

  void _startSensors() {
    _accelerometerSub?.cancel();
    _accelerometerSub = accelerometerEvents.listen((event) {
      if (_isGameOver || _isWin || _isDialogVisible) return;

      double rawTilt = -event.x / 9.8;
      _filteredTilt = (_filteredTilt * 0.7) + (rawTilt * 0.3);

      if (_filteredTilt.abs() < 0.02) return;

      double speed = _filteredTilt * _filteredTilt * _speedFactor * _filteredTilt.sign;
      speed *= 1.3;

      double newX = (_blackHoleX + speed).clamp(0.0, 1.0);
      _blackHoleX = lerpDouble(_blackHoleX, newX, 0.4)!;

      setState(() {
        _actualLeft = _blackHoleX * (_screenWidth - _blackHoleSize);
      });
    });
  }


  void _startGameLoop() {
    _spawnTimer?.cancel();
    _moveTimer?.cancel();

    _spawnTimer = Timer.periodic(const Duration(milliseconds: 650), (_) {
      if (!_isGameOver && !_isWin && !_isDialogVisible) {
        setState(() {
          _stars.add(Star(
            x: _random.nextDouble(),
            y: 0,
            // Kecepatan dikurangi agar lebih mudah dimainkan
            speed: 0.003 + _random.nextDouble() * 0.005, 
          ));
        });
      }
    });

    _moveTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_isGameOver && !_isWin && !_isDialogVisible) {
        setState(() => _updateStars());
      }
    });
  }


  void _updateStars() {
    List<Star> remaining = [];
    for (var star in _stars) {
      star.y += star.speed;

      double starLeft = star.x * (_screenWidth - _starSize);
      double starTop = star.y * (_screenHeight - _starSize);
      double blackLeft = _actualLeft;
      double blackTop = _screenHeight - _blackHoleSize - 100; 

      bool hit = (starLeft < blackLeft + _blackHoleSize &&
          starLeft + _starSize > blackLeft &&
          starTop < blackTop + _blackHoleSize &&
          starTop + _starSize > blackTop);

      if (hit) {
        _score++;
        if (_score >= _winScore) {
          _isWin = true;
          _stopGame();
          _isDialogVisible = true;
        }
        continue;
      }

      if (star.y >= 1.0) {
        _lives--;
        if (_lives <= 0) {
          _isGameOver = true;
          _stopGame();
          _isDialogVisible = true;
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
  }

  void _resetToStart() {
    setState(() {
      _isGameStarted = false;
      _isDialogVisible = true;
      _stars.clear();
    });
  }

  @override
  void dispose() {
    _stopGame();
    super.dispose();
  }

  Widget _buildOverlayDialog() {
    String title = !_isGameStarted 
        ? '🕳️ BLACK HOLE GAME 🕳️' 
        : (_isWin ? '🌟 MENANG!' : '💀 GAME OVER');
    
    String content = !_isGameStarted ? _fact : 'Skor Anda: $_score';

    return Container(
      color: Colors.black.withOpacity(0.7), // Background redup
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: Container(
        width: _screenWidth * 0.8,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.solarGold.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Text(content, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_isGameStarted)
                  TextButton(
                    onPressed: _resetToStart,
                    child: const Text('MENU', style: TextStyle(color: Colors.white54)),
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.solarGold),
                  onPressed: _startGame,
                  child: Text(!_isGameStarted ? 'MULAI' : 'MAIN LAGI', style: const TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar dari MediaQuery
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AstroAppBar(title: ' Black Hole Game'),
      body: Stack(
        children: [
          // 1. Background dan Game Area
          StarBackground(
            child: Stack(
              children: [
                // Bintang
                for (var star in _stars)
                  Positioned(
                    left: star.x * (_screenWidth - _starSize),
                    top: star.y * (_screenHeight - _starSize),
                    child: const Icon(Icons.star, color: AppTheme.solarGold, size: _starSize),
                  ),

                // Black Hole
                Positioned(
                  left: _actualLeft,
                  bottom: 20,
                  child: Image.asset(
                    'assets/images/blackhole.png',
                    width: _blackHoleSize,
                    height: _blackHoleSize,
                  ),
                ),
                
                // Score & Lives UI (Opsional di dalam game)
                if (_isGameStarted && !_isDialogVisible)
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Text('Score: $_score  |  Lives: $_lives', 
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),

          // 2. Overlay Dialog (Hanya muncul jika _isDialogVisible true)
          if (_isDialogVisible) _buildOverlayDialog(),
        ],
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