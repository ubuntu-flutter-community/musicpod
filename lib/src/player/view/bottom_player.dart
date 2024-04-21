import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../../app.dart';
import '../../../build_context_x.dart';
import '../../../common.dart';
import '../../../constants.dart';
import '../../../data.dart';
import '../../../get.dart';
import '../../../l10n.dart';
import '../../../player.dart';
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
    final veryNarrow = context.m.size.width < kMasterDetailBreakPoint;
    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    final isVideo = watchPropertyValue((PlayerModel m) => m.isVideo);

    final model = getIt<PlayerModel>();
    final appModel = getIt<AppModel>();
    final isOnline = watchPropertyValue((AppModel m) => m.isOnline);

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
                if (audio?.audioType != AudioType.podcast && !veryNarrow)
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
          if (!veryNarrow)
            Expanded(
              flex: 6,
              child: bottomPlayerControls,
            ),
          if (!veryNarrow)
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
                      Iconz().fullScreen,
                      color: theme.colorScheme.onSurface,
                    ),
                    onPressed: () => appModel.setFullScreen(true),
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
          if (veryNarrow)
            InkWell(
              onTap: () => appModel.setFullScreen(true),
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
            appModel.setFullScreen(true);
          }
        },
        child: player,
      );
    }

    return player;
  }
}
