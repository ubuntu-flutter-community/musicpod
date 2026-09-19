import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/platform_x.dart';
import 'full_window_player_image.dart';
import 'player_explorer.dart';
import 'player_main_controls.dart';
import 'player_title_and_artist.dart';
import 'player_track.dart';
import 'player_view.dart';

class FullWindowPlayerBody extends StatelessWidget with WatchItMixin {
  const FullWindowPlayerBody({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final mediaQuerySize = context.mediaQuerySize;

    final playerWithSidePanel = mediaQuerySize.width > 2 * kPlayerExplorerWidth;

    return playerWithSidePanel
        ? Padding(
            padding: const EdgeInsets.only(bottom: 3 * kLargestSpace),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: kPlayerExplorerWidth,
                  child: Column(
                    spacing: kLargestSpace,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FullWindowPlayerImage(),
                      PlayerTitleAndArtist(
                        playerPosition: PlayerPosition.fullWindow,
                      ),
                    ],
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: kPlayerExplorerWidth,
                    maxHeight:
                        mediaQuerySize.height - 0.3 * mediaQuerySize.height,
                  ),
                  child: PlayerExplorer(
                    selectedColor: context.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMobile) const SizedBox(height: 1 * kLargestSpace),
              Expanded(
                child: PlayerExplorer(
                  selectedColor: context.colorScheme.onSurface,
                  firstChild: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: kLargestSpace,
                      children: [
                        FullWindowPlayerImage(
                          dimension: isMobile
                              ? kFullWindowPlayerImageSize + 45
                              : null,
                        ),
                        if (!isMobile)
                          const PlayerTitleAndArtist(
                            playerPosition: PlayerPosition.fullWindow,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isMobile) ...[
                const Padding(
                  padding: EdgeInsets.only(
                    bottom: 1 * kLargestSpace,
                    left: 2 * kLargestSpace,
                    right: 2 * kLargestSpace,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: PlayerTitleAndArtist(
                          playerPosition: PlayerPosition.fullWindow,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    bottom: 3 * kLargestSpace,
                    left: 2 * kLargestSpace,
                    right: 2 * kLargestSpace,
                  ),
                  child: const PlayerTrack(),
                ),
                PlayerMainControls(active: active),
                const SizedBox(height: 3 * kLargestSpace),
              ],
            ],
          );
  }
}
