import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/animated_like_icon.dart';
import '../../l10n/l10n.dart';
import '../radio_manager.dart';

class RadioPageStarButton extends StatelessWidget with WatchItMixin {
  const RadioPageStarButton({super.key, required this.station});

  final Audio station;

  @override
  Widget build(BuildContext context) {
    final radioManager = di<RadioManager>();
    final isStarred = watchValue(
      (RadioManager m) =>
          m.toggleStarStationCommand.select((p) => p.contains(station.uuid)),
    );

    return IconButton(
      isSelected: isStarred,
      tooltip: isStarred
          ? context.l10n.removeFromCollection
          : context.l10n.addToCollection,
      onPressed: station.uuid == null
          ? null
          : () => radioManager.toggleStarStationCommand.run(station.uuid!),
      icon: AnimatedStar(isStarred: isStarred),
    );
  }
}
