import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/podcasts/data/podcast_genre.dart';
import 'package:musicpod/podcasts/data/podcast_short_info.dart';
import 'package:musicpod/podcasts/manager/podcast_collection_filter_manager.dart';
import 'package:musicpod/podcasts/manager/podcast_feeds_with_downloads_manager.dart';
import 'package:musicpod/podcasts/manager/podcast_genre_manager.dart';
import 'package:musicpod/podcasts/manager/podcast_load_genres_manager.dart';
import 'package:musicpod/podcasts/manager/podcast_short_info_manager.dart';
import 'package:musicpod/podcasts/service/podcast_service.dart';

import 'podcast_riverpod_managers_test.mocks.dart';

@GenerateMocks([PodcastService])
void main() {
  late MockPodcastService mockPodcastService;

  setUp(() async {
    await GetIt.I.reset();
    mockPodcastService = MockPodcastService();
    GetIt.I.registerSingleton<PodcastService>(mockPodcastService);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('PodcastLoadGenresManager loads genres and handles refresh', () async {
    const genres = [
      PodcastGenre.technology,
      PodcastGenre.science,
    ];
    when(mockPodcastService.loadGenres(force: anyNamed('force')))
        .thenAnswer((_) async => genres);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state =
        await container.read(podcastLoadGenresManagerProvider.future);
    expect(state, genres);

    await container
        .read(podcastLoadGenresManagerProvider.notifier)
        .loadGenres(force: true);
    verify(mockPodcastService.loadGenres(force: true)).called(1);
  });

  test('PodcastGenreManager finds and updates genre for feed', () async {
    const feedUrl = 'https://example.com/feed.xml';
    when(mockPodcastService.findPodcastGenre(feedUrl))
        .thenAnswer((_) async => 'Technology');
    when(mockPodcastService.addPodcastGenre(
      feedUrl: feedUrl,
      genreName: 'Science',
    )).thenAnswer((_) async => 1);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initial =
        await container.read(podcastGenreManagerProvider(feedUrl).future);
    expect(initial, 'Technology');

    await container
        .read(podcastGenreManagerProvider(feedUrl).notifier)
        .updateGenre('Science');
    expect(
      container.read(podcastGenreManagerProvider(feedUrl)).value,
      'Science',
    );
    verify(mockPodcastService.addPodcastGenre(
      feedUrl: feedUrl,
      genreName: 'Science',
    )).called(1);
  });

  test('PodcastUpdatesOnlyManager toggles and updates state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(podcastUpdatesOnlyManagerProvider), isFalse);

    container
        .read(podcastUpdatesOnlyManagerProvider.notifier)
        .setUpdatesOnly(true);
    expect(container.read(podcastUpdatesOnlyManagerProvider), isTrue);

    container.read(podcastUpdatesOnlyManagerProvider.notifier).toggle();
    expect(container.read(podcastUpdatesOnlyManagerProvider), isFalse);
  });

  test('PodcastDownloadsOnlyManager toggles and updates state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(podcastDownloadsOnlyManagerProvider), isFalse);

    container
        .read(podcastDownloadsOnlyManagerProvider.notifier)
        .setDownloadsOnly(true);
    expect(container.read(podcastDownloadsOnlyManagerProvider), isTrue);

    container.read(podcastDownloadsOnlyManagerProvider.notifier).toggle();
    expect(container.read(podcastDownloadsOnlyManagerProvider), isFalse);
  });

  test('PodcastFeedsWithDownloadsManager fetches feeds with downloads', () async {
    when(mockPodcastService.feedsWithDownloads)
        .thenReturn({'https://example.com/feed1.xml'});

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result =
        await container.read(podcastFeedsWithDownloadsManagerProvider.future);
    expect(result, {'https://example.com/feed1.xml'});
  });

  test('PodcastShortInfoManager fetches short info for given feed', () async {
    const feedUrl = 'https://example.com/feed1.xml';
    const info = PodcastShortInfo(
      name: 'Tech Talk',
      artist: 'Host',
      imageUrl: 'https://example.com/image.png',
    );
    when(mockPodcastService.getPodcastShortInfo(feedUrl))
        .thenAnswer((_) async => info);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = await container.read(
      podcastShortInfoManagerProvider(feedUrl).future,
    );
    expect(result, info);
  });
}
