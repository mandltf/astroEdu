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

  static const double _blackHoleSize = 140.0; // 🔥 lebih besar
  static const double _starSize = 32.0;
  static const double _speedFactor = 1.2;
  static const int _winScore = 10;

  double _blackHoleX = 0.5;
  double _actualLeft = 0.0;

  List<Star> _stars = [];

  int _score = 0;
  int _lives = 5;
  bool _isGameOver = false;
  bool _isWin = false;
  bool _isGameStarted = false;
  bool _dialogShown = false;

  Timer? _spawnTimer;
  Timer? _moveTimer;
  StreamSubscription<AccelerometerEvent>? _accelerometerSub;

  final Random _random = Random();

  double _filteredTilt = 0; // 🔥 smoothing sensor

  final String _blackHoleFact =
      "🕳️ Lubang hitam bisa 'memakan' bintang! Sekarang kamu jadi black hole—tangkap bintang jatuh!";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (mounted &&
        !_dialogShown &&
        !_isGameStarted &&
        ModalRoute.of(context)?.isCurrent == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showStartDialog();
      });
    }
  }

  Future<void> _showStartDialog() async {
    _dialogShown = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: const Text('🕳️ BLACK HOLE GAME'),
        content: Text(_blackHoleFact),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('MULAI'),
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
    });

    _startSensors();
    _startGameLoop();
  }

  void _startSensors() {
    _accelerometerSub?.cancel();

    _accelerometerSub = accelerometerEvents.listen((event) {
      if (_isGameOver || _isWin) return;

      // 🔥 balik arah + normalize
      double rawTilt = -event.x / 9.8;

      // 🔥 low pass filter (biar smooth)
      _filteredTilt = (_filteredTilt * 0.8) + (rawTilt * 0.2);

      // deadzone
      if (_filteredTilt.abs() < 0.03) return;

      // non-linear speed
      double speed =
          _filteredTilt * _filteredTilt * _speedFactor * _filteredTilt.sign;

      double newX = (_blackHoleX + speed).clamp(0.0, 1.0);

      // 🔥 LERP smoothing
      _blackHoleX = lerpDouble(_blackHoleX, newX, 0.25)!;

      setState(() {
        _actualLeft =
            _blackHoleX * (_screenWidth - _blackHoleSize);
      });
    });
  }

  void _startGameLoop() {
    _spawnTimer?.cancel();
    _moveTimer?.cancel();

    _spawnTimer =
        Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (!_isGameOver && !_isWin) {
        setState(() {
          _stars.add(Star(
            x: _random.nextDouble(),
            y: 0,
            speed: 0.006 + _random.nextDouble() * 0.01,
          ));
        });
      }
    });

    _moveTimer =
        Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_isGameOver && !_isWin) {
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
      double blackTop = _screenHeight - _blackHoleSize - 20;

      bool hit =
          (starLeft < blackLeft + _blackHoleSize &&
              starLeft + _starSize > blackLeft &&
              starTop < blackTop + _blackHoleSize &&
              starTop + _starSize > blackTop);

      if (hit) {
        _score++;

        if (_score >= _winScore) {
          _isWin = true;
          _stopGame();
          _showEndDialog(true);
        }
        continue;
      }

      if (star.y >= 1.0) {
        _lives--;
        if (_lives <= 0) {
          _isGameOver = true;
          _stopGame();
          _showEndDialog(false);
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
      builder: (_) => AlertDialog(
        title: Text(win ? '🌟 MENANG!' : '💀 GAME OVER'),
        content: Text('Skor: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetToStart(); // 🔥 balik ke dialog awal
            },
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('Main Lagi'),
          ),
        ],
      ),
    );
  }

  void _resetToStart() {
    setState(() {
      _isGameStarted = false;
      _dialogShown = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showStartDialog();
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

    if (!_isGameStarted) {
      return Scaffold(
        appBar: AstroAppBar(title: '🎮 Black Hole Game'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AstroAppBar(title: '🎮 Black Hole Game'),
      body: StarBackground(
        child: Stack(
          children: [
            for (var star in _stars)
              Positioned(
                left: star.x * (_screenWidth - _starSize),
                top: star.y * (_screenHeight - _starSize),
                child: const Icon(Icons.star,
                    color: AppTheme.solarGold, size: _starSize),
              ),

            Positioned(
              left: _actualLeft,
              bottom: 20,
              child: Image.asset(
                'assets/images/blackhole.png',
                width: _blackHoleSize,
                height: _blackHoleSize,
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