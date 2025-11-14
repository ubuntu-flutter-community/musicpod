import 'package:flutter/material.dart';
import 'package:phoenix_theme/phoenix_theme.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/safe_network_image.dart';
import '../../extensions/build_context_x.dart';
import '../player_model.dart';

class PlayerRemoteSourceImage extends StatelessWidget with WatchItMixin {
  const PlayerRemoteSourceImage({
    super.key,
    required this.height,
    required this.width,
    required this.fit,
    required this.fallBackIcon,
    required this.errorIcon,
  });

  final double height;
  final double width;
  final BoxFit? fit;
  final Widget fallBackIcon;
  final Widget errorIcon;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      color: theme.cardColor.scale(lightness: theme.isLight ? -0.15 : 0.3),
      height: height,
      width: width,
      child: SafeNetworkImage(
        onImageLoaded: di<PlayerModel>().setRemoteColorFromImageProvider,
        url: watchPropertyValue((PlayerModel m) => m.remoteImageUrl),
        filterQuality: FilterQuality.medium,
        fit: fit ?? BoxFit.scaleDown,
        fallBackIcon: fallBackIcon,
        errorIcon: errorIcon,
        height: height,
        width: width,
      ),
    );
  }
}
