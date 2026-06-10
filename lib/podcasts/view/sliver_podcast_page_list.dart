import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio.dart';
import '../../player/player_manager.dart';
import '../data/podcast_toggle_capsule.dart';
import '../podcast_manager.dart';
import 'podcast_audio_tile.dart';

class SliverPodcastPageList extends StatelessWidget with WatchItMixin {
  const SliverPodcastPageList({
    super.key,
    required this.audios,
    required this.pageId,
  });

  final List<Audio> audios;
  final String pageId;

  @override
  Widget build(BuildContext context) {
    final selectedAudio = watchPropertyValue((PlayerManager m) => m.audio);

    return SliverList(
      delegate: SliverChildBuilderDelegate(childCount: audios.length, (
        context,
        index,
      ) {
        final episode = audios.elementAt(index);

        return PodcastAudioTile(
          key: ValueKey('${episode.path ?? episode.url}'),
          audio: episode,
          addPodcast: () => di<PodcastManager>().togglePodcastCommand.run(
            PodcastToggleCapsule(
              feedUrl: episode.feedUrl!,
              imageUrl: episode.albumArtUrl ?? episode.imageUrl ?? '',
              name: episode.podcastTitle ?? '',
              artist: episode.copyright ?? '',
            ),
          ),
          isExpanded: episode == selectedAudio,
          selected: episode == selectedAudio,
          startPlaylist: () => di<PlayerManager>().startPlaylist(
            audios: audios,
            listName: pageId,
            index: index,
          ),
        );
      }),
    );
  }
}
