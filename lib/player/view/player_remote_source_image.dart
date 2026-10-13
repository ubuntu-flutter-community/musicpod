import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoenix_theme/phoenix_theme.dart';

import '../../common/data/audio_type.dart';
import '../../common/view/progress.dart';
import '../../common/view/safe_network_image.dart';
import '../../extensions/build_context_x.dart';
import '../../radio/manager/online_art_manager.dart';
import '../manager/current_audio_manager.dart';
import '../manager/mpv_metadata_manager.dart';
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

    final audio = ref.watch(currentAudioManagerProvider);
    final isRadio = audio?.audioType == AudioType.radio;
    final icyTitle = isRadio
        ? ref.watch(mpvMetadataManagerProvider.select((m) => m?.icyTitle))
        : null;

    final artAsync = (isRadio && icyTitle != null && icyTitle.isNotEmpty)
        ? ref.watch(onlineArtManagerProvider(icyTitle))
        : null;

    final String? remoteImageUrl;
    final bool isLoading;

    if (isRadio && icyTitle != null && icyTitle.isNotEmpty) {
      remoteImageUrl = artAsync?.value ?? audio?.imageUrl ?? audio?.albumArtUrl;
      isLoading = artAsync?.isLoading ?? false;
    } else {
      remoteImageUrl = audio?.imageUrl ?? audio?.albumArtUrl;
      isLoading = false;
    }

    final progressSize = (height * 0.4).clamp(14.0, 48.0);

    Widget imageWidget = remoteImageUrl == null
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
          );

    if (isLoading) {
      imageWidget = Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          imageWidget,
          Center(
            child: SizedBox(
              width: progressSize,
              height: progressSize,
              child: const Progress(strokeWidth: 2),
            ),
          ),
        ],
      );
    }

    return Container(
      color: theme.cardColor.scale(lightness: theme.isLight ? -0.15 : 0.3),
      height: height,
      width: width,
      child: imageWidget,
    );
  }
}
