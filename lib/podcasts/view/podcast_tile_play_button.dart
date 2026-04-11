import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import 'podcast_tile_progress.dart';

class PodcastTilePlayButton extends StatelessWidget with WatchItMixin {
  const PodcastTilePlayButton({
    super.key,
    required this.selected,
    required this.audio,
    required this.startPlaylist,
  });

  final bool selected;
  final Audio audio;

  final void Function()? startPlaylist;

  @override
  Widget build(BuildContext context) {
    final isPlayerPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);

    final playerModel = di<PlayerModel>();

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
            if (selected) {
              if (isPlayerPlaying) {
                playerModel.pause();
              } else {
                playerModel.resume();
              }
            } else {
              playerModel.safeLastPosition().then((value) {
                startPlaylist?.call();
              });
            }
          },
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.all(1.5),
              child: PodcastTileProgress(
                selected: selected,
                lastPosition: watchPropertyValue(
                  (PlayerModel m) => m.getLastPosition(audio.url),
                ),
                duration: audio.durationMs == null
                    ? null
                    : Duration(milliseconds: audio.durationMs!.toInt()),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
