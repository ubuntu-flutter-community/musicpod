import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/data/audio.dart';
import '../common/logging.dart';
import 'podcast_service.dart';

@Injectable(cache: true)
class EpisodesManager {
  EpisodesManager({
    @factoryParam required String feedUrl,
    @factoryParam required String? genre,
    required PodcastService podcastService,
  }) : _feedUrl = feedUrl,
       _genre = genre,
       _podcastService = podcastService {
    printMessageInDebugMode(
      '$EpisodesManager created for feedUrl: $feedUrl, genre: $genre',
    );
    command.run();
  }

  final String _feedUrl;
  final String? _genre;
  final PodcastService _podcastService;

  late final Command<void, List<Audio>?> command = Command.createAsyncNoParam(
    () => _podcastService.findEpisodes(
      feedUrl: _feedUrl,
      tryFromDbOnly: true,
      genre: _genre,
    ),
    initialValue: null,
  );
}
