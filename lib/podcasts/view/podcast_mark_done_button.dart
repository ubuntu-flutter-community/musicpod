import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../player/manager/audio_progress_manager.dart';
import '../../player/manager/current_audio_manager.dart';
import '../manager/episodes_manager.dart';
import 'podcast_icon_button_progress.dart';

class PodcastMarkDoneButton extends ConsumerWidget {
  const PodcastMarkDoneButton({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcast = ref.watch(episodesManagerProvider(feedUrl)).value?.episodes;
    final isToggling = ref.watch(
      audioProgressManagerProvider.select((s) => s.isToggling),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          tooltip: context.l10n.markAllEpisodesAsDone,
          onPressed: isToggling
              ? null
              : () => ref
                    .read(audioProgressManagerProvider.notifier)
                    .toggleAudiosProgress(
                      audios: podcast ?? [],
                      markComplete: true,
                    ),
          icon: Icon(Iconz.markAllRead),
        ),
        if (isToggling) const PodcastIconButtonProgress(),
      ],
    );
  }
}

class EpisodeMarkDownButton extends ConsumerWidget {
  const EpisodeMarkDownButton({super.key, required this.episode});

  final Audio episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(
      currentAudioManagerProvider.select((audio) => audio == episode),
    );

    final lastPosition = ref.watch(
      audioProgressManagerProvider.select(
        (s) => episode.url != null ? s.lastPositions[episode.url] : null,
      ),
    );
    final isRunning = ref.watch(
      audioProgressManagerProvider.select((s) => s.isToggling),
    );
    final isCompleted =
        lastPosition?.inMilliseconds == episode.durationMs?.toInt() &&
        episode.durationMs != null;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          tooltip: episode.durationMs == null
              ? context.l10n.podcastDoesNotSendEpisodeDuration
              : context.l10n.markEpisodeAsDone,
          isSelected: isCompleted,
          onPressed: isRunning || episode.durationMs == null
              ? null
              : () => ref
                    .read(audioProgressManagerProvider.notifier)
                    .toggleAudiosProgress(
                      audios: [episode],
                      markComplete: true,
                    ),
          icon: Icon(
            Iconz.markAllRead,
            color: isCompleted && !isPlaying ? Colors.green : null,
          ),
        ),
        if (isRunning) const PodcastIconButtonProgress(),
      ],
    );
  }
}
