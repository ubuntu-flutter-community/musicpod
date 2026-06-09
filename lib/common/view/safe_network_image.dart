import 'package:flutter/material.dart';

import '../../extensions/build_context_x.dart';
import '../logging.dart';
import 'icons.dart';

class SafeNetworkImage extends StatelessWidget {
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

  static final List<String> _failedUrls = [];

  @override
  Widget build(BuildContext context) {
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

    try {
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
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    } on Exception catch (e, s) {
      printErrorInDebugMode(
        'Failed to load image: $url',
        trace: s,
        tag: '$SafeNetworkImage',
      );
      if (url != null) {
        _failedUrls.add(url!);
      }
      return fallBack;
    }
  }
}
