import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '../../app/app_model.dart';
import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../radio/view/radio_history_list.dart';
import '../../settings/settings_model.dart';
import 'full_height_player_image.dart';
import 'full_height_player_top_controls.dart';
import 'player_lyrics.dart';
import 'player_main_controls.dart';
import 'player_title_and_artist.dart';
import 'player_track.dart';
import 'player_view.dart';
import 'queue/queue_body.dart';
import 'queue/queue_button.dart';

class FullHeightPlayerAudioBody extends StatelessWidget with WatchItMixin {
  const FullHeightPlayerAudioBody({
    super.key,
    this.audio,
    required this.playerPosition,
    required this.active,
    required this.iconColor,
  });

  final Audio? audio;
  final bool active;
  final PlayerPosition playerPosition;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final showQueue = watchPropertyValue((AppModel m) => m.showQueueOverlay);
    final showPlayerLyrics = watchPropertyValue(
      (SettingsModel m) => m.showPlayerLyrics,
    );

    final playerWithSidePanel =
        playerPosition == PlayerPosition.fullWindow &&
        context.mediaQuerySize.width > 1000;
    final theme = context.theme;
    final queueOrHistory = showPlayerLyrics && audio != null
        ? PlayerLyrics(
            key: ValueKey(audio?.path),
            audio: audio!,
            height: 500,
            width: 400,
          )
        : (audio?.audioType == AudioType.radio
              ? const SizedBox(
                  width: 400,
                  height: 500,
                  child: RadioHistoryList(simpleList: true),
                )
              : QueueBody(selectedColor: theme.colorScheme.onSurface));
    final column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showQueue && !playerWithSidePanel)
          Padding(
            padding: const EdgeInsets.only(
              bottom: 2 * kLargestSpace,
              top: kLargestSpace,
            ),
            child: queueOrHistory,
          )
        else ...[
          if (!isMobile || context.isPortrait)
            const Hero(
              tag: 'FullHeightPlayerImageInPortrait',
              child: FullHeightPlayerImage(showAudioVisualizer: true),
            ),
          const SizedBox(height: kLargestSpace),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: PlayerTitleAndArtist(playerPosition: playerPosition),
          ),
          const SizedBox(height: kLargestSpace),
          SizedBox(
            height: kLargestSpace,
            width: playerWithSidePanel ? 400 : 350,
            child: const PlayerTrack(),
          ),
          const SizedBox(height: kLargestSpace),
        ],
        SizedBox(
          width: playerWithSidePanel ? 400 : 320,
          child: PlayerMainControls(active: active),
        ),
      ],
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: playerWithSidePanel
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 490, child: column),
                    queueOrHistory,
                  ],
                )
              : isMobile && !context.isPortrait
              ? Row(
                  spacing: kLargestSpace,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Hero(
                      tag: 'FullHeightPlayerImageInLandscape',
                      child: FullHeightPlayerImage(height: 200, width: 200),
                    ),
                    SizedBox(width: 400, child: column),
                  ],
                )
              : column,
        ),
        Positioned(
          top: 0,
          right: 0,
          child: FullHeightPlayerTopControls(
            iconColor: iconColor,
            playerPosition: playerPosition,
            showQueueButton: !playerWithSidePanel,
          ),
        ),
        if (isMobile)
          const Positioned(
            bottom: 2 * kLargestSpace,
            child: QueueButton.text(),
          ),
      ],
    );
  }
}
