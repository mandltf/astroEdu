// lib/views/widgets/star_background.dart
import 'dart:math';
import 'package:flutter/material.dart';

class StarBackground extends StatefulWidget {
  final Widget child;
  final int starCount;
  const StarBackground({super.key, required this.child, this.starCount = 80});

  @override
  State<StarBackground> createState() => _StarBackgroundState();
}

class _StarBackgroundState extends State<StarBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Star> stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    final rand = Random();
    stars = List.generate(widget.starCount, (_) => _Star(rand));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _StarPainter(stars, _controller.value),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _Star {
  final double x, y, size, twinkleOffset;
  _Star(Random rand)
      : x = rand.nextDouble(),
        y = rand.nextDouble(),
        size = rand.nextDouble() * 2 + 0.5,
        twinkleOffset = rand.nextDouble();
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double animValue;
  _StarPainter(this.stars, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final star in stars) {
      final twinkle = sin((animValue + star.twinkleOffset) * pi);
      final opacity = 0.3 + twinkle.abs() * 0.7;
      paint.color = Colors.white.withOpacity(opacity * 0.8);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => true;
}