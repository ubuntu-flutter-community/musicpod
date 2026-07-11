import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio.dart';
import '../../player/manager/player_manager.dart';
import '../data/podcast_toggle_capsule.dart';
import '../manager/episodes_manager.dart';
import '../manager/subscribed_podcasts_manager.dart';
import 'podcast_audio_tile.dart';

class SliverPodcastPageList extends StatelessWidget with WatchItMixin {
  const SliverPodcastPageList({
    super.key,
    required this.feedUrl,
    this.audios,
    this.includePodcastImage = false,
  });

  final String feedUrl;
  final List<Audio>? audios;
  final bool includePodcastImage;

  @override
  Widget build(BuildContext context) {
    final audios =
        this.audios ??
        watchValue(
          (EpisodesManager m) => m.command.select((v) => v?.episodes ?? []),
          param1: feedUrl,
        );
    final selectedAudio = watchPropertyValue((PlayerManager m) => m.audio);

    return SliverList(
      delegate: SliverChildBuilderDelegate(childCount: audios?.length ?? 0, (
        context,
        index,
      ) {
        final episode = audios?.elementAt(index);

        if (episode == null) {
          return const SizedBox.shrink();
        }

        return PodcastAudioTile(
          key: ValueKey('${episode.path ?? episode.url}'),
          audio: episode,
          addPodcast: () => di<SubscribedPodcastsManager>().command.run(
            PodcastToggleCapsule(
              feedUrl: episode.feedUrl!,
              imageUrl: episode.albumArtUrl ?? episode.imageUrl ?? '',
              name: episode.podcastTitle ?? '',
              artist: episode.copyright ?? '',
            ),
          ),
          isExpanded: episode == selectedAudio,
          selected: episode == selectedAudio,
          play: () => di<PlayerManager>().play(
            audios: audios ?? [],
            listName: feedUrl,
            index: index,
          ),
          includePodcastImage: includePodcastImage,
        );
      }),
    );
  }
}
