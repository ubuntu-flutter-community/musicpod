import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/progress.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../manager/download_manager.dart';
import '../manager/subscribed_podcasts_manager.dart';

class DownloadButton extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    final downloadAsync = ref.watch(
      podcastEpisodeDownloadManagerProvider(audio),
    );
    final isRunning = downloadAsync.isLoading;
    final progress =
        (downloadAsync is AsyncLoading
            ? (downloadAsync as AsyncLoading).progress?.toDouble()
            : null) ??
        0.0;
    final hasDownload = downloadAsync.value?.path != null;

    final subs =
        ref.watch(subscribedPodcastsManagerProvider).value ?? <String>{};

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
            if (!subs.contains(audio.feedUrl)) {
              addPodcast();
            }

            ref
                .read(podcastEpisodeDownloadManagerProvider(audio).notifier)
                .toggleDownload();
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
                  value: progress == 1.0 ? 0.0 : progress,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
