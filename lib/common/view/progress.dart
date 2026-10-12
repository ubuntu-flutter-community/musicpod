import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/platform_x.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/manager/settings_manager.dart';

class Progress extends ConsumerWidget {
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
    this.adaptive = true,
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
  final bool adaptive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useYaruTheme =
        ref.watch(settingsBoolManagerProvider(SPKeys.useYaruTheme)) ?? isLinux;
    return useYaruTheme
        ? YaruCircularProgressIndicator(
            strokeWidth: strokeWidth,
            value: value,
            color: color,
            valueColor: valueColor,
            trackColor: backgroundColor,
          )
        : adaptive
        ? CircularProgressIndicator.adaptive(
            strokeWidth: strokeWidth,
            value: value,
            valueColor: valueColor,
            backgroundColor: value == null
                ? null
                : (backgroundColor ??
                      context.theme.colorScheme.primary.withValues(alpha: 0.3)),
          )
        : CircularProgressIndicator(
            strokeWidth: strokeWidth,
            value: value,
            valueColor: valueColor,
            backgroundColor: value == null
                ? null
                : (backgroundColor ??
                      context.theme.colorScheme.primary.withValues(alpha: 0.3)),
          );
  }
}

class LinearProgress extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final useYaruTheme =
        ref.watch(settingsBoolManagerProvider(SPKeys.useYaruTheme)) ?? isLinux;
    return useYaruTheme
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
