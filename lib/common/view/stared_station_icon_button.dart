import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extensions/build_context_x.dart';
import '../../radio/manager/radio_star_station_manager.dart';
import '../data/audio.dart';
import 'animated_like_icon.dart';

class StaredStationIconButton extends ConsumerWidget {
  const StaredStationIconButton({super.key, required this.audio, this.color});

  final Audio? audio;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStarredStation =
        (ref.watch(radioStarStationManagerProvider).value ?? {}).contains(
          audio?.uuid,
        );

    return IconButton(
      isSelected: isStarredStation,
      tooltip: isStarredStation
          ? context.l10n.removeFromCollection
          : context.l10n.addToCollection,
      icon: AnimatedStar(isStarred: isStarredStation, color: color),
      onPressed: audio?.uuid == null
          ? null
          : () => ref
                .read(radioStarStationManagerProvider.notifier)
                .toggleStarredStation(audio),
      color: color,
    );
  }
}
