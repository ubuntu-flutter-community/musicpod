import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_model.dart';
import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import 'bottom_player_image.dart';
import 'bottom_player_title_artist.dart';
import 'play_button.dart';
import 'playback_rate_button.dart';
import 'player_like_icon.dart';
import 'player_main_controls.dart';
import 'player_track.dart';
import 'queue_button.dart';
import 'volume_popup.dart';

const kBottomPlayerHeight = 90.0;

class BottomPlayer extends StatelessWidget with WatchItMixin {
  const BottomPlayer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final smallWindow = context.smallWindow;
    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    final isVideo = watchPropertyValue((PlayerModel m) => m.isVideo);

    final model = di<PlayerModel>();
    final appModel = di<AppModel>();
    final isOnline = watchPropertyValue((PlayerModel m) => m.isOnline);

    final active = audio?.path != null || isOnline;
    final showQueueButton = watchPropertyValue(
      (PlayerModel m) =>
          m.queue.length > 1 || audio?.audioType == AudioType.local,
    );

    final bottomPlayerImage = ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: BottomPlayerImage(
        audio: audio,
        size: kBottomPlayerHeight - 24,
        videoController: model.controller,
        isVideo: isVideo,
        isOnline: isOnline,
      ),
    );

    final titleAndArtist = BottomPlayerTitleArtist(
      audio: audio,
    );

    final bottomPlayerControls = PlayerMainControls(
      playPrevious: model.playPrevious,
      playNext: model.playNext,
      active: active,
    );

    final track = PlayerTrack(
      active: active,
      bottomPlayer: true,
    );

    final bottom = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 20),
            child: bottomPlayerImage,
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Flexible(
                  flex: 5,
                  child: titleAndArtist,
                ),
                if (audio?.audioType != AudioType.podcast && !smallWindow)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: PlayerLikeIcon(
                      audio: audio,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
              ],
            ),
          ),
          if (!smallWindow)
            Expanded(
              flex: 6,
              child: bottomPlayerControls,
            ),
          if (!smallWindow)
            Flexible(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (audio?.audioType == AudioType.podcast)
                    PlaybackRateButton(active: active),
                  const VolumeSliderPopup(),
                  if (showQueueButton) const QueueButton(),
                  IconButton(
                    tooltip: context.l10n.fullWindow,
                    icon: Icon(
                      Iconz().fullWindow,
                      color: theme.colorScheme.onSurface,
                    ),
                    onPressed: () => appModel.setFullWindowMode(true),
                  ),
                ],
              ),
            )
          else
            PlayButton(active: active),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );

    final player = SizedBox(
      height: kBottomPlayerHeight,
      child: Column(
        children: [
          track,
          if (smallWindow)
            InkWell(
              onTap: () => appModel.setFullWindowMode(true),
              child: bottom,
            )
          else
            bottom,
        ],
      ),
    );

    if (isMobile) {
      return GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! < 150) {
            appModel.setFullWindowMode(true);
          }
        },
        child: player,
      );
    }

    return player;
  }
}
