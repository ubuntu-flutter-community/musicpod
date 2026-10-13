import 'package:get_it/get_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/local_audio/data/local_audio_state.dart';
import 'package:musicpod/local_audio/data/playlist_action.dart';
import 'package:musicpod/local_audio/manager/has_tracks_manager.dart';
import 'package:musicpod/local_audio/manager/liked_audio_paths_manager.dart';
import 'package:musicpod/local_audio/manager/liked_audios_manager.dart';
import 'package:musicpod/local_audio/manager/local_audio_manager.dart';
import 'package:musicpod/local_audio/service/local_audio_service.dart';
import 'package:musicpod/podcasts/manager/download_manager.dart';
import 'package:musicpod/podcasts/manager/episodes_manager.dart';
import 'package:musicpod/podcasts/service/download_service.dart';
import 'package:musicpod/podcasts/service/podcast_service.dart';

import 'memory_management_test.mocks.dart';

@GenerateMocks([LocalAudioService, DownloadService, PodcastService])
class FakeLocalAudioManager extends LocalAudioManager {
  @override
  Future<LocalAudioState> build() async => const LocalAudioState();
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('DownloadManager memory optimization', () {
    test('hasDownload checks download status directly from PodcastService', () {
      final mockPodcastService = MockPodcastService();
      final mockDownloadService = MockDownloadService();
      GetIt.I.registerSingleton<PodcastService>(mockPodcastService);
      GetIt.I.registerSingleton<DownloadService>(mockDownloadService);

      when(
        mockDownloadService.setDownloadsDirectory(
          getDefault: anyNamed('getDefault'),
        ),
      ).thenAnswer((_) async => '/fake/downloads');

      final container = ProviderContainer();
      addTearDown(container.dispose);

      const audio1 = Audio(
        audioType: AudioType.podcast,
        url: 'https://example.com/ep1.mp3',
      );
      const audio2 = Audio(
        audioType: AudioType.podcast,
        url: 'https://example.com/ep2.mp3',
      );

      when(mockPodcastService.getDownloadPath(audio1)).thenReturn(null);
      when(
        mockPodcastService.getDownloadPath(audio2),
      ).thenReturn('/fake/path/ep2.mp3');

      final downloadManager = container.read(downloadManagerProvider.notifier);
      expect(downloadManager.hasDownload(audio1), isFalse);
      expect(downloadManager.hasDownload(audio2), isTrue);
    });
  });

  group('HasTracksManager lightweight boolean check', () {
    test('returns true/false without loading track list', () async {
      final fakeLocalAudio = FakeLocalAudioManager();
      final mockLocalAudioService = MockLocalAudioService();
      GetIt.I.registerSingleton<LocalAudioService>(mockLocalAudioService);
      when(mockLocalAudioService.hasTracks()).thenAnswer((_) async => false);

      final container = ProviderContainer(
        overrides: [
          localAudioManagerProvider.overrideWith(() => fakeLocalAudio),
        ],
      );
      addTearDown(container.dispose);

      expect(await container.read(hasTracksManagerProvider.future), isFalse);

      when(mockLocalAudioService.hasTracks()).thenAnswer((_) async => true);
      container.invalidate(hasTracksManagerProvider);
      expect(await container.read(hasTracksManagerProvider.future), isTrue);
    });
  });

