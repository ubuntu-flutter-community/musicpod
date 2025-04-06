import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import '../../extensions/build_context_x.dart';
import 'theme.dart';

class SideBarProgress extends StatelessWidget {
  const SideBarProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: AppConfig.yaruStyled ? 18 : iconSize,
      child: const Progress(
        strokeWidth: 2,
      ),
    );
  }
}

class Progress extends StatelessWidget {
  const Progress({
    super.key,
    this.value,
    this.backgroundColor,
    this.color,
    this.valueColor,
    this.semanticsLabel,
    this.semanticsValue,
    this.strokeCap,
    this.strokeWidth = 3.0,
    this.padding,
  });

  final double? value;
  final Color? backgroundColor;
  final Color? color;
  final Animation<Color?>? valueColor;
  final double strokeWidth;
  final String? semanticsLabel;
  final String? semanticsValue;
  final StrokeCap? strokeCap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return AppConfig.yaruStyled
        ? YaruCircularProgressIndicator(
            strokeWidth: strokeWidth,
            value: value,
            color: color,
            trackColor: backgroundColor,
          )
        : Padding(
            padding: padding ?? const EdgeInsets.all(4),
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              value: value,
              color: color,
              backgroundColor: value == null
                  ? null
                  : (backgroundColor ??
                      context.theme.colorScheme.primary.withValues(alpha: 0.3)),
            ),
          );
  }
}

class LinearProgress extends StatelessWidget {
  const LinearProgress({
    super.key,
    this.color,
    this.trackHeight,
    this.value,
    this.backgroundColor,
  });

  final double? value;
  final Color? color, backgroundColor;
  final double? trackHeight;

  @override
  Widget build(BuildContext context) {
    return AppConfig.yaruStyled
        ? YaruLinearProgressIndicator(
            value: value,
            strokeWidth: trackHeight,
            color: color,
          )
        : LinearProgressIndicator(
            value: value,
            minHeight: trackHeight,
            color: color,
            backgroundColor: backgroundColor,
            borderRadius: BorderRadius.circular(2),
          );
  }
}
