import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/progress.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/l10n.dart';
import '../podcast_manager.dart';

class DownloadButton extends StatelessWidget with WatchItMixin {
  const DownloadButton({
    super.key,
    this.iconSize,
    required this.audio,
    required this.addPodcast,
  });

  final double? iconSize;
  final Audio audio;
  final void Function() addPodcast;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final value = watchValue(
      (PodcastManager m) => m.getDownloadCommand(audio).progress,
    );
    final hasDownload = value == 1.0;

    final isRunning = watchValue(
      (PodcastManager m) => m.getDownloadCommand(audio).isRunning,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          isSelected: hasDownload,
          tooltip: hasDownload
              ? context.l10n.removeDownloadEpisode
              : context.l10n.downloadEpisode,
          icon: Icon(
            hasDownload ? Iconz.downloadFilled : Iconz.download,
            color: hasDownload ? theme.colorScheme.primary : null,
          ),
          onPressed: () {
            if (hasDownload) {
              // manager.deleteDownload(audio: audio);
            } else {
              if (!di<PodcastManager>().isPodcastSubscribed(audio.feedUrl)) {
                addPodcast();
              }
              final downloadCommand = di<PodcastManager>().getDownloadCommand(
                audio,
              );

              if (downloadCommand.isRunning.value) {
                downloadCommand.cancel();
              } else {
                downloadCommand.run(
                  // finishedMessage: context.l10n.downloadFinished(
                  //   audio.title ?? '',
                  // ),
                  // canceledMessage: context.l10n.downloadCancelled(
                  //   audio.title ?? '',
                  // ),
                  // audio: audio,
                );
              }
            }
          },
          iconSize: iconSize,
          color: hasDownload
              ? theme.contrastyPrimary
              : theme.colorScheme.onSurface,
        ),
        if (isRunning)
          Positioned.fill(
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.all(1.5),
                child: Progress(
                  adaptive: false,
                  padding: EdgeInsets.zero,
                  value: value == 1.0 ? 0 : value,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
