import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/data/audio.dart';
import '../../player/manager/current_audio_manager.dart';
import '../manager/episodes_manager.dart';
import '../manager/subscribed_podcasts_manager.dart';
import 'podcast_audio_tile.dart';

class SliverPodcastPageList extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final episodesState = this.audios == null
        ? ref.watch(episodesManagerProvider(feedUrl)).value
        : null;
    final audios = this.audios ?? episodesState?.episodes;

    final isPaginated = this.audios == null;
    final hasMore = isPaginated && (episodesState?.hasMore ?? false);
    final count = audios?.length ?? 0;
    final selectedAudio = ref.watch(currentAudioManagerProvider);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: count + (hasMore ? 1 : 0),
        (context, index) {
          if (hasMore && index >= count - 4) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(episodesManagerProvider(feedUrl).notifier).loadMore();
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
            addPodcast: () => ref
                .read(subscribedPodcastsManagerProvider.notifier)
                .togglePodcastSubscription(
                  feedUrl: episode.feedUrl!,
                  imageUrl: episode.albumArtUrl ?? episode.imageUrl ?? '',
                  name: episode.podcastTitle ?? '',
                  artist: episode.copyright ?? '',
                ),
            isExpanded: episode == selectedAudio,
            selected: episode == selectedAudio,
            play: () => ref.read(currentAudioManagerProvider.notifier).play(
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

