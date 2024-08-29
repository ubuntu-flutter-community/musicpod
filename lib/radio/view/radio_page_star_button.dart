import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';

class RadioPageStarButton extends StatelessWidget with WatchItMixin {
  const RadioPageStarButton({super.key, required this.station});

  final Audio station;

  @override
  Widget build(BuildContext context) {
    final libraryModel = di<LibraryModel>();
    final isStarred = watchPropertyValue(
      (LibraryModel m) => m.starredStations.containsKey(station.url),
    );

    return IconButton(
      isSelected: isStarred,
      tooltip: isStarred
          ? context.l10n.removeFromCollection
          : context.l10n.addToCollection,
      onPressed: station.url == null
          ? null
          : isStarred
              ? () => libraryModel.unStarStation(station.url!)
              : () => libraryModel.addStarredStation(station.url!, [station]),
      icon: Iconz().getAnimatedStar(isStarred),
    );
  }
}
