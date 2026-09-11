import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/app/page_ids.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/common/util/family.dart';
import 'package:musicpod/common/view/audio_filter.dart';
import 'package:musicpod/local_audio/data/playlist_action.dart';
import 'package:musicpod/local_audio/manager/has_tracks_manager.dart';
import 'package:musicpod/local_audio/manager/liked_audio_paths_manager.dart';
import 'package:musicpod/local_audio/manager/liked_audios_manager.dart';
import 'package:musicpod/local_audio/manager/local_audio_manager.dart';
import 'package:musicpod/player/manager/player_manager.dart';
import 'package:musicpod/podcasts/data/podcast_download.dart';
import 'package:musicpod/podcasts/data/podcast_short_info.dart';
import 'package:musicpod/podcasts/manager/download_manager.dart';
import 'package:musicpod/podcasts/manager/episodes_manager.dart';
import 'package:musicpod/podcasts/manager/podcast_manager.dart';
import 'package:musicpod/podcasts/manager/podcast_short_info_manager.dart';
import 'package:musicpod/podcasts/service/download_service.dart';
import 'package:musicpod/podcasts/service/podcast_service.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class FakeLocalAudioManager extends Fake implements LocalAudioManager {
  Set<String> likedPaths = {};
  List<Audio> likedAudios = [];
  bool libraryHasTracks = false;

  @override
  Future<Set<String>> findLikedAudioPaths() async => Set.from(likedPaths);

  @override
  Future<List<Audio>?> findLikedAudios() async => List.from(likedAudios);

  @override
  Future<bool> hasTracks() async => libraryHasTracks;

  @override
  Future<void> createOrChangeLikedAudios(PlaylistChange param) async {
    if (param.action == PlaylistAction.addTo && param.audios != null) {
      likedAudios.addAll(param.audios!);
      likedPaths.addAll(param.audios!.map((a) => a.path!).whereType<String>());
    } else if (param.action == PlaylistAction.removeFrom &&
        param.audios != null) {
      likedAudios.removeWhere((a) => param.audios!.contains(a));
      likedPaths.removeAll(param.audios!.map((a) => a.path!));
    }
  }
}

class FakeDownloadService extends Fake implements DownloadService {
  @override
  Future<String?> setDownloadsDirectory({required bool getDefault}) async =>
      '/fake/downloads';
}

class FakePodcastServiceForDownload extends Fake implements PodcastService {
  final Map<String, String?> downloadPaths = {};

  @override
  String? getDownloadPath(Audio? audio) =>
      audio?.url != null ? downloadPaths[audio!.url] : null;
}

class FakePodcastManagerForEpisodes extends Fake implements PodcastManager {
  final updatesOnly = SafeValueNotifier<bool>(false);
  final downloadsOnly = SafeValueNotifier<bool>(false);
  List<Audio> episodesToReturn = [];

  @override
  Future<Set<String>> get ascendingPodcasts async => {};

  @override
  Future<List<Audio>> findEpisodes({
    required String feedUrl,
    required bool tryFromDbOnly,
    AudioSortOrder? order,
  }) async => List.from(episodesToReturn);
}

class FakePlayerManagerForEpisodes extends Fake implements PlayerManager {
  @override
  Map<String, Duration>? lastPositions;
}

class FakeDownloadManagerForEpisodes extends Fake implements DownloadManager {
  @override
  final downloadCommands =
      MapNotifier<Audio, Command<void, PodcastDownload?>>();

  @override
  bool hasDownload(Audio audio) => false;
}

class FakePodcastShortInfoManagerForEpisodes extends Fake
    implements PodcastShortInfoManager {
  @override
  late final Command<void, PodcastShortInfo?> command =
      Command.createSyncNoParam(() => null, initialValue: null);
}

