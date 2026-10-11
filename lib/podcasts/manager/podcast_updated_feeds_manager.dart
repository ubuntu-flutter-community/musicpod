import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/podcast_service.dart';

part 'podcast_updated_feeds_manager.g.dart';

@Riverpod(keepAlive: true)
class PodcastUpdatedFeedsManager extends _$PodcastUpdatedFeedsManager {
  late final PodcastService _podcastService = di<PodcastService>();

  @override
  Future<Set<String>> build() => _podcastService.getPodcastUpdates();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _podcastService.getPodcastUpdates());
  }

  void updateFeeds(Set<String> feedUrls) {
    state = AsyncData(feedUrls);
  }
}
