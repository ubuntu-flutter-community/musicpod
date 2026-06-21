import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../extensions/build_context_x.dart';
import '../../radio/manager/radio_star_station_manager.dart';
import '../data/audio.dart';
import 'animated_like_icon.dart';

class StaredStationIconButton extends StatelessWidget with WatchItMixin {
  const StaredStationIconButton({super.key, required this.audio, this.color});

  final Audio? audio;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isStarredStation = watchValue(
      (RadioStarStationManager m) =>
          m.command.select((p) => p.contains(audio?.uuid)),
    );

    return IconButton(
      isSelected: isStarredStation,
      tooltip: isStarredStation
          ? context.l10n.removeFromCollection
          : context.l10n.addToCollection,
      icon: AnimatedStar(isStarred: isStarredStation, color: color),
      onPressed: audio?.uuid == null
          ? null
          : () => di<RadioStarStationManager>().command.run(audio),
      color: color,
    );
  }
}
