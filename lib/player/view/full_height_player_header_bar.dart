import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import '../../app/app_manager.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../l10n/l10n.dart';
import 'full_height_player_top_controls.dart';
import 'player_view.dart';

class FullHeightPlayerHeaderBar extends StatelessWidget {
  const FullHeightPlayerHeaderBar({
    super.key,
    required this.isVideo,
    required this.playerPosition,
  });

  final bool isVideo;
  final PlayerPosition playerPosition;

  @override
  Widget build(BuildContext context) {
    return HeaderBar(
      leading: playerPosition == PlayerPosition.sideBar || isMobile
          ? Center(
              child: IconButton(
                tooltip: context.l10n.fullWindow,
                icon: Icon(Iconz.fullScreen),
                onPressed: () => di<AppManager>().setFullWindowMode(
                  playerPosition == PlayerPosition.sideBar,
                ),
              ),
            )
          : null,
      adaptive: false,
      includeBackButton: false,
      includeSidebarButton: false,
      title: const Text('', maxLines: 1, overflow: TextOverflow.ellipsis),
      foregroundColor: isVideo == true ? Colors.white : null,
      backgroundColor: isVideo == true ? Colors.black : Colors.transparent,
      actions: isVideo
          ? null
          : [
              FullHeightPlayerTopControls(
                iconColor: isVideo
                    ? Colors.white
                    : context.colorScheme.onSurface,
                playerPosition: playerPosition,
                video: isVideo,
              ),
            ],
    );
  }
}
