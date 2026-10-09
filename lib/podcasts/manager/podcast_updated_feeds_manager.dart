import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../service/podcast_service.dart';

@Injectable(cache: true)
class PodcastUpdatedFeedsManager {
  PodcastUpdatedFeedsManager({required PodcastService podcastService}) {
    command = Command.createAsyncNoParam(
      () => podcastService.getPodcastUpdates(),
      initialValue: {},
    );
    command.run();
  }

  late final Command<void, Set<String>> command;
}
