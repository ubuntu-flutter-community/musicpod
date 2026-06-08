import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'podcast_service.dart';

@Injectable(cache: true)
class PodcastGenreManager {
  PodcastGenreManager({
    @factoryParam required String feedUrl,
    required PodcastService podcastService,
  }) : _feedUrl = feedUrl,
       _podcastService = podcastService {
    findPodcastGenreCommand.run();
  }

  final String _feedUrl;
  final PodcastService _podcastService;

  late final Command<void, String?> findPodcastGenreCommand =
      Command.createAsyncNoParam(
        () => _podcastService.findPodcastGenre(_feedUrl),
        initialValue: null,
      );

  late final Command<({String genre}), void> updatePodcastGenreCommand =
      Command.createAsyncNoResult(
        (param) => _podcastService.addPodcastGenre(
          feedUrl: _feedUrl,
          genreName: param.genre,
        ),
      );
}
