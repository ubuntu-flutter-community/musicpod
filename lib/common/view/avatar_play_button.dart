import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../../radio/radio_model.dart';
import '../data/audio.dart';
import '../data/audio_type.dart';
import 'icons.dart';
import 'theme.dart';

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
    final playerModel = di<PlayerModel>();
    final isPlayerPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);
    final pageIsQueue = watchPropertyValue(
      (PlayerModel m) => m.queueName != null && m.queueName == pageId,
    );
    final iconData = isPlayerPlaying &&
            (pageIsQueue && playerModel.queue.length == audios.length)
        ? Iconz.pause
        : Iconz.playFilled;

    return Padding(
      padding: bigPlayButtonPadding,
      child: CircleAvatar(
        radius: bigAvatarButtonRadius,
        backgroundColor: theme.colorScheme.inverseSurface,
        child: IconButton(
          tooltip: context.l10n.playAll,
          onPressed: () {
            if (audios.isNotEmpty &&
                audios.first.audioType == AudioType.radio) {
              di<RadioModel>().clickStation(audios.first);
            }
            if (isPlayerPlaying) {
              if (pageIsQueue && playerModel.queue.length == audios.length) {
                playerModel.pause();
              } else {
                playerModel.startPlaylist(
                  audios: audios,
                  listName: pageId,
                );
              }
            } else {
              if (pageIsQueue) {
                playerModel.resume();
              } else {
                playerModel.startPlaylist(
                  audios: audios,
                  listName: pageId,
                );
              }
            }
          },
          icon: Icon(
            iconData,
            color: theme.colorScheme.onInverseSurface,
          ),
        ),
      ),
    );
  }
}
