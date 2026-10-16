import 'package:get_it/get_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/podcasts/data/podcast_download.dart';
import 'package:musicpod/podcasts/data/podcast_genre.dart';
import 'package:musicpod/podcasts/data/podcast_short_info.dart';
import 'package:musicpod/podcasts/manager/download_manager.dart';
import 'package:musicpod/podcasts/manager/episodes_manager.dart';
import 'package:musicpod/podcasts/manager/podcast_collection_filter_manager.dart';
import 'package:musicpod/podcasts/manager/podcast_feeds_with_downloads_manager.dart';
import 'package:musicpod/podcasts/manager/podcast_genre_manager.dart';
import 'package:musicpod/podcasts/manager/podcast_load_genres_manager.dart';
import 'package:musicpod/podcasts/manager/podcast_short_info_manager.dart';
import 'package:musicpod/player/service/player_service.dart';
import 'package:musicpod/podcasts/service/download_service.dart';
import 'package:musicpod/podcasts/service/podcast_service.dart';

import 'mpv_metadata_manager_test.mocks.dart' show MockPlayerService;
import 'podcast_riverpod_managers_test.mocks.dart';

@GenerateMocks([PodcastService, DownloadService])
void main() {
  late MockPodcastService mockPodcastService;
  late MockDownloadService mockDownloadService;
  late MockPlayerService mockPlayerService;

  setUp(() async {
    await GetIt.I.reset();
    mockPodcastService = MockPodcastService();
    mockDownloadService = MockDownloadService();
    mockPlayerService = MockPlayerService();

    when(mockPlayerService.changes).thenAnswer((_) => const Stream.empty());
    when(mockPlayerService.audio).thenReturn(null);
    when(mockPlayerService.isPlaying).thenReturn(false);
    when(mockPlayerService.lastPositions).thenReturn({});

    GetIt.I.registerSingleton<PodcastService>(mockPodcastService);
    GetIt.I.registerSingleton<DownloadService>(mockDownloadService);
    GetIt.I.registerSingleton<PlayerService>(mockPlayerService);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('PodcastLoadGenresManager loads genres and handles refresh', () async {
    const genres = [PodcastGenre.technology, PodcastGenre.science];
    when(
      mockPodcastService.loadGenres(force: anyNamed('force')),
    ).thenAnswer((_) async => genres);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = await container.read(podcastLoadGenresManagerProvider.future);
    expect(state, genres);

    await container
        .read(podcastLoadGenresManagerProvider.notifier)
        .loadGenres(force: true);
    verify(mockPodcastService.loadGenres(force: true)).called(1);
  });

  test('PodcastGenreManager finds and updates genre for feed', () async {
    const feedUrl = 'https://example.com/feed.xml';
    when(
      mockPodcastService.findPodcastGenre(feedUrl),
    ).thenAnswer((_) async => 'Technology');
    when(
      mockPodcastService.addPodcastGenre(
        feedUrl: feedUrl,
        genreName: 'Science',
      ),
    ).thenAnswer((_) async => 1);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initial = await container.read(
      podcastGenreManagerProvider(feedUrl).future,
    );
    expect(initial, 'Technology');

    await container
        .read(podcastGenreManagerProvider(feedUrl).notifier)
        .updateGenre('Science');
    expect(
      container.read(podcastGenreManagerProvider(feedUrl)).value,
      'Science',
    );
    verify(
      mockPodcastService.addPodcastGenre(
        feedUrl: feedUrl,
        genreName: 'Science',
      ),
    ).called(1);
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

  test(
    'PodcastFeedsWithDownloadsManager fetches feeds with downloads',
    () async {
      when(
        mockPodcastService.feedsWithDownloads,
      ).thenReturn({'https://example.com/feed1.xml'});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        podcastFeedsWithDownloadsManagerProvider.future,
      );
      expect(result, {'https://example.com/feed1.xml'});
    },
  );

  test('PodcastShortInfoManager fetches short info for given feed', () async {
    const feedUrl = 'https://example.com/feed1.xml';
    const info = PodcastShortInfo(
      name: 'Tech Talk',
      artist: 'Host',
      imageUrl: 'https://example.com/image.png',
    );
    when(
      mockPodcastService.getPodcastShortInfo(feedUrl),
    ).thenAnswer((_) async => info);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = await container.read(
      podcastShortInfoManagerProvider(feedUrl).future,
    );
    expect(result, info);
  });

  group('DownloadManager', () {
    test('initializes and manages active and recent downloads', () async {
      when(
        mockDownloadService.setDownloadsDirectory(getDefault: true),
      ).thenAnswer((_) async => '/downloads');

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await container.read(downloadManagerProvider.future);
      expect(state.downloadsDirectory, '/downloads');
      expect(state.activeDownloads, isEmpty);
      expect(state.recentDownloads, isEmpty);

      const audio = Audio(
        audioType: AudioType.podcast,
        url: 'https://example.com/ep1.mp3',
        feedUrl: 'https://example.com/feed.xml',
      );

      // Event: inProgress
      const inProgressEvent = PodcastDownload(
        status: DownloadStatus.inProgress,
        audio: audio,
        path: null,
      );
      container
          .read(downloadManagerProvider.notifier)
          .notifyEvent(inProgressEvent);

      var updatedState = container.read(downloadManagerProvider).value!;
      expect(updatedState.activeDownloads.length, 1);
      expect(updatedState.activeDownloads.first.url, audio.url);
      expect(updatedState.lastEvent, inProgressEvent);

      // Event: completed
      const completedEvent = PodcastDownload(
        status: DownloadStatus.completed,
        audio: audio,
        path: '/downloads/ep1.mp3',
      );
      container
          .read(downloadManagerProvider.notifier)
          .notifyEvent(completedEvent);

      updatedState = container.read(downloadManagerProvider).value!;
      expect(updatedState.activeDownloads, isEmpty);
      expect(updatedState.recentDownloads.length, 1);
      expect(updatedState.recentDownloads.first.url, audio.url);
      expect(updatedState.lastEvent, completedEvent);
    });

    test('hasDownload checks podcastService.getDownloadPath', () {
      when(
        mockDownloadService.setDownloadsDirectory(getDefault: true),
      ).thenAnswer((_) async => '/downloads');

      const audio = Audio(
        audioType: AudioType.podcast,
        url: 'https://example.com/ep1.mp3',
      );
      when(
        mockPodcastService.getDownloadPath(audio),
      ).thenReturn('/downloads/ep1.mp3');

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final hasDownload = container
          .read(downloadManagerProvider.notifier)
          .hasDownload(audio);
      expect(hasDownload, isTrue);
    });
  });

  group('PodcastEpisodeDownloadManager', () {
    test(
      'reports progress via AsyncLoading and completes with AsyncData',
      () async {
        const audio = Audio(
          audioType: AudioType.podcast,
          url: 'https://example.com/ep1.mp3',
          feedUrl: 'https://example.com/feed.xml',
        );

        when(mockPodcastService.getDownloadPath(audio)).thenReturn(null);
        when(
          mockDownloadService.setDownloadsDirectory(getDefault: true),
        ).thenAnswer((_) async => '/downloads');

        when(
          mockDownloadService.download(
            targetUrl: anyNamed('targetUrl'),
            podcastDownloadId: anyNamed('podcastDownloadId'),
            cancelToken: anyNamed('cancelToken'),
            onProgress: anyNamed('onProgress'),
          ),
        ).thenAnswer((inv) async {
          final progressCb =
              inv.namedArguments[#onProgress] as void Function(int, int)?;
          progressCb?.call(50, 100);
          return '/downloads/ep1.mp3';
        });

        when(
          mockPodcastService.addDownload(
            url: anyNamed('url'),
            path: anyNamed('path'),
            feedUrl: anyNamed('feedUrl'),
          ),
        ).thenAnswer((_) async {});

        final container = ProviderContainer();
        addTearDown(container.dispose);

        final subscription = container.listen(
          podcastEpisodeDownloadManagerProvider(audio),
          (_, __) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);

        // Initial state is removed (no downloaded path)
        final initialDownload = await container.read(
          podcastEpisodeDownloadManagerProvider(audio).future,
        );
        expect(initialDownload.status, DownloadStatus.removed);
        expect(initialDownload.path, isNull);

        // Trigger download
        await container
            .read(podcastEpisodeDownloadManagerProvider(audio).notifier)
            .toggleDownload();

        final finalState = container.read(
          podcastEpisodeDownloadManagerProvider(audio),
        );
        expect(finalState, isA<AsyncData<PodcastDownload>>());
        expect(finalState.value?.status, DownloadStatus.completed);
        expect(finalState.value?.path, '/downloads/ep1.mp3');
      },
    );
  });

  group('EpisodesManager', () {
    test(
      'loads episodes, filters, and supports sorting and loadMore',
      () async {
        const feedUrl = 'https://example.com/podcast.xml';
        final testEpisodes = List.generate(
          30,
          (i) => Audio(
            audioType: AudioType.podcast,
            url: 'https://example.com/ep$i.mp3',
            feedUrl: feedUrl,
            title: 'Episode ${i + 1}',
          ),
        );

        when(mockPodcastService.ascendingPodcasts).thenAnswer((_) async => {});
        when(
          mockPodcastService.findEpisodes(
            feedUrl: feedUrl,
            tryFromDbOnly: anyNamed('tryFromDbOnly'),
            order: anyNamed('order'),
          ),
        ).thenAnswer((_) async => testEpisodes);
        when(mockPodcastService.getDownloadPath(any)).thenReturn(null);

        final container = ProviderContainer();
        addTearDown(container.dispose);
        final sub = container.listen(
          episodesManagerProvider(feedUrl),
          (_, __) {},
        );
        addTearDown(sub.close);

        final state = await container.read(
          episodesManagerProvider(feedUrl).future,
        );

        expect(state.episodes.length, 25);
        expect(state.totalCount, 30);
        expect(state.hasMore, isTrue);

        // Load more
        container.read(episodesManagerProvider(feedUrl).notifier).loadMore();
        final expandedState = container
            .read(episodesManagerProvider(feedUrl))
            .value!;
        expect(expandedState.episodes.length, 30);
        expect(expandedState.hasMore, isFalse);

        // Toggle search
        container
            .read(episodesManagerProvider(feedUrl).notifier)
            .toggleShowSearch();
        expect(
          container.read(episodesManagerProvider(feedUrl)).value!.showSearch,
          isTrue,
        );
      },
    );
  });
}
