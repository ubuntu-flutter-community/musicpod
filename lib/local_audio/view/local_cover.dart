import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../extensions/build_context_x.dart';
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
    return SizedBox.square(
      dimension: dimension,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) =>
            FadeTransition(opacity: animation, child: child),
        reverseDuration: const Duration(milliseconds: 200),
        child:
            watchValue(
              (LocalCoverManager m) => m.command.results,
              param1: albumId,
            ).toWidget(
              whileRunning: (lastResult, param) =>
                  loadingWidget ??
                  Container(
                    decoration: BoxDecoration(
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.05,
                      ),
                    ),
                  ),
              onError: (error, lastResult, param) => fallback,
              onNullData: (_) => fallback,
              onData: (result, param) => result == null
                  ? fallback
                  : Image.memory(
                      result,
                      fit: fit,
                      height: dimension,
                      width: dimension,
                      // TODO: understand why the cache dimensions have to be bigger than the actual dimensions
                      // to prevent the image to look blurry. Maybe the image is resized at some point and needs bigger cache dimensions to still look good after resizing?
                      cacheHeight: dimension != double.infinity
                          ? (dimension * 1.4).toInt()
                          : null,
                      cacheWidth: dimension != double.infinity
                          ? (dimension * 1.4).toInt()
                          : null,
                    ),
            ),
      ),
    );
  }
}
