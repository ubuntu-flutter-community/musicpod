import '../../../common/data/audio_type.dart';
import '../../../common/view/ui_constants.dart';
import '../../../l10n/l10n.dart';
import '../../../library/library_model.dart';
import '../../player_model.dart';
import '../player_main_controls.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'queue_body.dart';

class QueueDialog extends StatelessWidget with WatchItMixin {
  const QueueDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final queue = watchPropertyValue((PlayerModel m) => m.queue);

    return AlertDialog(
      titlePadding: const EdgeInsets.only(
        left: 10,
        right: 10,
        top: kLargestSpace,
        bottom: 10,
      ),
      contentPadding: const EdgeInsets.only(bottom: kLargestSpace, top: 10),
      title: const PlayerMainControls(active: true),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton(
          onPressed: () {
            di<LibraryModel>().addPlaylist(
              '${context.l10n.queue} ${DateTime.now()}',
              List.from(queue.where((e) => e.audioType == AudioType.local)),
            );
            Navigator.of(context).pop();
          },
          child: Text(context.l10n.createNewPlaylist),
        ),
      ],
      content: const QueueBody(),
    );
  }
}
