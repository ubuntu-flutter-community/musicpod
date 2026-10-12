import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoenix_theme/phoenix_theme.dart';

import '../../common/view/safe_network_image.dart';
import '../../extensions/build_context_x.dart';
import '../manager/current_audio_manager.dart';
import '../manager/player_color_manager.dart';

class PlayerRemoteSourceImage extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    final remoteImageUrl = ref.watch(
      currentAudioManagerProvider.select((a) => a?.imageUrl ?? a?.albumArtUrl),
    );

    return Container(
      color: theme.cardColor.scale(lightness: theme.isLight ? -0.15 : 0.3),
      height: height,
      width: width,
      child: remoteImageUrl == null
          ? fallBackIcon
          : SafeNetworkImage(
              onImageLoaded: ref
                  .read(playerColorManagerProvider.notifier)
                  .setRemoteColorFromImageProvider,
              url: remoteImageUrl,
              filterQuality: FilterQuality.medium,
              fit: fit ?? BoxFit.scaleDown,
              loadingWidget: fallBackIcon,
              errorWidget: errorIcon,
              height: height,
              width: width,
            ),
    );
  }
}
