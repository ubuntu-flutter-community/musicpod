import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../player/manager/audio_progress_manager.dart';
import '../manager/episodes_manager.dart';
import 'podcast_icon_button_progress.dart';

class PodcastReplayButton extends ConsumerWidget {
  const PodcastReplayButton({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcast = ref.watch(episodesManagerProvider(feedUrl)).value;
    final isRunning = ref.watch(
      audioProgressManagerProvider.select((s) => s.isToggling),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          tooltip: context.l10n.replayAllEpisodes,
          onPressed: isRunning
              ? null
              : () => ref
                    .read(audioProgressManagerProvider.notifier)
                    .toggleAudiosProgress(
                      audios: podcast?.episodes ?? [],
                      markComplete: false,
                    ),
          icon: Icon(Iconz.replay),
        ),
        if (isRunning) const PodcastIconButtonProgress(),
      ],
    );
  }
}

class PodcastEpisodeResetProgressButton extends ConsumerWidget {
  const PodcastEpisodeResetProgressButton({super.key, required this.audio});

  final Audio audio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRunning = ref.watch(
      audioProgressManagerProvider.select((s) => s.isToggling),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          tooltip: context.l10n.replayEpisode,
          onPressed: audio.url == null || isRunning
              ? null
              : () => ref
                    .read(audioProgressManagerProvider.notifier)
                    .toggleAudiosProgress(audios: [audio], markComplete: false),
          icon: Icon(Iconz.replay),
        ),
        if (isRunning) const PodcastIconButtonProgress(),
      ],
    );
  }
}
