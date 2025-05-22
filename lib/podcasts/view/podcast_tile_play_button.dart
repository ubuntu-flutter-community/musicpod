import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/constants.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../l10n/l10n.dart';
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
    final useYaruTheme = watchPropertyValue(
      (SettingsModel m) => m.useYaruTheme,
    );
    final radius =
        (useYaruTheme
            ? kYaruTitleBarItemHeight
            : isMobile
            ? 40
            : 38) /
        2;

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

    return SizedBox.square(
      dimension: radius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: (radius * 2) - 3,
            child: PodcastTileProgress(
              selected: selected,
              lastPosition: playerModel.getLastPosition(audio.url),
              duration: audio.durationMs == null
                  ? null
                  : Duration(milliseconds: audio.durationMs!.toInt()),
            ),
          ),
          SizedBox.square(
            dimension: radius * 2,
            child: IconButton.filled(
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
                    removeUpdate?.call();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