  group('LikedAudioPathsManager & LikedAudiosManager memory separation', () {
    const song1 = Audio(
      audioType: AudioType.local,
      path: '/music/song1.mp3',
      title: 'Song 1',
    );
    const song2 = Audio(
      audioType: AudioType.local,
      path: '/music/song2.mp3',
      title: 'Song 2',
    );

    late MockLocalAudioService mockLocalAudioService;
    late Set<String> likedPaths;
    late List<Audio> likedAudios;

    setUp(() {
      mockLocalAudioService = MockLocalAudioService();
      GetIt.I.registerSingleton<LocalAudioService>(mockLocalAudioService);
      likedPaths = {};
      likedAudios = [];

      when(
        mockLocalAudioService.findLikedAudioPaths(),
      ).thenAnswer((_) async => Set.from(likedPaths));
      when(
        mockLocalAudioService.findLikedAudios(),
      ).thenAnswer((_) async => List.from(likedAudios));
      when(mockLocalAudioService.createOrChangeLikedAudios(any)).thenAnswer((
        inv,
      ) async {
        final param = inv.positionalArguments[0] as PlaylistChange;
        if (param.action == PlaylistAction.addTo && param.audios != null) {
          likedAudios.addAll(param.audios!);
          likedPaths.addAll(
            param.audios!.map((a) => a.path!).whereType<String>(),
          );
        } else if (param.action == PlaylistAction.removeFrom &&
            param.audios != null) {
          likedAudios.removeWhere((a) => param.audios!.contains(a));
          likedPaths.removeAll(param.audios!.map((a) => a.path!));
        }
      });
    });

    test(
      'LikedAudioPathsManager operates strictly with path Strings',
      () async {
        final fakeLocalAudio = FakeLocalAudioManager();
        likedPaths.add(song1.path!);
        likedAudios.add(song1);

        final container = ProviderContainer(
          overrides: [
            localAudioManagerProvider.overrideWith(() => fakeLocalAudio),
          ],
        );
        addTearDown(container.dispose);

        final initialPaths = await container.read(
          likedAudioPathsManagerProvider.future,
        );
        expect(initialPaths, isA<Set<String>>());
        expect(initialPaths, contains(song1.path));
        expect(initialPaths.contains(song2.path), isFalse);

        // Add song2 via pathsManager
        await container
            .read(likedAudioPathsManagerProvider.notifier)
            .addLikedAudios([song2]);

        final updatedPaths = await container.read(
          likedAudioPathsManagerProvider.future,
        );
        expect(updatedPaths, containsAll([song1.path, song2.path]));
        expect(likedPaths, containsAll([song1.path, song2.path]));

        // Remove song1 via pathsManager
        await container
            .read(likedAudioPathsManagerProvider.notifier)
            .removeLikedAudios([song1]);

        final remainingPaths = await container.read(
          likedAudioPathsManagerProvider.future,
        );
        expect(remainingPaths.contains(song1.path), isFalse);
        expect(remainingPaths, contains(song2.path));
      },
    );

    test(
      'LikedAudioPathsManager does not eagerly instantiate LikedAudiosManager',
      () async {
        final fakeLocalAudio = FakeLocalAudioManager();
        final container = ProviderContainer(
          overrides: [
            localAudioManagerProvider.overrideWith(() => fakeLocalAudio),
          ],
        );
        addTearDown(container.dispose);

        expect(container.exists(likedAudiosManagerProvider), isFalse);

        await container.read(likedAudioPathsManagerProvider.future);
        await container
            .read(likedAudioPathsManagerProvider.notifier)
            .addLikedAudios([song1]);

        expect(container.exists(likedAudiosManagerProvider), isFalse);
      },
    );

    test(
      'Synchronizes LikedAudioPathsManager when LikedAudiosManager is active',
      () async {
        final fakeLocalAudio = FakeLocalAudioManager();
        final container = ProviderContainer(
          overrides: [
            localAudioManagerProvider.overrideWith(() => fakeLocalAudio),
          ],
        );
        addTearDown(container.dispose);

        await container.read(likedAudioPathsManagerProvider.future);
        await container.read(likedAudiosManagerProvider.future);

        expect(container.exists(likedAudiosManagerProvider), isTrue);

        // 1. Add via audiosManager updates both
        await container
            .read(likedAudiosManagerProvider.notifier)
            .addLikedAudios([song1]);

        expect(
          await container.read(likedAudiosManagerProvider.future),
          contains(song1),
        );
        expect(
          await container.read(likedAudioPathsManagerProvider.future),
          contains(song1.path),
        );

        // 2. Add via pathsManager updates audiosManager as well
        await container
            .read(likedAudioPathsManagerProvider.notifier)
            .addLikedAudios([song2]);

        expect(
          await container.read(likedAudioPathsManagerProvider.future),
          contains(song2.path),
        );
        expect(
          await container.read(likedAudiosManagerProvider.future),
          contains(song2),
        );
      },
    );
  });

