import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/progress.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../settings/settings_model.dart';
import '../download_model.dart';

class DownloadButton extends StatelessWidget with WatchItMixin {
  const DownloadButton({
    super.key,
    this.iconSize,
    required this.audio,
    required this.addPodcast,
  });

  final double? iconSize;
  final Audio? audio;
  final void Function()? addPodcast;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final model = di<DownloadModel>();
    final value =
        watchPropertyValue((DownloadModel m) => m.getValue(audio?.url));

    final download = watchPropertyValue(
      (LibraryModel m) => m.getDownload(audio?.url) != null,
    );
    final downloadsDir =
        watchPropertyValue((SettingsModel m) => m.downloadsDir);

    return Stack(
      alignment: Alignment.center,
      children: [
        Progress(
          padding: EdgeInsets.zero,
          value: value == null || value == 1.0 ? 0 : value,
          backgroundColor: Colors.transparent,
        ),
        IconButton(
          tooltip: audio?.path != null
              ? context.l10n.removeDownloadEpisode
              : context.l10n.downloadEpisode,
          icon: Icon(
            download ? Iconz.downloadFilled : Iconz.download,
            color: audio?.path != null ? theme.colorScheme.primary : null,
          ),
          onPressed: downloadsDir == null
              ? null
              : () {
                  if (download) {
                    model.deleteDownload(audio: audio);
                  } else {
                    addPodcast?.call();
                    model.startDownload(
                      finishedMessage:
                          context.l10n.downloadFinished(audio?.title ?? ''),
                      canceledMessage:
                          context.l10n.downloadCancelled(audio?.title ?? ''),
                      audio: audio,
                    );
                  }
                },
          iconSize: iconSize,
          color: download
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
        ),
      ],
    );
  }
}
