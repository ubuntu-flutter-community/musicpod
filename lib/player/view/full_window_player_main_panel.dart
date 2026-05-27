import 'package:flutter/material.dart';

import '../../common/view/ui_constants.dart';
import '../../extensions/taget_platform_x.dart';
import 'full_window_player_image.dart';
import 'player_main_controls.dart';
import 'player_title_and_artist.dart';
import 'player_track.dart';
import 'player_view.dart';

class FullWindowPlayerMainPanel extends StatelessWidget {
  const FullWindowPlayerMainPanel({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (isMobile) const Spacer(flex: 1),
      const FullWindowPlayerImage(),
      if (isMobile) ...[
        const Spacer(flex: 4),
        const Padding(
          padding: EdgeInsets.all(kLargestSpace + kMediumPlusSpace),
          child: PlayerTitleAndArtist(
            playerPosition: PlayerPosition.fullWindow,
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
        const Spacer(flex: 1),
      ] else
        const SizedBox(height: 4 * kLargestSpace),
    ],
  );
}
