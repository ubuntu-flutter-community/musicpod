import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/progress.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/l10n.dart';
import '../download_manager.dart';
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

    final progress = watchValue(
      (DownloadManager m) => m.getCommand(audio).progress,
    );
    final results = watchValue(
      (DownloadManager m) => m.getCommand(audio).results,
    );
    final result = results.data;
    final isRunning = results.isRunning;

    final hasDownload = result?.path != null;

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
            final downloadCommand = di<DownloadManager>().getCommand(audio);
            if (!di<PodcastManager>().isPodcastSubscribed(audio.feedUrl)) {
              addPodcast();
            }

            if (isRunning) {
              downloadCommand.cancel();
            } else {
              downloadCommand.run(audio);
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
                  value: progress == 1.0 ? 0 : progress,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
