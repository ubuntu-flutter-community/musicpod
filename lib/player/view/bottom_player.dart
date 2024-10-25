import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_model.dart';
import '../../app/connectivity_model.dart';
import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/like_icon.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import 'blurred_full_height_player_image.dart';
import 'bottom_player_image.dart';
import 'play_button.dart';
import 'playback_rate_button.dart';
import 'player_main_controls.dart';
import 'player_title_and_artist.dart';
import 'player_track.dart';
import 'player_view.dart';
import 'queue_button.dart';
import 'volume_popup.dart';

class BottomPlayer extends StatelessWidget with WatchItMixin {
  const BottomPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final smallWindow = context.smallWindow;
    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    final isVideo = watchPropertyValue((PlayerModel m) => m.isVideo);

    final model = di<PlayerModel>();
    final appModel = di<AppModel>();
    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);

    final active = audio?.path != null || isOnline;
    final showQueueButton = watchPropertyValue(
      (PlayerModel m) =>
          m.queue.length > 1 || audio?.audioType == AudioType.local,
    );

    final player = SizedBox(
      height: bottomPlayerHeight,
      child: Column(
        children: [
          PlayerTrack(
            active: active,
            bottomPlayer: true,
          ),
          InkWell(
            onTap: () => appModel.setFullWindowMode(true),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: BottomPlayerImage(
                        audio: audio,
                        size: bottomPlayerHeight - 24,
                        videoController: model.controller,
                        isVideo: isVideo,
                        isOnline: isOnline,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        const Flexible(
                          flex: 5,
                          child: PlayerTitleAndArtist(
                            playerPosition: PlayerPosition.bottom,
                          ),
                        ),
                        if (!smallWindow)
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: switch (audio?.audioType) {
                              AudioType.local => LikeIcon(
                                  audio: audio,
                                  color: theme.colorScheme.onSurface,
                                ),
                              AudioType.radio => RadioLikeIcon(audio: audio),
                              _ => const SizedBox.shrink(),
                            },
                          ),
                      ],
                    ),
                  ),
                  if (!smallWindow)
                    Expanded(
                      flex: 6,
                      child: PlayerMainControls(active: active),
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
                              Iconz.fullWindow,
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
            ),
          ),
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

    if (isVideo == true) {
      return player;
    }

    return Stack(
      children: [
        BlurredFullHeightPlayerImage(
          size: Size(context.mediaQuerySize.width, bottomPlayerHeight),
        ),
        player,
      ],
    );
  }
}
