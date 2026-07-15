import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/util/family.dart';
import '../data/podcast_short_info.dart';
import 'podcast_manager.dart';

@injectable
class PodcastShortInfoManager {
  PodcastShortInfoManager._({
    required String feedUrl,
    required PodcastManager podcastManager,
  }) {
    command = Command.createAsyncNoParam(
      () => podcastManager.getPodcastShortInfo(feedUrl),
      initialValue: null,
    );

    command.run();
  }

  @factoryMethod
  static PodcastShortInfoManager create({
    @factoryParam required String feedUrl,
    required PodcastManager podcastManager,
  }) => Family.of(
    feedUrl,
    () => PodcastShortInfoManager._(
      feedUrl: feedUrl,
      podcastManager: podcastManager,
    ),
    shouldDispose: (t) => t.command.listenerCount == 0,
    onDispose: (t) => t.command.dispose(),
  );

  late final Command<void, PodcastShortInfo?> command;
}
