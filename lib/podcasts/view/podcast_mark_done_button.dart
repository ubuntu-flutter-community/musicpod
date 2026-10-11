import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../player/manager/player_manager.dart';
import '../manager/episodes_manager.dart';
import 'podcast_icon_button_progress.dart';

class PodcastMarkDoneButton extends ConsumerWidget {
  const PodcastMarkDoneButton({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcast = ref.watch(episodesManagerProvider(feedUrl)).value?.episodes;

    return ValueListenableBuilder<bool>(
      valueListenable:
          di<PlayerManager>().toggleAudiosProgressCommand.isRunning,
      builder: (context, isToggling, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: context.l10n.markAllEpisodesAsDone,
              onPressed: isToggling
                  ? null
                  : () => di<PlayerManager>().toggleAudiosProgressCommand.run((
                      audios: podcast ?? [],
                      markComplete: true,
                    )),
              icon: Icon(Iconz.markAllRead),
            ),
            if (isToggling) const PodcastIconButtonProgress(),
          ],
        );
      },
    );
  }
}

class EpisodeMarkDownButton extends StatelessWidget with WatchItMixin {
  const EpisodeMarkDownButton({super.key, required this.episode});

  final Audio episode;

  @override
  Widget build(BuildContext context) {
    final progress = watchValue(
      (PlayerManager m) => m.toggleAudiosProgressCommand,
    );
    final isCompleted =
        progress?[episode.url]?.inMilliseconds == episode.durationMs?.toInt() &&
        episode.durationMs != null;

    final isPlaying = watchPropertyValue((PlayerManager m) {
      final audio = m.audio;
      return audio == episode;
    });

    final isRunning = watchValue(
      (PlayerManager m) => m.toggleAudiosProgressCommand.isRunning,
    );

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
              : () => di<PlayerManager>().toggleAudiosProgressCommand.run((
                  audios: [episode],
                  markComplete: true,
                )),
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