void main() {
  setUp(() async {
    await Family.reset();
    await GetIt.I.reset();
  });

  tearDown(() async {
    await Family.reset();
    await GetIt.I.reset();
  });

  group('DownloadManager memory optimization', () {
    test(
      'hasDownload checks download status without creating or retaining a Command',
      () {
        final podcastService = FakePodcastServiceForDownload();
        final downloadService = FakeDownloadService();
        final manager = DownloadManager(
          podcastService: podcastService,
          downloadService: downloadService,
        );

        const audio1 = Audio(
          audioType: AudioType.podcast,
          url: 'https://example.com/ep1.mp3',
        );
        const audio2 = Audio(
          audioType: AudioType.podcast,
          url: 'https://example.com/ep2.mp3',
        );

        podcastService.downloadPaths[audio2.url!] = '/fake/path/ep2.mp3';

        expect(manager.downloadCommands.containsKey(audio1), isFalse);
        expect(manager.downloadCommands.containsKey(audio2), isFalse);

        // Calling hasDownload should return correct status without creating a command
        expect(manager.hasDownload(audio1), isFalse);
        expect(manager.hasDownload(audio2), isTrue);

        expect(
          manager.downloadCommands.containsKey(audio1),
          isFalse,
          reason: 'hasDownload must not create a command in downloadCommands',
        );
        expect(
          manager.downloadCommands.containsKey(audio2),
          isFalse,
          reason: 'hasDownload must not create a command in downloadCommands',
        );

        // Explicit getCommand should create and register the command
        final cmd = manager.getCommand(audio1);
        expect(cmd, isNotNull);
        expect(manager.downloadCommands.containsKey(audio1), isTrue);
      },
    );
  });

  group('HasTracksManager lightweight boolean check', () {
    test('returns true/false without loading track list', () async {
      final fakeLocalAudio = FakeLocalAudioManager();
      fakeLocalAudio.libraryHasTracks = false;

      final manager = HasTracksManager.create(
        localAudioManager: fakeLocalAudio,
      );

      await manager.command.runAsync();
      expect(manager.command.value, isFalse);

      fakeLocalAudio.libraryHasTracks = true;
      await manager.command.runAsync();
      expect(manager.command.value, isTrue);
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

    test(
      'LikedAudioPathsManager operates strictly with path Strings',
      () async {
        final fakeLocalAudio = FakeLocalAudioManager();
        fakeLocalAudio.likedPaths.add(song1.path!);
        fakeLocalAudio.likedAudios.add(song1);

        final pathsManager = LikedAudioPathsManager.create(
          localAudioManager: fakeLocalAudio,
        );

        await pathsManager.command.runAsync();
        expect(pathsManager.command.value, isA<Set<String>>());
        expect(pathsManager.command.value, contains(song1.path));
        expect(pathsManager.command.value.contains(song2.path), isFalse);

        // Add song2 via pathsManager
        await pathsManager.command.runAsync(
          PlaylistChange(
            id: PageIDs.likedAudios,
            action: PlaylistAction.addTo,
            audios: [song2],
          ),
        );

        expect(
          pathsManager.command.value,
          containsAll([song1.path, song2.path]),
        );
        expect(
          fakeLocalAudio.likedPaths,
          containsAll([song1.path, song2.path]),
        );

        // Remove song1 via pathsManager
        await pathsManager.command.runAsync(
          PlaylistChange(
            id: PageIDs.likedAudios,
            action: PlaylistAction.removeFrom,
            audios: [song1],
          ),
        );

        expect(pathsManager.command.value.contains(song1.path), isFalse);
        expect(pathsManager.command.value, contains(song2.path));
      },
    );

    test(
      'LikedAudioPathsManager does not eagerly instantiate LikedAudiosManager when not in Family',
      () async {
        final fakeLocalAudio = FakeLocalAudioManager();
        final pathsManager = LikedAudioPathsManager.create(
          localAudioManager: fakeLocalAudio,
        );

        expect(Family.get<LikedAudiosManager>('$LikedAudiosManager'), isNull);

        await pathsManager.command.runAsync(
          PlaylistChange(
            id: PageIDs.likedAudios,
            action: PlaylistAction.addTo,
            audios: [song1],
          ),
        );

        // LikedAudiosManager should NOT have been instantiated
        expect(Family.get<LikedAudiosManager>('$LikedAudiosManager'), isNull);
      },
    );

    test(
      'Synchronizes LikedAudioPathsManager when LikedAudiosManager is active',
      () async {
        final fakeLocalAudio = FakeLocalAudioManager();
        final pathsManager = LikedAudioPathsManager.create(
          localAudioManager: fakeLocalAudio,
        );
        final audiosManager = LikedAudiosManager.create(
          localAudioManager: fakeLocalAudio,
          pathsManager: pathsManager,
        );

        await pumpEventQueue();
        expect(
          Family.get<LikedAudiosManager>('$LikedAudiosManager'),
          isNotNull,
        );

        // 1. Add via audiosManager updates both
        await audiosManager.command.runAsync(
          PlaylistChange(
            id: PageIDs.likedAudios,
            action: PlaylistAction.addTo,
            audios: [song1],
          ),
        );

        await pumpEventQueue();
        expect(audiosManager.command.value, contains(song1));
        expect(pathsManager.command.value, contains(song1.path));

        // 2. Add via pathsManager updates audiosManager as well
        await pathsManager.command.runAsync(
          PlaylistChange(
            id: PageIDs.likedAudios,
            action: PlaylistAction.addTo,
            audios: [song2],
          ),
        );

        await pumpEventQueue();
        expect(pathsManager.command.value, contains(song2.path));
        expect(audiosManager.command.value, contains(song2));
      },
    );
  });

  group('EpisodesManager chunking & pagination', () {
    const feedUrl = 'https://example.com/podcast.xml';
    late FakePodcastManagerForEpisodes fakePodcastManager;
    late FakePlayerManagerForEpisodes fakePlayerManager;
    late FakeDownloadManagerForEpisodes fakeDownloadManager;
    late List<Audio> mockEpisodes;

    setUp(() {
      GetIt.I.registerFactoryParam<PodcastShortInfoManager, String, void>(
        (url, _) => FakePodcastShortInfoManagerForEpisodes(),
      );

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

      fakePodcastManager = FakePodcastManagerForEpisodes();
      fakePodcastManager.episodesToReturn = mockEpisodes;
      fakePlayerManager = FakePlayerManagerForEpisodes();
      fakeDownloadManager = FakeDownloadManagerForEpisodes();
    });

    Future<void> waitForCommand(EpisodesManager manager) async {
      await pumpEventQueue();
      while (manager.command.isRunning.value) {
        await pumpEventQueue();
      }
    }

    test('initially loads only pageSize episodes into command.value', () async {
      final manager = EpisodesManager.create(
        feedUrl: feedUrl,
        podcastManager: fakePodcastManager,
        downloadsManager: fakeDownloadManager,
        playerManager: fakePlayerManager,
      );

      await waitForCommand(manager);

      expect(manager.command.value, isNotNull);
      expect(
        manager.command.value!.episodes?.length,
        equals(EpisodesManager.pageSize),
      );
      expect(manager.displayedCount.value, equals(EpisodesManager.pageSize));
      expect(manager.totalCount, equals(60));
      expect(manager.hasMore, isTrue);
      expect(manager.allFilteredEpisodes.length, equals(60));
    });

    test(
      'loadMore increments displayedCount and updates command.value synchronously',
      () async {
        final manager = EpisodesManager.create(
          feedUrl: feedUrl,
          podcastManager: fakePodcastManager,
          downloadsManager: fakeDownloadManager,
          playerManager: fakePlayerManager,
        );

        await waitForCommand(manager);

        // First loadMore: 25 -> 50
        manager.loadMore();
        expect(manager.displayedCount.value, equals(50));
        expect(manager.command.value!.episodes?.length, equals(50));
        expect(manager.hasMore, isTrue);

        // Second loadMore: 50 -> 60 (clamped to total 60)
        manager.loadMore();
        expect(manager.displayedCount.value, equals(60));
        expect(manager.command.value!.episodes?.length, equals(60));
        expect(manager.hasMore, isFalse);

        // Third loadMore when !hasMore: no-op
        manager.loadMore();
        expect(manager.displayedCount.value, equals(60));
        expect(manager.command.value!.episodes?.length, equals(60));
        expect(manager.hasMore, isFalse);
      },
    );

    test('search query reset restores displayedCount to pageSize', () async {
      final manager = EpisodesManager.create(
        feedUrl: feedUrl,
        podcastManager: fakePodcastManager,
        downloadsManager: fakeDownloadManager,
        playerManager: fakePlayerManager,
      );

      await waitForCommand(manager);

      // Expand to 50
      manager.loadMore();
      expect(manager.displayedCount.value, equals(50));

      // Setting search query triggers _resetPaging and re-runs command
      manager.setSearchQuery('Episode 1');
      await waitForCommand(manager);

      expect(manager.displayedCount.value, equals(EpisodesManager.pageSize));
      expect(manager.totalCount, lessThan(60));
    });

    test('changing filter type restores displayedCount to pageSize', () async {
      final manager = EpisodesManager.create(
        feedUrl: feedUrl,
        podcastManager: fakePodcastManager,
        downloadsManager: fakeDownloadManager,
        playerManager: fakePlayerManager,
      );

      await waitForCommand(manager);

      manager.loadMore();
      expect(manager.displayedCount.value, equals(50));

      manager.setFilter();
      await waitForCommand(manager);

      expect(manager.displayedCount.value, equals(EpisodesManager.pageSize));
    });
  });
}
