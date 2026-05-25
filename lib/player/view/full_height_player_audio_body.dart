import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../player_model.dart';
import 'full_height_player_image.dart';
import 'player_explorer.dart';
import 'player_main_controls.dart';
import 'player_track.dart';

class FullHeightPlayerAudioBody extends StatelessWidget with WatchItMixin {
  const FullHeightPlayerAudioBody({
    super.key,
    this.audio,
    required this.active,
    required this.iconColor,
  });

  final Audio? audio;
  final bool active;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final mediaQuerySize = context.mediaQuerySize;

    final showQueue = watchPropertyValue((PlayerModel m) => m.showQueue);

    final playerWithSidePanel = mediaQuerySize.width > 2 * kPlayerExplorerWidth;

    final queueOrHistory = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: kPlayerExplorerWidth,
        maxHeight: mediaQuerySize.height - 0.3 * mediaQuerySize.height,
      ),
      child: PlayerExplorer(selectedColor: theme.colorScheme.onSurface),
    );

    final column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showQueue && !playerWithSidePanel) ...[
          Expanded(child: queueOrHistory),
          if (isMobile) ...[
            const Padding(
              padding: EdgeInsets.only(
                bottom: 1 * kLargestSpace,
                left: 2 * kLargestSpace,
                right: 2 * kLargestSpace,
              ),
              child: PlayerTrack(),
            ),
            const SizedBox(height: kLargestSpace),
            PlayerMainControls(active: active),
            const SizedBox(height: 3 * kLargestSpace),
          ],
        ] else ...[
          if (isMobile) const Spacer(flex: 1),
          const Hero(
            tag: 'FullHeightPlayerImageInPortrait',
            child: FullHeightPlayerImage(),
          ),
          if (!isMobile) const SizedBox(height: 4 * kLargestSpace),
          if (isMobile) ...[
            const Spacer(flex: 4),
            const Padding(
              padding: EdgeInsets.only(
                bottom: 3 * kLargestSpace,
                left: 2 * kLargestSpace,
                right: 2 * kLargestSpace,
              ),
              child: const PlayerTrack(),
            ),
            PlayerMainControls(active: active),
            const Spacer(flex: 1),
          ],
        ],
      ],
    );

    return Center(
      child: playerWithSidePanel
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: kPlayerExplorerWidth, child: column),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3 * kLargestSpace),
                  child: queueOrHistory,
                ),
              ],
            )
          : column,
    );
  }
}
