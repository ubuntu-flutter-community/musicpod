import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app_config.dart';
import 'theme.dart';

class ActiveAudioSignalIndicator extends StatefulWidget {
  final Color? color;
  final double thickness;

  const ActiveAudioSignalIndicator({
    this.color,
    this.thickness = 2.0,
    super.key,
  });

  @override
  State<ActiveAudioSignalIndicator> createState() =>
      _ActiveAudioSignalIndicatorState();
}

class _ActiveAudioSignalIndicatorState extends State<ActiveAudioSignalIndicator>
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
      child: Padding(
        padding: AppConfig.yaruStyled || AppConfig.appleStyled
            ? const EdgeInsets.only(left: 3, right: 1)
            : const EdgeInsets.only(left: 5),
        child: SizedBox(
          width: iconSize - 2,
          height: iconSize,
          child: AnimatedBuilder(
            animation: Listenable.merge(_controllers),
            builder: (context, _) {
              return CustomPaint(
                painter: _ActiveAudioSignalPainter(
                  animations: _controllers
                      .map(_seq.animate)
                      .map((e) => e.value)
                      .toList(),
                  color: widget.color ?? Theme.of(context).colorScheme.primary,
                  thickness: widget.thickness,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ActiveAudioSignalPainter extends CustomPainter {
  final List<double> animations;
  final Color? color;
  final double thickness;

  const _ActiveAudioSignalPainter({
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
  bool shouldRepaint(covariant _ActiveAudioSignalPainter old) {
    return !listEquals(animations, old.animations) ||
        color != old.color ||
        thickness != old.thickness;
  }
}

// Code by @HrX03
const _kTargetCanvasSize = 24.0;
const _kBarsStartOffsets = [0.2, 0.8, 0.4, 0.6];
const _kDefaultIndicatorThickness = 2.0;

class AudioSignalIndicator extends StatelessWidget {
  const AudioSignalIndicator({
    required this.progress,
    this.color,
    this.size = _kTargetCanvasSize,
    super.key,
  });

  final Animation<double> progress;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final values =
        _kBarsStartOffsets.map((e) => _transform(progress.value, e)).toList();

    return RepaintBoundary(
      child: SizedBox.square(
        dimension: size,
        child: AnimatedBuilder(
          animation: progress,
          builder: (context, _) {
            return CustomPaint(
              painter: _AudioSignalPainter(
                values: values,
                size: size,
                color: color ?? Theme.of(context).colorScheme.onSurface,
                thickness: _kDefaultIndicatorThickness,
              ),
              size: Size.square(size),
            );
          },
        ),
      ),
    );
  }
}

double _transform(double v, [double offset = 0]) {
  return math.acos(math.cos((v + offset / 2) * 2 * math.pi)) / math.pi;
}

class _AudioSignalPainter extends CustomPainter {
  const _AudioSignalPainter({
    required this.values,
    this.size = 24.0,
    this.color,
    this.thickness = 2.0,
  });

  final List<double> values;
  final double size;
  final Color? color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(this.size / _kTargetCanvasSize);

    final inbetweenSpace =
        (_kTargetCanvasSize - thickness) / (values.length - 1);

    for (var i = 0; i < values.length; i++) {
      final dx = (inbetweenSpace * i) + thickness / 2;
      const hh = _kTargetCanvasSize / 2;
      final fraction = values[i];

      canvas.drawLine(
        Offset(dx, hh - (fraction * hh)),
        Offset(dx, hh + (fraction * hh)),
        getBarPaint(),
      );
    }
  }

  Paint getBarPaint() {
    return Paint()
      ..color = color ?? Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
  }

  @override
  bool shouldRepaint(covariant _AudioSignalPainter old) {
    return !listEquals(values, old.values) ||
        color != old.color ||
        thickness != old.thickness;
  }
}
