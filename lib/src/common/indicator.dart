import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MusicIndicator extends StatefulWidget {
  final Color? color;
  final double thickness;

  const MusicIndicator({
    this.color,
    this.thickness = 2.0,
    super.key,
  });

  @override
  State<MusicIndicator> createState() => _MusicIndicatorState();
}

class _MusicIndicatorState extends State<MusicIndicator>
    with TickerProviderStateMixin {
  static const _delayInMills = [770, 290, 280, 740];
  static const _durationInMills = [1260, 430, 1010, 730];
  static final TweenSequence<double> _seq = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 1),
  ]);

  final List<AnimationController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 4; i++) {
      _controllers.add(
        AnimationController(
          value: _delayInMills[i] / _durationInMills[i],
          vsync: this,
          duration: Duration(milliseconds: _durationInMills[i]),
        ),
      );
      _controllers[i].repeat();
    }
  }

  @override
  void dispose() {
    for (final AnimationController e in _controllers) {
      e.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge(_controllers),
        builder: (context, _) {
          return CustomPaint(
            painter: _MusicIndicatorPainter(
              animations:
                  _controllers.map(_seq.animate).map((e) => e.value).toList(),
              color: widget.color ?? Theme.of(context).colorScheme.primary,
              thickness: widget.thickness,
            ),
          );
        },
      ),
    );
  }
}

class _MusicIndicatorPainter extends CustomPainter {
  final List<double> animations;
  final Color? color;
  final double thickness;

  const _MusicIndicatorPainter({
    required this.animations,
    this.color,
    this.thickness = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < animations.length; i++) {
      final double dx = (size.width - thickness * animations.length) /
              (animations.length - 1) *
              i +
          thickness / 2;

      canvas.drawLine(
        Offset(dx, 0.5 * animations[i] * size.height),
        Offset(dx, size.height - 0.5 * animations[i] * size.height),
        Paint()
          ..color = color ?? Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MusicIndicatorPainter old) {
    return !listEquals(animations, old.animations) ||
        color != old.color ||
        thickness != old.thickness;
  }
}
