import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/podcast_service.dart';

part 'podcast_feeds_with_downloads_manager.g.dart';

@riverpod
class PodcastFeedsWithDownloadsManager
    extends _$PodcastFeedsWithDownloadsManager {
  late final PodcastService _podcastService = di<PodcastService>();

  @override
  Future<Set<String>> build() async {
    if (_podcastService.feedsWithDownloads.isEmpty) {
      await _podcastService.loadDownloads();
    }
    return _podcastService.feedsWithDownloads;
  }
}
