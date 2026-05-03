import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import '../../l10n/l10n.dart';
import '../../radio/radio_model.dart';
import '../data/audio.dart';
import 'animated_like_icon.dart';

class StaredStationIconButton extends StatelessWidget with WatchItMixin {
  const StaredStationIconButton({super.key, required this.audio, this.color});

  final Audio? audio;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final radioManager = di<RadioManager>();

    watchPropertyValue((RadioManager m) => m.starredStations.length);

    final isStarredStation = radioManager.isStarredStation(audio?.uuid);

    final void Function()? onLike;
    if (audio == null && audio?.uuid == null) {
      onLike = null;
    } else {
      onLike = () {
        isStarredStation
            ? radioManager.unStarStation(audio!.uuid!)
            : radioManager.addStarredStation(audio!.uuid!);
      };
    }

    return IconButton(
      tooltip: isStarredStation
          ? context.l10n.removeFromCollection
          : context.l10n.addToCollection,
      icon: AnimatedStar(isStarred: isStarredStation, color: color),
      onPressed: onLike,
      color: color,
    );
  }
}
