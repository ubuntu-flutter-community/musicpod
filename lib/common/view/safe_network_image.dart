import 'dart:async';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../extensions/build_context_x.dart';
import '../logging.dart';
import '../util/failed_image_urls.dart';
import 'icons.dart';

class SafeNetworkImage extends StatefulWidget {
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
  State<SafeNetworkImage> createState() => _SafeNetworkImageState();
}

class _SafeNetworkImageState extends State<SafeNetworkImage> {
  int _retryAttempt = 0;
  Timer? _retryTimer;

  @override
  void didUpdateWidget(covariant SafeNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _retryTimer?.cancel();
      _retryTimer = null;
      _retryAttempt = 0;
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _scheduleRetry({required Duration delay, bool resetFailedUrl = false}) {
    if (_retryTimer?.isActive == true) return;
    _retryTimer = Timer(delay, () {
      if (!mounted) return;
      final url = widget.url;
      if (url != null && url.isNotEmpty) {
        PaintingBinding.instance.imageCache.evict(
          CachedNetworkImageProvider(url, cacheManager: _cacheManager),
        );
        if (resetFailedUrl) {
          FailedImageUrls.remove(url);
        }
      }
      setState(() {
        _retryAttempt++;
        _retryTimer = null;
      });
    });
  }

  void _handleError(String? url, Object error) {
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
      reportType: widget.logType,
    );

    if (url != null && url.isNotEmpty) {
      FailedImageUrls.add(url);

      if (!FailedImageUrls.contains(url)) {
        // Transient error: retry with short backoff (e.g., 3s, then 8s)
        final delay = _retryAttempt == 0
            ? const Duration(seconds: 3)
            : const Duration(seconds: 8);
        _scheduleRetry(delay: delay);
      } else {
        // Exceeded max failures: retry after cooldown so persistent widgets recover
        _scheduleRetry(delay: FailedImageUrls.cooldown, resetFailedUrl: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorWidget = Center(
      child:
          widget.errorWidget ??
          Icon(
            Iconz.imageMissing,
            size: widget.height != null ? widget.height! * 0.7 : null,
            color: context.theme.hintColor,
          ),
    );

    final url = widget.url;
    if (url == null ||
        url.isEmpty ||
        FailedImageUrls.contains(url) ||
        (Uri.tryParse(url)?.host.isEmpty ?? false)) {
      if (url != null &&
          url.isNotEmpty &&
          FailedImageUrls.contains(url) &&
          _retryTimer == null) {
        _scheduleRetry(delay: FailedImageUrls.cooldown, resetFailedUrl: true);
      }
      return errorWidget;
    }

    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
    const maxDecodeDimension = 1024;

    final effectiveWidth =
        widget.width ??
        (widget.fit == BoxFit.cover ||
                widget.fit == BoxFit.fill ||
                widget.fit == BoxFit.fitHeight
            ? widget.height
            : null);
    final effectiveHeight =
        widget.height ??
        (widget.fit == BoxFit.cover ||
                widget.fit == BoxFit.fill ||
                widget.fit == BoxFit.fitWidth
            ? widget.width
            : null);

    final int? calculatedCacheWidth = effectiveWidth != null
        ? (effectiveWidth * dpr).round()
        : null;
    final int? calculatedCacheHeight = effectiveHeight != null
        ? (effectiveHeight * dpr).round()
        : null;

    final int? effectiveCacheWidth = (widget.cacheWidth ?? calculatedCacheWidth)
        ?.clamp(1, maxDecodeDimension);
    final int? effectiveCacheHeight =
        (widget.cacheHeight ?? calculatedCacheHeight)?.clamp(
          1,
          maxDecodeDimension,
        );

    final memWidth =
        effectiveCacheWidth ??
        (effectiveCacheHeight == null ? maxDecodeDimension : null);
    final memHeight =
        effectiveCacheHeight ??
        (effectiveCacheWidth == null ? maxDecodeDimension : null);

    return CachedNetworkImage(
      key: ValueKey('${url}_$_retryAttempt'),
      cacheManager: _cacheManager,
      imageUrl: url,
      height: widget.height,
      width: widget.width,
      memCacheHeight: memHeight,
      memCacheWidth: memWidth,
      maxWidthDiskCache: maxDecodeDimension,
      maxHeightDiskCache: maxDecodeDimension,
      fit: widget.fit,
      filterQuality: widget.filterQuality,
      httpHeaders: widget.httpHeaders,
      imageBuilder: (context, imageProvider) {
        widget.onImageLoaded?.call(imageProvider);
        return Image(
          image: imageProvider,
          height: widget.height,
          width: widget.width,
          fit: widget.fit,
          filterQuality: widget.filterQuality,
        );
      },
      placeholder: (context, url) =>
          widget.fallbackWidget ??
          Center(
            child: Icon(
              Iconz.musicNote,
              size: widget.height != null ? widget.height! * 0.7 : null,
            ),
          ),
      errorBuilder: (context, error, _) {
        _handleError(url, error);
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
