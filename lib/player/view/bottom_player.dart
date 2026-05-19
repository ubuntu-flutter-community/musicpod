import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/app_manager.dart';
import '../../app/connectivity_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/share_button.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../player/player_model.dart';
import 'bottom_player_image.dart';
import 'bottom_player_like_and_star_button.dart';
import 'play_button.dart';
import 'playback_rate_button.dart';
import 'player_main_controls.dart';
import 'player_pause_timer_button.dart';
import 'player_title_and_artist.dart';
import 'player_track.dart';
import 'player_view.dart';
import 'stop_button.dart';
import 'volume_popup.dart';

class BottomPlayer extends StatelessWidget with WatchItMixin {
  const BottomPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final smallWindow = context.smallWindow;
    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    final isVideo = watchPropertyValue((PlayerModel m) => m.isVideo);
    final fullWindowMode = watchValue((AppManager m) => m.fullWindowMode);

    final model = di<PlayerModel>();
    final isOnline = watchValue(
      (ConnectivityManager m) =>
          m.connectivityCommand.select((p) => p.isOnline),
    );

    final active = audio?.path != null || isOnline;

    final trackAndPlayer = [
      PlayerTrack(active: active, bottomPlayer: true),
      Flexible(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: kLargestSpace),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: BottomPlayerImage(
                    audio: audio,
                    size: bottomPlayerDefaultHeight - 24,
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
                    const SizedBox(width: 10),
                    if (!smallWindow) const BottomPlayerLikeAndStarButton(),
                  ],
                ),
              ),
              if (!smallWindow)
                Expanded(flex: 6, child: PlayerMainControls(active: active)),
              if (!smallWindow)
                Flexible(
                  flex: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (audio?.audioType == AudioType.podcast)
                        const PlaybackRateButton(),
                      if (!isMobile) const VolumeSliderPopup(),
                      const PlayerPauseTimerButton(),
                      ShareButton(audio: audio, active: active),
                      StopButton(active: active),
                    ],
                  ),
                )
              else ...[
                const BottomPlayerLikeAndStarButton(),
                const SizedBox(width: 10),
                if (isMobile)
                  PlayButton(active: active)
                else
                  PlayerMainControls(
                    active: active,
                    avatarPlayButton: false,
                    iconColor: context.colorScheme.onSurface,
                  ),
              ],
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: audio == null || (isVideo && fullWindowMode)
          ? 0
          : bottomPlayerDefaultHeight,
      child: Column(
        children: isMobile ? trackAndPlayer.reversed.toList() : trackAndPlayer,
      ),
    );
  }
}
