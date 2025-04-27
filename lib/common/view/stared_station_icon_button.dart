import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../data/audio.dart';
import 'animated_like_icon.dart';

class StaredStationIconButton extends StatelessWidget with WatchItMixin {
  const StaredStationIconButton({
    super.key,
    required this.audio,
    this.color,
  });

  final Audio? audio;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final libraryModel = di<LibraryModel>();

    watchPropertyValue((LibraryModel m) => m.starredStations.length);

    final isStarredStation = libraryModel.isStarredStation(audio?.uuid);

    final void Function()? onLike;
    if (audio == null && audio?.uuid == null) {
      onLike = null;
    } else {
      onLike = () {
        isStarredStation
            ? libraryModel.unStarStation(audio!.uuid!)
            : libraryModel.addStarredStation(
                audio!.uuid!,
              );
      };
    }

    return IconButton(
      tooltip: isStarredStation
          ? context.l10n.removeFromCollection
          : context.l10n.addToCollection,
      icon: AnimatedStar(
        isStarred: isStarredStation,
        color: color,
      ),
      onPressed: onLike,
      color: color,
    );
  }
}
