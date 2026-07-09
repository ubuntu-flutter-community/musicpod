import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../data/podcast_short_info.dart';
import 'podcast_manager.dart';

@Injectable(cache: true)
class PodcastShortInfoManager {
  PodcastShortInfoManager({
    @factoryParam required String feedUrl,
    required PodcastManager podcastManager,
  }) {
    command = Command.createAsyncNoParam(
      () => podcastManager.getPodcastShortInfo(feedUrl),
      initialValue: null,
    );

    command.run();
  }

  late final Command<void, PodcastShortInfo?> command;
}
