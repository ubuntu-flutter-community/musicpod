import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/progress.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
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
    final theme = context.t;
    final model = di<DownloadModel>();
    final value =
        watchPropertyValue((DownloadModel m) => m.getValue(audio?.url));
    return Stack(
      alignment: Alignment.center,
      children: [
        Progress(
          value: value == null || value == 1.0 ? 0 : value,
          backgroundColor: Colors.transparent,
        ),
        IconButton(
          tooltip: audio?.path != null
              ? context.l10n.removeDownloadEpisode
              : context.l10n.downloadEpisode,
          icon: Icon(
            audio?.path != null ? Iconz().downloadFilled : Iconz().download,
            color: audio?.path != null ? theme.colorScheme.primary : null,
          ),
          onPressed: () {
            if (audio?.path != null) {
              model.deleteDownload(context: context, audio: audio);
            } else {
              addPodcast?.call();
              model.startDownload(context: context, audio: audio);
            }
          },
          iconSize: iconSize,
          color: audio?.path != null ? theme.colorScheme.primary : null,
        ),
      ],
    );
  }
}
