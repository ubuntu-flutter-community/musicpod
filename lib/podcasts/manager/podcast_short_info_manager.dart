import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/podcast_short_info.dart';
import '../service/podcast_service.dart';

part 'podcast_short_info_manager.g.dart';

@riverpod
class PodcastShortInfoManager extends _$PodcastShortInfoManager {
  @override
  Future<PodcastShortInfo?> build(String feedUrl) =>
      di<PodcastService>().getPodcastShortInfo(feedUrl);

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await di<PodcastService>().getPodcastShortInfo(feedUrl));
  }

  void setShortInfo(PodcastShortInfo info) {
    state = AsyncData(info);
  }
}
