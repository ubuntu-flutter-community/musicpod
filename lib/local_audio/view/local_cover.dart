import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../manager/local_cover_manager.dart';

class LocalCover extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
    const maxDecodeDimension = 1024;
    final cacheDim = dimension.isFinite
        ? (dimension * dpr).round().clamp(1, maxDecodeDimension)
        : maxDecodeDimension;

    return SizedBox.square(
      dimension: dimension,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) =>
            FadeTransition(opacity: animation, child: child),
        reverseDuration: const Duration(milliseconds: 200),
        child: ref
            .watch(localCoverManagerProvider(albumId))
            .when(
              data: (coverBytes) => coverBytes != null
                  ? Image.memory(
                      coverBytes,
                      key: const ValueKey('cover_image'),
                      fit: fit,
                      height: dimension,
                      width: dimension,
                      cacheHeight: cacheDim,
                      cacheWidth: cacheDim,
                    )
                  : KeyedSubtree(
                      key: const ValueKey('cover_fallback'),
                      child: fallback,
                    ),
              loading: () => KeyedSubtree(
                key: const ValueKey('cover_loading'),
                child: loadingWidget ?? fallback,
              ),
              error: (_, __) => KeyedSubtree(
                key: const ValueKey('cover_error'),
                child: fallback,
              ),
            ),
      ),
    );
  }
}
