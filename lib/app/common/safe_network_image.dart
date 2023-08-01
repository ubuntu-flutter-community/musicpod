import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';

class SafeNetworkImage extends StatelessWidget {
  const SafeNetworkImage({
    super.key,
    required this.url,
    this.filterQuality = FilterQuality.medium,
    this.fit = BoxFit.fitWidth,
    this.fallBackIcon,
    this.errorIcon,
  });

  final String? url;
  final FilterQuality filterQuality;
  final BoxFit fit;
  final Widget? fallBackIcon;
  final Widget? errorIcon;

  @override
  Widget build(BuildContext context) {
    final fallBack = Center(
      child: fallBackIcon ??
          const Icon(
            YaruIcons.music_note,
            size: 70,
          ),
    );

    final errorWidget = Center(
      child: errorIcon ??
          Icon(
            YaruIcons.image_missing,
            size: 70,
            color: Theme.of(context).hintColor,
          ),
    );

    if (url == null) return fallBack;

    return Image.network(
      url!,
      filterQuality: filterQuality,
      fit: fit,
      frameBuilder: (context, child, frame, wasSyncLoaded) => AnimatedOpacity(
        duration: const Duration(seconds: 1),
        opacity: frame == null ? 0 : 1.0,
        child: child,
      ),
      errorBuilder: (context, url, error) {
        return errorWidget;
      },
    );
  }
}
