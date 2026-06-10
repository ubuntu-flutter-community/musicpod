import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../player/player_manager.dart';
import '../../search/search_manager.dart';

class NextStationButton extends StatelessWidget with WatchItMixin {
  const NextStationButton({super.key, this.iconColor, required this.active});

  final Color? iconColor;
  final bool active;

  @override
  Widget build(BuildContext context) {
    registerHandler(
      select: (SearchManager m) => m.findSimilarStationCommand,
      handler: (context, newValue, cancel) {
        if (newValue != null &&
            newValue.uuid != null &&
            newValue.uuid != di<PlayerManager>().audio?.uuid) {
          di<PlayerManager>().startPlaylist(
            audios: [newValue],
            listName: newValue.uuid!,
          );
        } else {
          context.toast(Text(context.l10n.nothingFound));
        }
      },
    );

    final audio = watchPropertyValue((PlayerManager m) => m.audio);

    final findingSimilarStation = watchValue(
      (SearchManager m) => m.findSimilarStationCommand.isRunning,
    );

    return IconButton(
      tooltip: context.l10n.searchSimilarStation,
      onPressed: !active || findingSimilarStation || audio == null
          ? null
          : () {
              di<SearchManager>().findSimilarStationCommand.run(audio);
            },
      icon: Icon(Iconz.explore, color: iconColor),
    );
  }
}
