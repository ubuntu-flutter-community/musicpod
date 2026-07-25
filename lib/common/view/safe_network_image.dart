import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../extensions/build_context_x.dart';
import '../logging.dart';
import '../util/failed_image_urls.dart';
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

  @override
  Widget build(BuildContext context) {
    final errorWidget = Center(
      child:
          this.errorWidget ??
          Icon(
            Iconz.imageMissing,
            size: height != null ? height! * 0.7 : null,
            color: context.theme.hintColor,
          ),
    );

    if (url == null ||
        url!.isEmpty ||
        FailedImageUrls.contains(url) ||
        (Uri.tryParse(url!)?.host.isEmpty ?? false))
      return errorWidget;

    return CachedNetworkImage(
      cacheManager: _cacheManager,
      imageUrl: url!,
      height: height,
      width: width,
      memCacheHeight: cacheHeight,
      memCacheWidth: cacheWidth,
      maxWidthDiskCache: cacheWidth,
      maxHeightDiskCache: cacheHeight,
      fit: fit,
      filterQuality: filterQuality,
      httpHeaders: httpHeaders,
      imageBuilder: (context, imageProvider) {
        onImageLoaded?.call(imageProvider);
        return Image(
          image: imageProvider,
          height: height,
          width: width,
          fit: fit,
          filterQuality: filterQuality,
        );
      },
      placeholder: (context, url) =>
          fallbackWidget ??
          Center(
            child: Icon(
              Iconz.musicNote,
              size: height != null ? height! * 0.7 : null,
            ),
          ),
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
        if (url == null || url!.isEmpty) {
          FailedImageUrls.add(url);
        }
        return errorWidget;
      },
    );
  }
}

final _cacheManager = DefaultCacheManager(
  stalePeriod: const Duration(days: 1),
  maxNrOfCacheObjects: 100,
  connectionParameters: ConnectionParameters(
    connectionTimeout: const Duration(seconds: 10),
    requestTimeout: const Duration(seconds: 30),
  ),
);
