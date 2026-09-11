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
        watchValue((EpisodesManager m) => m.command, param1: feedUrl)?.episodes;
    final selectedAudio = watchPropertyValue((PlayerManager m) => m.audio);

    final isPaginated = this.audios == null;
    final hasMore = isPaginated && di<EpisodesManager>(param1: feedUrl).hasMore;
    final count = audios?.length ?? 0;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: count + (hasMore ? 1 : 0),
        (context, index) {
          if (hasMore && index >= count - 4) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              di<EpisodesManager>(param1: feedUrl).loadMore();
            });
          }

          if (index >= count) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                ),
              ),
            );
          }

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
              audios: [episode],
              listName: feedUrl,
              index: 0,
            ),
            includePodcastImage: includePodcastImage,
          );
        },
      ),
    );
  }
}
