import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../data.dart';
import '../../l10n.dart';
import 'download_model.dart';

class DownloadButton extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.t;
    final model = ref.read(downloadProvider);
    final value =
        ref.watch(downloadProvider.select((d) => d.getValue(audio?.url)));
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
