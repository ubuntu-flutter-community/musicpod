import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class PodcastReplayButton extends StatelessWidget {
  const PodcastReplayButton({super.key, required this.audios});

  final List<Audio> audios;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.l10n.replayAllEpisodes,
      onPressed: () => di<PlayerModel>().removeLastPositions(audios),
      icon: Icon(Iconz().replay),
    );
  }
}
