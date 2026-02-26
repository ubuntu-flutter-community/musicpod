import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/icons.dart';
import '../../common/view/snackbars.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../../search/search_model.dart';

class NextStationButton extends StatelessWidget with WatchItMixin {
  const NextStationButton({super.key, this.iconColor, required this.active});

  final Color? iconColor;
  final bool active;

  @override
  Widget build(BuildContext context) {
    registerHandler(
      select: (SearchModel m) => m.findSimilarStationCommand,
      handler: (context, newValue, cancel) {
        if (newValue != null &&
            newValue.uuid != di<PlayerModel>().audio?.uuid) {
          di<PlayerModel>().startPlaylist(
            audios: [newValue],
            listName: newValue.uuid!,
          );
        } else {
          showSnackBar(
            context: context,
            content: Text(context.l10n.nothingFound),
          );
        }
      },
    );

    final audio = watchPropertyValue((PlayerModel m) => m.audio);

    final findingSimilarStation = watchValue(
      (SearchModel m) => m.findSimilarStationCommand.isRunning,
    );

    return IconButton(
      tooltip: context.l10n.searchSimilarStation,
      onPressed: !active || findingSimilarStation || audio == null
          ? null
          : () {
              di<SearchModel>().findSimilarStationCommand.run(audio);
            },
      icon: Icon(Iconz.explore, color: iconColor),
    );
  }
}