  group('EpisodesManager chunking & pagination', () {
    const feedUrl = 'https://example.com/podcast.xml';
    late MockPodcastService mockPodcastService;
    late MockDownloadService mockDownloadService;
    late List<Audio> mockEpisodes;

    setUp(() {
      mockEpisodes = List.generate(
        60,
        (i) => Audio(
          audioType: AudioType.podcast,
          url: 'https://example.com/ep$i.mp3',
          feedUrl: feedUrl,
          title: 'Episode ${i + 1}',
          episodeDescription: 'Description for episode ${i + 1}',
        ),
      );

      mockPodcastService = MockPodcastService();
      mockDownloadService = MockDownloadService();

      when(mockPodcastService.ascendingPodcasts).thenAnswer((_) async => {});
      when(
        mockPodcastService.findEpisodes(
          feedUrl: anyNamed('feedUrl'),
          tryFromDbOnly: anyNamed('tryFromDbOnly'),
          order: anyNamed('order'),
        ),
      ).thenAnswer((_) async => List.from(mockEpisodes));
      when(mockPodcastService.getDownloadPath(any)).thenReturn(null);

      when(
        mockDownloadService.setDownloadsDirectory(
          getDefault: anyNamed('getDefault'),
        ),
      ).thenAnswer((_) async => '/fake/downloads');

      GetIt.I.registerSingleton<PodcastService>(mockPodcastService);
      GetIt.I.registerSingleton<DownloadService>(mockDownloadService);
    });

    test('initially loads only pageSize episodes into state', () async {
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

      expect(state.episodes.length, equals(EpisodesManager.pageSize));
      expect(state.displayedCount, equals(EpisodesManager.pageSize));
      expect(state.totalCount, equals(60));
      expect(state.hasMore, isTrue);
      expect(state.allEpisodes.length, equals(60));
    });

    test('loadMore increments displayedCount and updates state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final sub = container.listen(
        episodesManagerProvider(feedUrl),
        (_, __) {},
      );
      addTearDown(sub.close);

      await container.read(episodesManagerProvider(feedUrl).future);

      // First loadMore: 25 -> 50
      container.read(episodesManagerProvider(feedUrl).notifier).loadMore();
      var state = container.read(episodesManagerProvider(feedUrl)).value!;
      expect(state.displayedCount, equals(50));
      expect(state.episodes.length, equals(50));
      expect(state.hasMore, isTrue);

      // Second loadMore: 50 -> 60 (clamped to total 60)
      container.read(episodesManagerProvider(feedUrl).notifier).loadMore();
      state = container.read(episodesManagerProvider(feedUrl)).value!;
      expect(state.displayedCount, equals(60));
      expect(state.episodes.length, equals(60));
      expect(state.hasMore, isFalse);

      // Third loadMore when !hasMore: no-op
      container.read(episodesManagerProvider(feedUrl).notifier).loadMore();
      state = container.read(episodesManagerProvider(feedUrl)).value!;
      expect(state.displayedCount, equals(60));
      expect(state.episodes.length, equals(60));
      expect(state.hasMore, isFalse);
    });

    test('search query reset restores displayedCount to pageSize', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final sub = container.listen(
        episodesManagerProvider(feedUrl),
        (_, __) {},
      );
      addTearDown(sub.close);

      await container.read(episodesManagerProvider(feedUrl).future);

      // Expand to 50
      container.read(episodesManagerProvider(feedUrl).notifier).loadMore();
      var state = container.read(episodesManagerProvider(feedUrl)).value!;
      expect(state.displayedCount, equals(50));

      // Setting search query triggers reset to pageSize
      container
          .read(episodesManagerProvider(feedUrl).notifier)
          .setSearchQuery('Episode 1');
      state = container.read(episodesManagerProvider(feedUrl)).value!;

      expect(state.displayedCount, equals(EpisodesManager.pageSize));
      expect(state.totalCount, lessThan(60));
    });

    test('changing filter type restores displayedCount to pageSize', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final sub = container.listen(
        episodesManagerProvider(feedUrl),
        (_, __) {},
      );
      addTearDown(sub.close);

      await container.read(episodesManagerProvider(feedUrl).future);

      container.read(episodesManagerProvider(feedUrl).notifier).loadMore();
      var state = container.read(episodesManagerProvider(feedUrl)).value!;
      expect(state.displayedCount, equals(50));

      container.read(episodesManagerProvider(feedUrl).notifier).setFilter();
      state = container.read(episodesManagerProvider(feedUrl)).value!;

      expect(state.displayedCount, equals(EpisodesManager.pageSize));
    });
  });
}
