import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/util/family.dart';
import '../../extensions/command_x.dart';
import '../service/podcast_service.dart';

@injectable
class PodcastUpdatedFeedsManager {
  PodcastUpdatedFeedsManager._({required PodcastService podcastService}) {
    command = Command.createAsyncNoParam(
      () => podcastService.getPodcastUpdates(),
      initialValue: {},
    );
    command.run();
  }

  @factoryMethod
  static PodcastUpdatedFeedsManager create({
    required PodcastService podcastService,
  }) => Family.of(
    '$PodcastUpdatedFeedsManager',
    () => PodcastUpdatedFeedsManager._(podcastService: podcastService),
    shouldDispose: (m) => m.command.safeToDispose,
    onDispose: (m) => m.command.dispose(),
  );

  late final Command<void, Set<String>> command;
}
