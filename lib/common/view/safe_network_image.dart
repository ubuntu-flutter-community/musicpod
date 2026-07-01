import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../extensions/build_context_x.dart';
import '../logging.dart';
import 'icons.dart';

class SafeNetworkImage extends StatelessWidget with WatchItMixin {
  const SafeNetworkImage({
    super.key,
    required this.url,
    this.filterQuality = FilterQuality.medium,
    this.fit = BoxFit.fitWidth,
    this.fallbackWidget,
    this.errorWidget,
    this.height,
    this.width,
    this.httpHeaders,
    this.onImageLoaded,
    this.cacheHeight,
    this.cacheWidth,
    this.logType = ReportType.warning,
  });

  final String? url;
  final FilterQuality filterQuality;
  final BoxFit fit;
  final Widget? fallbackWidget;
  final Widget? errorWidget;
  final double? height;
  final double? width;
  final int? cacheHeight;
  final int? cacheWidth;
  final Map<String, String>? httpHeaders;
  final Function(ImageProvider imageProvider)? onImageLoaded;
  final ReportType logType;

  static final List<String> _failedUrls = [];

  @override
  Widget build(BuildContext context) {
    onDispose(() {
      if (url != null) {
        final imageCache2 = PaintingBinding.instance.imageCache;

        if (imageCache2.containsKey(NetworkImage(url!)) ||
            imageCache2.containsKey(url!)) {
          Logger.i('Evicting image from cache: $url', tag: '$SafeNetworkImage');
          imageCache2.evict(NetworkImage(url!));
          imageCache2.evict(url!);
        }
      }
    });

    final fallBack = Center(
      child:
          fallbackWidget ??
          Icon(Iconz.musicNote, size: height != null ? height! * 0.7 : null),
    );

    if (url == null ||
        url!.isEmpty ||
        _failedUrls.contains(url!) ||
        (Uri.tryParse(url!)?.host.isEmpty ?? false))
      return fallBack;

    final errorWidget = Center(
      child:
          this.errorWidget ??
          Icon(
            Iconz.imageMissing,
            size: height != null ? height! * 0.7 : null,
            color: context.theme.hintColor,
          ),
    );

    return Image.network(
      url!,
      height: height,
      width: width,
      cacheHeight: cacheHeight,
      cacheWidth: cacheWidth,
      fit: fit,
      filterQuality: filterQuality,
      headers: httpHeaders,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (frame != null) {
          onImageLoaded?.call(NetworkImage(url!));
        }
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: child,
        );
      },
      errorBuilder: (context, error, _) {
        final message = switch (error.runtimeType) {
          final NetworkImageLoadException e => switch (e.statusCode) {
            403 => 'Access forbidden to the resource.',
            404 => 'Resource not found at $url.',
            500 => 'Server error occurred while fetching the image.',
            _ => 'Failed to load image: HTTP ${e.statusCode}.',
          },
          _ => 'Unknown error occurred: $error',
        };
        Logger.r(
          'Failed to load image: $url, error: $message',
          trace: null,
          tag: '$SafeNetworkImage',
          reportType: logType,
        );
        if (url != null) {
          _failedUrls.add(url!);
        }
        return errorWidget;
      },
    );
  }
}
