import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/data/audio.dart';
import '../common/keep_alive_registry.dart';
import 'podcast_service.dart';

@injectable
class EpisodesManager {
  EpisodesManager._({
    required String feedUrl,
    required PodcastService podcastService,
  }) {
    _registry.register(id: feedUrl, instance: this);
    command = Command.createAsync(
      (genre) => podcastService.findEpisodes(
        feedUrl: feedUrl,
        tryFromDbOnly: true,
        genre: genre,
      ),
      initialValue: null,
    );
    command.run();
  }

  @factoryMethod
  static EpisodesManager create({
    @factoryParam required String feedUrl,
    required PodcastService podcastService,
  }) =>
      _registry.get(feedUrl) ??
      EpisodesManager._(feedUrl: feedUrl, podcastService: podcastService);

  static final _registry = KeepAliveRegistry<String, EpisodesManager>();
  static EpisodesManager? dispose(String feedUrl) => _registry.dispose(feedUrl);

  late final Command<String?, List<Audio>?> command;
}
