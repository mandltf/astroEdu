// lib/views/screens/game/catch_star_game.dart
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
  late double _screenWidth;
  late double _screenHeight;
  static const double _blackHoleSize = 90.0;
  static const double _starSize = 32.0;
  static const double _speedFactor = 0.25; // Semakin besar, semakin cepat respon

  double _blackHoleX = 0.5;
  double _actualLeft = 0.0;

  List<Star> _stars = [];

  int _score = 0;
  int _lives = 5;
  bool _isGameOver = false;
  bool _isGameStarted = false;

  Timer? _spawnTimer;
  Timer? _moveTimer;
  StreamSubscription<AccelerometerEvent>? _accelerometerSub;

  final Random _random = Random();

  final String _blackHoleFact =
      "🕳️ Lubang hitam memiliki gravitasi sangat kuat sehingga "
      "bintang pun bisa 'dimakan'! Ketika bintang terlalu dekat, "
      "materialnya tersedot dan menghasilkan semburan energi dahsyat. "
      "Sekarang, kamu jadi lubang hitam. Miringkan HP untuk menangkap bintang jatuh!";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showStartDialog();
      }
    });
  }

  Future<void> _showStartDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.opacity, color: AppTheme.solarGold, size: 32),
            SizedBox(width: 12),
            Text('BLACK HOLE GAME', style: TextStyle(color: AppTheme.starlight, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚡ Fakta Menarik:',
              style: TextStyle(color: AppTheme.auroraBlue, fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              _blackHoleFact,
              style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppTheme.cardBorder),
            const SizedBox(height: 8),
            const Text(
              '🎮 Cara Main:\nMiringkan HP ke kiri/kanan untuk menggerakkan lubang hitam.\nSemakin miring, semakin cepat geraknya!\nTangkap bintang jatuh sebelum menyentuh tanah!',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('MULAI GAME', style: TextStyle(color: AppTheme.auroraBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _startGame() {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    
    setState(() {
      _isGameStarted = true;
      _isGameOver = false;
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
      if (_isGameOver || !mounted) return;
      
      // event.x: nilai -9.8 (miring kiri maks) sampai +9.8 (miring kanan maks)
      // Normalisasi ke -1..1
      double tilt = event.x / 9.8;
      tilt = tilt.clamp(-1.0, 1.0);
      
      // Kecepatan gerak = kemiringan × speedFactor
      // Semakin besar kemiringan (mendekati ±1), semakin cepat gerak
      double speed = tilt * _speedFactor;
      
      // Update posisi blackhole
      double newX = (_blackHoleX + speed).clamp(0.0, 1.0);
      
      setState(() {
        _blackHoleX = newX;
        _actualLeft = _blackHoleX * (_screenWidth - _blackHoleSize);
      });
    }, onError: (error) {
      print('Sensor error: $error');
    });
  }

  void _startGameLoop() {
    _spawnTimer?.cancel();
    _moveTimer?.cancel();

    _spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!_isGameOver && mounted) {
        setState(() {
          _stars.add(Star(
            x: _random.nextDouble(),
            y: 0.0,
            speed: 0.004 + _random.nextDouble() * 0.01,
          ));
        });
      }
    });

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

      double starLeft = star.x * (_screenWidth - _starSize);
      double starTop = star.y * (_screenHeight - _starSize);
      double blackLeft = _actualLeft;
      double blackTop = _screenHeight - _blackHoleSize - 20;
      double blackRight = blackLeft + _blackHoleSize;
      double starRight = starLeft + _starSize;

      bool isColliding = (starRight > blackLeft && 
                          starLeft < blackRight && 
                          starTop + _starSize > blackTop && 
                          starTop < blackTop + _blackHoleSize);

      if (isColliding) {
        _score++;
        continue;
      }
      else if (star.y >= 1.0) {
        _lives--;
        if (_lives <= 0) {
          _isGameOver = true;
          _stopGame();
          if (mounted) _showGameOverDialog();
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

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('💀 GAME OVER', style: TextStyle(color: AppTheme.marsRed, fontWeight: FontWeight.bold)),
        content: Text('Skor akhir: $_score\nBintang yang tertangkap: $_score', style: const TextStyle(color: AppTheme.starlight)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Kembali', style: TextStyle(color: AppTheme.auroraBlue)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetAndStart();
            },
            child: const Text('Main Lagi'),
          ),
        ],
      ),
    );
  }

  void _resetAndStart() {
    _stopGame();
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    
    setState(() {
      _stars.clear();
      _score = 0;
      _lives = 5;
      _isGameOver = false;
      _isGameStarted = true;
      _blackHoleX = 0.5;
      _actualLeft = _blackHoleX * (_screenWidth - _blackHoleSize);
    });
    _startSensors();
    _startGameLoop();
  }

  @override
  void dispose() {
    _stopGame();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    
    if (_actualLeft == 0 && _blackHoleX != 0) {
      _actualLeft = _blackHoleX * (_screenWidth - _blackHoleSize);
    }

    if (!_isGameStarted) {
      return Scaffold(
        appBar: AstroAppBar(title: '🎮 Black Hole Game'),
        body: StarBackground(
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AstroAppBar(title: '🎮 Black Hole Game'),
      body: StarBackground(
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('⭐ Skor: $_score', style: const TextStyle(color: AppTheme.solarGold, fontSize: 16)),
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
                  children: List.generate(_lives, (index) => const Icon(Icons.favorite, color: AppTheme.marsRed, size: 18)),
                ),
              ),
            ),
            for (var star in _stars)
              Positioned(
                left: star.x * (_screenWidth - _starSize),
                top: star.y * (_screenHeight - _starSize),
                child: const Icon(Icons.star, color: AppTheme.solarGold, size: _starSize),
              ),
            Positioned(
              left: _actualLeft,
              bottom: 20,
              child: Image.asset(
                'assets/images/blackhole.png',
                width: _blackHoleSize,
                height: _blackHoleSize,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: _blackHoleSize,
                    height: _blackHoleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Colors.black, AppTheme.cosmicPurple],
                        center: Alignment.center,
                        radius: 0.8,
                      ),
                    ),
                    child: const Center(child: Icon(Icons.circle, color: Colors.white24, size: 40)),
                  );
                },
              ),
            ),
            Positioned(
              bottom: _blackHoleSize + 30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.deepSpace.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Miringkan HP - semakin miring semakin cepat',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ),
              ),
            ),
          ],
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