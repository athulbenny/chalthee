import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;

class RainLoader extends StatefulWidget {
  const RainLoader({super.key});

  @override
  State<RainLoader> createState() => _RainLoaderState();
}

class _RainLoaderState extends State<RainLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final Random random = Random();

  final int dropCount = 35;
  final List<_Drop> drops = [];

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..addListener(() {
      setState(() {});
    });

    controller.repeat();
  }

  void initializeDrops(Size size) {
    if (drops.isNotEmpty) return;

    for (int i = 0; i < dropCount; i++) {
      drops.add(
        _Drop(
          position: vmath.Vector2(
            random.nextDouble() * size.width,
            random.nextDouble() * size.height,
          ),
          speed: 4 + random.nextDouble() * 6,
          size: 6 + random.nextDouble() * 6,
        ),
      );
    }
  }

  void updateDrops(Size size) {
    for (var drop in drops) {
      drop.position.y += drop.speed;

      if (drop.position.y > size.height) {
        drop.position.y = -20;
        drop.position.x = random.nextDouble() * size.width;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (_, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          initializeDrops(size);
          updateDrops(size);

          return CustomPaint(
            painter: _RainPainter(drops),
            size: size,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _Drop {
  vmath.Vector2 position;
  double speed;
  double size;

  _Drop({
    required this.position,
    required this.speed,
    required this.size,
  });
}

class _RainPainter extends CustomPainter {
  final List<_Drop> drops;

  _RainPainter(this.drops);

  @override
  void paint(Canvas canvas, Size size) {
    for (var drop in drops) {
      drawDrop(canvas, drop);
    }
  }

  void drawDrop(Canvas canvas, _Drop drop) {
    final pos = drop.position;
    final radius = drop.size;

    final paint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF81D4FA),
          Color(0xFF0288D1),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(pos.x, pos.y),
          radius: radius,
        ),
      );

    final path = Path();

    path.moveTo(pos.x, pos.y - radius);

    path.quadraticBezierTo(
      pos.x - radius,
      pos.y,
      pos.x - radius * 0.4,
      pos.y + radius,
    );

    path.quadraticBezierTo(
      pos.x,
      pos.y + radius * 1.4,
      pos.x + radius * 0.4,
      pos.y + radius,
    );

    path.quadraticBezierTo(
      pos.x + radius,
      pos.y,
      pos.x,
      pos.y - radius,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}