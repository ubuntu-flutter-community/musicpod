import 'package:flutter/material.dart';

class CoverBackground extends StatelessWidget {
  const CoverBackground({super.key, required this.dimension});

  final double dimension;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8.0),
    child: CustomPaint(
      size: Size(dimension, dimension),
      painter: _CompactDiscPainter(),
    ),
  );
}

class _CompactDiscPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final holeRadius = radius * 0.15;

    // Path constraint with hole
    final cdPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..addOval(Rect.fromCircle(center: center, radius: holeRadius))
      ..fillType = PathFillType.evenOdd;

    canvas.clipPath(cdPath);

    // Outer rim
    final basePaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, basePaint);

    // Data area (shiny gradient)
    final gradientPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.grey.shade400,
          Colors.teal.withValues(alpha: 0.3),
          Colors.purple.withValues(alpha: 0.3),
          Colors.grey.shade400,
          Colors.teal.withValues(alpha: 0.3),
          Colors.purple.withValues(alpha: 0.3),
          Colors.grey.shade400,
        ],
        stops: const [0.0, 0.16, 0.33, 0.5, 0.66, 0.83, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.98, gradientPaint);

    // Inner plastic rim
    final plasticRimPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.35, plasticRimPaint);

    // Inner rim borders
    final strokePaint = Paint()
      ..color = Colors.grey.shade500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.35, strokePaint);
    canvas.drawCircle(center, radius * 0.98, strokePaint);

    // Data rings
    for (double r = radius * 0.45; r < radius * 0.95; r += radius * 0.05) {
      canvas.drawCircle(
        center,
        r,
        strokePaint..color = Colors.grey.withValues(alpha: 0.1),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
