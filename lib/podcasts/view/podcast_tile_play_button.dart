import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../player/manager/audio_progress_manager.dart';
import '../../player/manager/player_manager.dart';
import '../service/podcast_service.dart';
import 'podcast_tile_progress.dart';

class PodcastTilePlayButton extends StatelessWidget with WatchItMixin {
  const PodcastTilePlayButton({
    super.key,
    required this.selected,
    required this.audio,
    required this.play,
  });

  final bool selected;
  final Audio audio;

  final void Function() play;

  @override
  Widget build(BuildContext context) {
    final isPlayerPlaying = watchPropertyValue(
      (PlayerManager m) => m.isPlaying,
    );

    final playerManager = di<PlayerManager>();

    String label;
    final l10n = context.l10n;
    if (selected) {
      if (isPlayerPlaying) {
        label = l10n.pause;
      } else {
        label = l10n.play;
      }
    } else {
      label = l10n.playAll;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton.filled(
          style: translucentIconButtonStyle(context.colorScheme),
          icon: (isPlayerPlaying && selected)
              ? Icon(Iconz.pause, semanticLabel: label)
              : Padding(
                  padding: Iconz.cupertino
                      ? const EdgeInsets.only(left: 3)
                      : EdgeInsets.zero,
                  child: Icon(Iconz.playFilled, semanticLabel: label),
                ),
          onPressed: () {
            // let's update the database episode duration in case it is not set
            // for podcasts that do not send episode duration:
            di<PodcastService>().updateAudioDuration(audio);
            if (selected) {
              if (isPlayerPlaying) {
                playerManager.pause();
              } else {
                playerManager.resume();
              }
            } else {
              playerManager.safeCurrentAudioPosition().then((value) {
                play();
              });
            }
          },
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.all(1.5),
              child: Consumer(
                builder: (context, ref, _) {
                  final lastPosition = ref.watch(
                    audioProgressManagerProvider.select(
                      (s) => audio.url != null
                          ? s.lastPositions[audio.url]
                          : null,
                    ),
                  );
                  return PodcastTileProgress(
                    selected: selected,
                    lastPosition: lastPosition,
                    duration: audio.durationMs == null
                        ? null
                        : Duration(milliseconds: audio.durationMs!.toInt()),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
