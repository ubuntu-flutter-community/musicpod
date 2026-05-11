import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../podcast_manager.dart';
import 'podcast_icon_button_progress.dart';

class PodcastReplayButton extends StatelessWidget with WatchItMixin {
  const PodcastReplayButton({super.key, required this.feedUrl});

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
          tooltip: context.l10n.replayAllEpisodes,
          onPressed: isRunning
              ? null
              : () => di<PlayerModel>().toggleAudiosProgressCommand.run((
                  audios: podcast,
                  markComplete: false,
                )),
          icon: Icon(Iconz.replay),
        ),
        if (isRunning) const PodcastIconButtonProgress(),
      ],
    );
  }
}

class PodcastEpisodeResetProgressButton extends StatelessWidget
    with WatchItMixin {
  const PodcastEpisodeResetProgressButton({super.key, required this.audio});

  final Audio audio;

  @override
  Widget build(BuildContext context) {
    final isRunning = watchValue(
      (PlayerModel m) => m.toggleAudiosProgressCommand.isRunning,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          tooltip: context.l10n.replayEpisode,
          onPressed: audio.url == null || isRunning
              ? null
              : () => di<PlayerModel>().toggleAudiosProgressCommand.run((
                  audios: [audio],
                  markComplete: false,
                )),
          icon: Icon(Iconz.replay),
        ),
        if (isRunning) const PodcastIconButtonProgress(),
      ],
    );
  }
}
