import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../../search/search_model.dart';

class NextStationButton extends StatelessWidget with WatchItMixin {
  const NextStationButton({super.key, this.iconColor});

  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final findingSimilarStation =
        watchPropertyValue((SearchModel m) => m.findingSimilarStation);
    final audio = watchPropertyValue((PlayerModel m) => m.audio);

    return IconButton(
      tooltip: context.l10n.searchSimilarStation,
      onPressed: findingSimilarStation || audio == null
          ? null
          : () {
              di<SearchModel>().nextSimilarStation(audio).then(
                (station) {
                  if (station == audio || audio.uuid == null) return;
                  di<PlayerModel>().startPlaylist(
                    audios: [station],
                    listName: station.uuid!,
                  );
                },
              );
            },
      icon: Icon(Iconz.explore, color: iconColor),
    );
  }
}
