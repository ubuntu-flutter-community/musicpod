import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../podcast_manager.dart';
import 'podcast_icon_button_progress.dart';

class PodcastMarkDoneButton extends StatelessWidget with WatchItMixin {
  const PodcastMarkDoneButton({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final podcast = watchValue(
      (PodcastManager m) => m.getEpisodesCommand(feedUrl),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          tooltip: context.l10n.markAllEpisodesAsDone,
          onPressed: () =>
              di<PlayerModel>().markProgressCompleteCommand.run(podcast),
          icon: Icon(Iconz.markAllRead),
        ),
        if (watchValue(
          (PlayerModel m) => m.markProgressCompleteCommand.isRunning,
        ))
          const PodcastIconButtonProgress(),
      ],
    );
  }
}

class EpisodeMarkDownButton extends StatelessWidget with WatchItMixin {
  const EpisodeMarkDownButton({super.key, required this.episode});

  final Audio episode;

  @override
  Widget build(BuildContext context) {
    final isCompleted = watchPropertyValue(
      (PlayerModel m) =>
          m.getLastPosition(episode.url)?.inMilliseconds ==
          episode.durationMs?.toInt(),
    );

    final isPlaying = watchPropertyValue((PlayerModel m) {
      final audio = m.audio;
      return audio == episode;
    });

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          tooltip: context.l10n.markEpisodeAsDone,
          isSelected: isCompleted,
          onPressed: () =>
              di<PlayerModel>().markProgressCompleteCommand.run([episode]),
          icon: Icon(
            Iconz.markAllRead,
            color: isCompleted && !isPlaying ? Colors.green : null,
          ),
        ),
        if (watchValue(
          (PlayerModel m) => m.markProgressCompleteCommand.isRunning,
        ))
          const PodcastIconButtonProgress(),
      ],
    );
  }
}
