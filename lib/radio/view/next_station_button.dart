import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../player/manager/player_manager.dart';
import '../manager/radio_manager.dart';

class NextStationButton extends StatelessWidget with WatchItMixin {
  const NextStationButton({super.key, this.iconColor, required this.active});

  final Color? iconColor;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final audio = watchPropertyValue((PlayerManager m) => m.audio);

    return Consumer(
      builder: (context, ref, _) {
        final findingSimilarStation =
            ref.watch(similarStationManagerProvider).isLoading;

        return IconButton(
          tooltip: context.l10n.searchSimilarStation,
          onPressed: !active || findingSimilarStation || audio == null
              ? null
              : () async {
                  final newValue = await ref
                      .read(similarStationManagerProvider.notifier)
                      .findSimilarStation(audio);
                  if (context.mounted) {
                    if (newValue != null &&
                        newValue.uuid != null &&
                        newValue.uuid != di<PlayerManager>().audio?.uuid) {
                      await di<PlayerManager>().play(
                        audios: [newValue],
                        listName: newValue.uuid!,
                      );
                    } else {
                      context.toast(Text(context.l10n.nothingFound));
                    }
                  }
                },
          icon: Icon(Iconz.explore, color: iconColor),
        );
      },
    );
  }
}
