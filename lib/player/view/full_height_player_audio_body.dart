import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../settings/settings_model.dart';
import '../player_model.dart';
import 'full_height_player_image.dart';
import 'full_height_player_top_controls.dart';
import 'player_explorer.dart';
import 'player_main_controls.dart';
import 'player_title_and_artist.dart';
import 'player_track.dart';
import 'player_view.dart';

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
    final theme = context.theme;
    final mediaQuerySize = context.mediaQuerySize;

    final showQueue = watchPropertyValue((PlayerModel m) => m.showQueue);

    final showPlayerLyrics = watchPropertyValue(
      (SettingsModel m) => m.showPlayerLyrics,
    );
    final showPlayerExplorer = showQueue || showPlayerLyrics;

    final playerWithSidePanel =
        playerPosition == PlayerPosition.fullWindow &&
        mediaQuerySize.width > 1000;

    final queueOrHistory = Padding(
      padding: const EdgeInsets.only(top: 50, bottom: 50),
      child: SizedBox(
        width: 400,
        child: PlayerExplorer(selectedColor: theme.colorScheme.onSurface),
      ),
    );

    final column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showPlayerExplorer && !playerWithSidePanel) ...[
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(top: kLargestSpace),
              child: queueOrHistory,
            ),
          ),
        ] else ...[
          if (!isMobile || context.isPortrait)
            const Hero(
              tag: 'FullHeightPlayerImageInPortrait',
              child: FullHeightPlayerImage(),
            ),
          const SizedBox(height: kLargestSpace),
        ],
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
        SizedBox(
          width: playerWithSidePanel ? 400 : 320,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: showPlayerExplorer && !playerWithSidePanel
                  ? 4 * kLargestSpace
                  : 0,
            ),
            child: PlayerMainControls(active: active),
          ),
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3 * kLargestSpace),
                      child: queueOrHistory,
                    ),
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
          ),
        ),
      ],
    );
  }
}
