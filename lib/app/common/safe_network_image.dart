import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';

class SafeNetworkImage extends StatelessWidget {
  const SafeNetworkImage({
    super.key,
    required this.url,
    this.filterQuality = FilterQuality.medium,
    this.fit = BoxFit.fitHeight,
    this.fallBackIcon,
  });

  final String? url;
  final FilterQuality filterQuality;
  final BoxFit fit;
  final Widget? fallBackIcon;

  @override
  Widget build(BuildContext context) {
    final fallBack = fallBackIcon ??
        Icon(
          YaruIcons.music_note,
          size: 60,
          color: Theme.of(context).hintColor,
        );
    if (url == null) return fallBack;

    return CachedNetworkImage(
      imageUrl: url!,
      imageBuilder: (context, imageProvider) => Image(
        image: imageProvider,
        filterQuality: filterQuality,
        fit: fit,
      ),
      placeholder: (context, url) => fallBack,
      errorWidget: (context, url, _) => fallBack,
    );
  }
}
