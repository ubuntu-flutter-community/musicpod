import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../l10n.dart';
import '../../player.dart';
import '../data/audio.dart';

class AvatarPlayButton extends StatelessWidget with WatchItMixin {
  const AvatarPlayButton({
    super.key,
    required this.audios,
    required this.pageId,
  });

  final Set<Audio> audios;
  final String? pageId;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final playerModel = di<PlayerModel>();
    final isPlayerPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);
    final pageIsQueue = watchPropertyValue(
      (PlayerModel m) => m.queueName != null && m.queueName == pageId,
    );
    final iconData =
        isPlayerPlaying && pageIsQueue ? Iconz().pause : Iconz().play;

    return CircleAvatar(
      radius: avatarIconSize,
      backgroundColor: theme.colorScheme.inverseSurface,
      child: IconButton(
        tooltip: context.l10n.playAll,
        onPressed: pageId == null
            ? null
            : () {
                runOrConfirm(
                  context: context,
                  noConfirm: audios.length < kAudioQueueThreshHold,
                  message: context.l10n.queueConfirmMessage(
                    audios.length.toString(),
                  ),
                  run: () {
                    if (isPlayerPlaying) {
                      if (pageIsQueue) {
                        playerModel.pause();
                      } else {
                        playerModel.startPlaylist(
                          audios: audios,
                          listName: pageId!,
                        );
                      }
                    } else {
                      if (pageIsQueue) {
                        playerModel.resume();
                      } else {
                        playerModel.startPlaylist(
                          audios: audios,
                          listName: pageId!,
                        );
                      }
                    }
                  },
                  onCancel: () {},
                );
              },
        icon: Icon(
          iconData,
          color: theme.colorScheme.onInverseSurface,
        ),
      ),
    );
  }
}
