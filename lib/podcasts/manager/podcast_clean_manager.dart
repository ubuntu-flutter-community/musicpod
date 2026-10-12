import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/podcast_service.dart';
import 'episodes_manager.dart';
import 'podcast_genre_manager.dart';
import 'podcast_short_info_manager.dart';

part 'podcast_clean_manager.g.dart';

@Riverpod(keepAlive: true)
class PodcastCleanManager extends _$PodcastCleanManager {
  late final PodcastService _podcastService = di<PodcastService>();

  @override
  AsyncValue<Set<String>?> build() => const AsyncData(null);

  Future<Set<String>> clean({bool reclaimDiskSpace = false}) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final unsubscribedPodcasts = await _podcastService
          .deleteUnsubscribedPodcastData();

      if (unsubscribedPodcasts != null) {
        for (final feedUrl in unsubscribedPodcasts) {
          ref.invalidate(episodesManagerProvider(feedUrl));
          ref.invalidate(podcastShortInfoManagerProvider(feedUrl));
          ref.invalidate(podcastGenreManagerProvider(feedUrl));
        }
      }

      if (reclaimDiskSpace) {
        await _podcastService.reclaimDiskSpace();
      }

      return Set<String>.from(unsubscribedPodcasts ?? {});
    });

    state = result;
    return result.value ?? <String>{};
  }
}
