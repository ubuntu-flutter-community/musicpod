import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../extensions/build_context_x.dart';
import '../../player/player_manager.dart';
import '../../radio/radio_manager.dart';
import '../data/audio.dart';
import '../data/audio_type.dart';
import 'icons.dart';
import 'ui_constants.dart';

class AvatarPlayButton extends StatelessWidget with WatchItMixin {
  const AvatarPlayButton({
    super.key,
    required this.audios,
    required this.pageId,
  });

  final List<Audio> audios;
  final String pageId;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final playerManager = di<PlayerManager>();
    final disabled = pageId.isEmpty || audios.isEmpty;
    final isPlayerPlaying = watchPropertyValue(
      (PlayerManager m) => m.isPlaying,
    );
    final pageIsQueue = watchPropertyValue(
      (PlayerManager m) => m.queueName != null && m.queueName == pageId,
    );
    final iconData =
        isPlayerPlaying &&
            (pageIsQueue && playerManager.queue.length == audios.length)
        ? Iconz.pause
        : Iconz.playFilled;

    final label = context.l10n.playAll;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSmallestSpace),
      child: IconButton(
        style: IconButton.styleFrom(
          shape: const CircleBorder(),

          minimumSize: Size(
            context.buttonHeight * 1.2,
            context.buttonHeight * 1.2,
          ),
          maximumSize: Size(
            context.buttonHeight * 1.2,
            context.buttonHeight * 1.2,
          ),
          backgroundColor: theme.colorScheme.inverseSurface,
          foregroundColor: theme.colorScheme.onInverseSurface,
          hoverColor: theme.colorScheme.primary.withValues(alpha: 0.5),
          focusColor: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
        tooltip: label,
        onPressed: disabled
            ? null
            : () {
                if (audios.isNotEmpty &&
                    audios.first.audioType == AudioType.radio) {
                  di<RadioManager>().clickStation(audios.first);
                }
                if (isPlayerPlaying) {
                  if (pageIsQueue &&
                      playerManager.queue.length == audios.length) {
                    playerManager.pause();
                  } else {
                    playerManager.startPlaylist(
                      audios: audios,
                      listName: pageId,
                    );
                  }
                } else {
                  if (pageIsQueue) {
                    playerManager.resume();
                  } else {
                    playerManager.startPlaylist(
                      audios: audios,
                      listName: pageId,
                    );
                  }
                }
              },
        icon: Icon(
          iconData,
          color: disabled ? null : theme.colorScheme.onInverseSurface,
          semanticLabel: label,
        ),
      ),
    );
  }
}
