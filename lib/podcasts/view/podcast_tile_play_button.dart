import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../player/player_model.dart';
import '../../settings/settings_model.dart';
import 'podcast_tile_progress.dart';

class PodcastTilePlayButton extends StatelessWidget with WatchItMixin {
  const PodcastTilePlayButton({
    super.key,
    required this.selected,
    required this.audio,
    required this.isPlayerPlaying,
    required this.startPlaylist,
    required this.removeUpdate,
  });

  final bool selected;
  final Audio audio;
  final bool isPlayerPlaying;

  final void Function()? startPlaylist;
  final void Function()? removeUpdate;

  @override
  Widget build(BuildContext context) {
    final playerModel = di<PlayerModel>();
    final theme = context.theme;
    final useYaruTheme =
        watchPropertyValue((SettingsModel m) => m.useYaruTheme);
    var smallAvatarButtonRadius = getSmallAvatarButtonRadius(useYaruTheme);
    return Stack(
      alignment: Alignment.center,
      children: [
        PodcastTileProgress(
          selected: selected,
          lastPosition: playerModel.getLastPosition(audio.url),
          duration: audio.durationMs == null
              ? null
              : Duration(milliseconds: audio.durationMs!.toInt()),
        ),
        CircleAvatar(
          radius: smallAvatarButtonRadius,
          backgroundColor: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.colorScheme.onSurface.withValues(alpha: 0.09),
          child: SizedBox.square(
            dimension: smallAvatarButtonRadius * 2,
            child: IconButton(
              icon: (isPlayerPlaying && selected)
                  ? Icon(
                      Iconz.pause,
                    )
                  : Padding(
                      padding: Iconz.cupertino
                          ? const EdgeInsets.only(left: 3)
                          : EdgeInsets.zero,
                      child: Icon(Iconz.playFilled),
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
                    removeUpdate?.call();
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
