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

    final isRunning = watchValue(
      (PlayerModel m) => m.toggleAudiosProgressCommand.isRunning,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          tooltip: context.l10n.markAllEpisodesAsDone,
          onPressed: isRunning
              ? null
              : () => di<PlayerModel>().toggleAudiosProgressCommand.run((
                  audios: podcast,
                  markComplete: true,
                )),
          icon: Icon(Iconz.markAllRead),
        ),
        if (isRunning) const PodcastIconButtonProgress(),
      ],
    );
  }
}

class EpisodeMarkDownButton extends StatelessWidget with WatchItMixin {
  const EpisodeMarkDownButton({super.key, required this.episode});

  final Audio episode;

  @override
  Widget build(BuildContext context) {
    final isCompleted = watchValue(
      (PlayerModel m) => m.toggleAudiosProgressCommand.select(
        (m) => m?[episode.url]?.inMilliseconds == episode.durationMs?.toInt(),
      ),
    );

    final isPlaying = watchPropertyValue((PlayerModel m) {
      final audio = m.audio;
      return audio == episode;
    });

    final isRunning = watchValue(
      (PlayerModel m) => m.toggleAudiosProgressCommand.isRunning,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          tooltip: context.l10n.markEpisodeAsDone,
          isSelected: isCompleted,
          onPressed: isRunning
              ? null
              : () => di<PlayerModel>().toggleAudiosProgressCommand.run((
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
