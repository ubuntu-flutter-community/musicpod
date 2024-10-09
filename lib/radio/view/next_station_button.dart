import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../../search/search_model.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../radio_model.dart';

class NextStationButton extends StatelessWidget with WatchItMixin {
  const NextStationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final loading = watchPropertyValue((SearchModel m) => m.loading);
    final audio = watchPropertyValue((PlayerModel m) => m.audio);

    return IconButton(
      tooltip: context.l10n.searchSimilarStation,
      onPressed: loading
          ? null
          : () {
              if (audio == null) return;
              di<RadioModel>().init().then((host) {
                if (host == null) return null;
                return di<SearchModel>().nextSimilarStation(audio).then(
                  (station) {
                    if (station == audio) return;
                    di<PlayerModel>().startPlaylist(
                      audios: [station],
                      listName: station.uuid ?? station.toString(),
                    );
                  },
                );
              });
            },
      icon: Icon(Iconz().explore),
    );
  }
}
