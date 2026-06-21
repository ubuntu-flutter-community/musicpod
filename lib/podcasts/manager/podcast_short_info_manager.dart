import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import '../../common/keep_alive_registry.dart';
import '../data/podcast_short_info.dart';
import '../podcast_service.dart';

@injectable
class PodcastShortInfoManager {
  PodcastShortInfoManager._({
    required String feedUrl,
    required PodcastService podcastService,
  }) {
    command = Command.createAsync(
      podcastService.getPodcastShortInfo,
      initialValue: null,
    );

    command.run(feedUrl);
  }

  @factoryMethod
  static PodcastShortInfoManager create({
    @factoryParam required String feedUrl,
    required PodcastService podcastService,
  }) => _registry.getOrRegister(
    id: feedUrl,
    factoryFunction: () => PodcastShortInfoManager._(
      feedUrl: feedUrl,
      podcastService: podcastService,
    ),
  );

  static final _registry = KeepAliveRegistry<String, PodcastShortInfoManager>();
  static PodcastShortInfoManager? dispose(String feedUrl) =>
      _registry.dispose(feedUrl);
  static void disposeAll() => _registry.disposeAll();

  late final Command<String, PodcastShortInfo?> command;
}
