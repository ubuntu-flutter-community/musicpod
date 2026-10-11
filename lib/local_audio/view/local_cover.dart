import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../manager/local_cover_manager.dart';

class LocalCover extends StatelessWidget with WatchItMixin {
  const LocalCover({
    super.key,
    required this.albumId,
    required this.fallback,
    required this.dimension,
    this.loadingWidget,
    this.fit = BoxFit.cover,
  });

  final int albumId;
  final Widget fallback;
  final Widget? loadingWidget;
  final double dimension;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
    const maxDecodeDimension = 1024;
    final cacheDim = dimension.isFinite
        ? (dimension * dpr).round().clamp(1, maxDecodeDimension)
        : maxDecodeDimension;

    final coverBytes = watchValue(
      (LocalCoverManager m) => m.command,
      param1: albumId,
    );
    final isRunning = loadingWidget != null
        ? watchValue(
            (LocalCoverManager m) => m.command.isRunning,
            param1: albumId,
          )
        : false;

    final Widget child;
    if (coverBytes != null) {
      child = Image.memory(
        coverBytes,
        key: const ValueKey('cover_image'),
        fit: fit,
        height: dimension,
        width: dimension,
        cacheHeight: cacheDim,
        cacheWidth: cacheDim,
      );
    } else if (isRunning && loadingWidget != null) {
      child = KeyedSubtree(
        key: const ValueKey('cover_loading'),
        child: loadingWidget!,
      );
    } else {
      child = KeyedSubtree(
        key: const ValueKey('cover_fallback'),
        child: fallback,
      );
    }

    return SizedBox.square(
      dimension: dimension,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) =>
            FadeTransition(opacity: animation, child: child),
        reverseDuration: const Duration(milliseconds: 200),
        child: child,
      ),
    );
  }
}
