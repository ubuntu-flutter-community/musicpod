import 'package:flutter/material.dart';

import '../../../get.dart';
import '../../../l10n.dart';
import '../../../library.dart';
import '../../common/icons.dart';
import '../../data/audio.dart';

class RadioPageStarButton extends StatelessWidget with WatchItMixin {
  const RadioPageStarButton({super.key, required this.station});

  final Audio station;

  @override
  Widget build(BuildContext context) {
    final libraryModel = getIt<LibraryModel>();
    final isStarred = watchPropertyValue(
      (LibraryModel m) => m.starredStations.containsKey(station.url),
    );

    return IconButton(
      tooltip: isStarred
          ? context.l10n.removeFromCollection
          : context.l10n.addToCollection,
      onPressed: station.url == null
          ? null
          : isStarred
              ? () => libraryModel.unStarStation(station.url!)
              : () => libraryModel.addStarredStation(station.url!, {station}),
      icon: Iconz().getAnimatedStar(
        isStarred,
      ),
    );
  }
}
