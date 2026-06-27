import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/util/keep_alive_registry.dart';
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

    podcastManager.wipeCommand.listen((_, sub) {
      dispose(feedUrl);
      sub.cancel();
    });
  }

  @factoryMethod
  static PodcastShortInfoManager create({
    @factoryParam required String feedUrl,
    required PodcastManager podcastManager,
  }) => _registry.getOrRegister(
    id: feedUrl,
    factoryFunction: () => PodcastShortInfoManager._(
      feedUrl: feedUrl,
      podcastManager: podcastManager,
    ),
  );

  static final _registry = KeepAliveRegistry<String, PodcastShortInfoManager>();
  static PodcastShortInfoManager? dispose(String feedUrl) =>
      _registry.dispose(feedUrl);
  static void disposeAll() => _registry.disposeAll();

  late final Command<void, PodcastShortInfo?> command;
}
