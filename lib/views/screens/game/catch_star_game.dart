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

  static const double _blackHoleSize = 130.0;
  static const double _starSize = 32.0;
  static const double _speedFactor = 2.2; // 🔥 Lebih cepat
  static const int _winScore = 20;

  double _blackHoleX = 0.5;
  double _actualLeft = 0.0;

  List<Star> _stars = [];

  int _score = 0;
  int _lives = 5;

  bool _isGameStarted = false;
  bool _dialogShown = false;
  bool _isGameOver = false;
  bool _isWin = false;

  Timer? _spawnTimer;
  Timer? _moveTimer;
  StreamSubscription<AccelerometerEvent>? _accelerometerSub;

  final Random _random = Random();
  double _filteredTilt = 0;

  final String _fact =
    "🕳️ Lubang hitam memiliki gravitasi sangat kuat sehingga "
    "bintang pun bisa 'dimakan'! Ketika bintang terlalu dekat, "
    "materialnya tersedot dan menghasilkan semburan energi dahsyat. "
    "Sekarang, kamu jadi lubang hitam. Miringkan HP untuk menangkap bintang jatuh!";

  @override
  void initState() {
    super.initState();
    _dialogShown = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_dialogShown && !_isGameStarted && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_dialogShown && !_isGameStarted) {
          _showStartDialog();
        }
      });
    }
  }

  Future<void> _showStartDialog() async {
    _dialogShown = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false, // 🔥 Biar navbar tetap aktif
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.opacity, color: AppTheme.solarGold, size: 28),
            SizedBox(width: 10),
            Text('BLACK HOLE GAME', style: TextStyle(color: AppTheme.starlight, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚡ Fakta Menarik:',
              style: TextStyle(color: AppTheme.auroraBlue, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _fact,
              style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13, height: 1.4),
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
      _isWin = false;
      _score = 0;
      _lives = 5;
      _stars.clear();
      _blackHoleX = 0.5;
      _actualLeft = _blackHoleX * (_screenWidth - _blackHoleSize);
      _filteredTilt = 0;
    });

    _startSensors();
    _startGameLoop();
  }

  void _startSensors() {
    _accelerometerSub?.cancel();

    _accelerometerSub = accelerometerEvents.listen((event) {
      if (_isGameOver || _isWin || !mounted) return;

      double rawTilt = event.x / 9.8;
      rawTilt = rawTilt.clamp(-1.0, 1.0);
      
      _filteredTilt = _filteredTilt * 0.6 + rawTilt * 0.4;
      
      if (_filteredTilt.abs() < 0.03) return;
      
      // 🔥 Perbaikan: gunakan pow() dari dart:math
      double absTilt = _filteredTilt.abs();
      double signTilt = _filteredTilt.sign;
      double speed = pow(absTilt, 1.5).toDouble() * signTilt * _speedFactor;
      
      double newX = (_blackHoleX + speed).clamp(0.0, 1.0);
      
      _blackHoleX = _blackHoleX * 0.5 + newX * 0.5;
      
      setState(() {
        _actualLeft = _blackHoleX * (_screenWidth - _blackHoleSize);
      });
    }, onError: (error) {
      print('Sensor error: $error');
    });
  }

  void _startGameLoop() {
    _spawnTimer?.cancel();
    _moveTimer?.cancel();

    _spawnTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!_isGameOver && !_isWin && mounted) {
        setState(() {
          _stars.add(Star(
            x: _random.nextDouble(),
            y: 0.0,
            speed: 0.008 + _random.nextDouble() * 0.012,
          ));
        });
      }
    });

    _moveTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!_isGameOver && !_isWin && mounted) {
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

      // Deteksi tabrakan yang lebih akurat
      bool isColliding = (starRight > blackLeft &&
                          starLeft < blackRight &&
                          starTop + _starSize > blackTop &&
                          starTop < blackTop + _blackHoleSize);

      if (isColliding) {
        _score++;
        if (_score >= _winScore) {
          _isWin = true;
          _stopGame();
          if (mounted) _showEndDialog(true);
        }
        continue;
      }
      else if (star.y >= 1.0) {
        _lives--;
        if (_lives <= 0) {
          _isGameOver = true;
          _stopGame();
          if (mounted) _showEndDialog(false);
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

  void _showEndDialog(bool win) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false, // 🔥 Biar navbar tetap aktif
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(win ? Icons.emoji_events : Icons.sentiment_very_dissatisfied, 
                color: win ? AppTheme.solarGold : AppTheme.marsRed, size: 32),
            const SizedBox(width: 10),
            Text(
              win ? '🌟 YOU WIN!' : '💀 GAME OVER',
              style: TextStyle(color: win ? AppTheme.solarGold : AppTheme.marsRed, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Skor akhir: $_score', style: const TextStyle(color: AppTheme.starlight, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              win ? 'Selamat! Kamu berhasil menangkap $_winScore bintang!' : 'Kamu kehabisan nyawa. Coba lagi!',
              style: const TextStyle(color: Color(0xFF9CA3AF)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Kembali ke home
            },
            child: const Text('Kembali', style: TextStyle(color: AppTheme.auroraBlue)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('Main Lagi'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    _stopGame();
    
    setState(() {
      _stars.clear();
      _score = 0;
      _lives = 5;
      _isGameOver = false;
      _isWin = false;
      _isGameStarted = false;
      _dialogShown = false;
      _blackHoleX = 0.5;
      _filteredTilt = 0;
    });
    
    // Tampilkan dialog awal lagi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_dialogShown) {
        _showStartDialog();
      }
    });
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
            // Skor
            Positioned(
              top: 20,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('⭐ Skor: $_score / $_winScore', 
                    style: const TextStyle(color: AppTheme.solarGold, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            // Nyawa
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
                  children: List.generate(_lives, (index) => 
                    const Icon(Icons.favorite, color: AppTheme.marsRed, size: 18)),
                ),
              ),
            ),
            // Progress bar
            Positioned(
              top: 60,
              left: 16,
              right: 16,
              child: LinearProgressIndicator(
                value: _score / _winScore,
                backgroundColor: AppTheme.cardBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.solarGold),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Bintang jatuh
            for (var star in _stars)
              Positioned(
                left: star.x * (_screenWidth - _starSize),
                top: star.y * (_screenHeight - _starSize),
                child: const Icon(Icons.star, color: AppTheme.solarGold, size: _starSize),
              ),
            // Black hole
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
            // Petunjuk berbentuk tooltip kecil
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
                    'Miringkan HP untuk menggerakkan lubang hitam',
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