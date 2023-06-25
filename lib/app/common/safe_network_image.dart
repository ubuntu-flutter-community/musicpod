import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yaru_icons/yaru_icons.dart';

class SafeNetworkImage extends StatelessWidget {
  const SafeNetworkImage({
    super.key,
    required this.url,
    this.filterQuality = FilterQuality.medium,
    this.fit = BoxFit.fitHeight,
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
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;

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
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: light ? kShimmerBaseLight : kShimmerBaseDark,
        highlightColor: light ? kShimmerHighLightLight : kShimmerHighLightDark,
        child: Container(
          color: light ? kShimmerBaseLight : kShimmerBaseDark,
          height: 250,
          width: 250,
        ),
      ),
      errorWidget: (context, url, error) {
        return errorIcon ??
            Icon(
              YaruIcons.image_missing,
              size: 60,
              color: Theme.of(context).hintColor,
            );
      },
    );
  }
}
