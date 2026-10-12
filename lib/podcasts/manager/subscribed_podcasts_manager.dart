import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logging.dart';
import '../../dependencies.dart';
import '../data/podcast_toggle_capsule.dart';
import '../service/podcast_service.dart';
import 'episodes_manager.dart';
import 'podcast_genre_manager.dart';
import 'podcast_short_info_manager.dart';

part 'subscribed_podcasts_manager.g.dart';

@Riverpod(keepAlive: true)
class SubscribedPodcastsManager extends _$SubscribedPodcastsManager {
  @override
  Future<Set<String>> build() async {
    Logger.o(tag: '$SubscribedPodcastsManager');
    return di<PodcastService>().getSubscribedPodcasts();
  }

  Future<void> togglePodcastSubscription({
    required String feedUrl,
    String? imageUrl,
    String? name,
    String? artist,
  }) async {
    await di<PodcastService>().togglePodcastSubscription(feedUrl: feedUrl);
    final isSubscribed = await di<PodcastService>().isPodcastSubscribed(
      feedUrl,
    );
    if (!isSubscribed) {
      ref.invalidate(episodesManagerProvider(feedUrl));
      ref.invalidate(podcastShortInfoManagerProvider(feedUrl));
      ref.invalidate(podcastGenreManagerProvider(feedUrl));
    }
    state = AsyncData(await di<PodcastService>().getSubscribedPodcasts());
  }

  Future<void> toggleSubscription(PodcastToggleCapsule param) =>
      togglePodcastSubscription(
        feedUrl: param.feedUrl,
        imageUrl: param.imageUrl,
        name: param.name,
        artist: param.artist,
      );

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await di<PodcastService>().getSubscribedPodcasts());
  }
}
