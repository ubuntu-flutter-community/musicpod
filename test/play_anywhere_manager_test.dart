import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/app/data/play_anywhere_bad_audios_exception.dart';
import 'package:musicpod/app/data/play_anywhere_param.dart';
import 'package:musicpod/app/data/play_anywhere_result.dart';
import 'package:musicpod/app/play_anywhere_manager.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/view/audio_page_type.dart';
import 'package:musicpod/local_audio/service/local_audio_service.dart';
import 'package:musicpod/player/data/queue.dart';
import 'package:musicpod/player/manager/player_manager.dart';
import 'package:musicpod/podcasts/service/podcast_service.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/radio/manager/station_manager.dart';
import 'package:musicpod/radio/service/radio_service.dart';

import 'play_anywhere_manager_test.mocks.dart';

class FakeStationManager extends StationManager {
  FakeStationManager(this.audio);
  final Audio audio;

  @override
  Future<Audio?> build(String uuid) async => audio;
}

@GenerateMocks([PlayerManager, LocalAudioService, PodcastService, RadioService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockPlayerManager mockPlayerManager;
  late MockLocalAudioService mockLocalAudioService;
  late MockPodcastService mockPodcastService;
  late MockRadioService mockRadioService;

  const testAudio = Audio(
    path: '/path/to/test.mp3',
    title: 'Test Song',
    uuid: 'test-uuid',
    audioType: AudioType.local,
  );

  setUp(() async {
    await GetIt.I.reset();

    mockPlayerManager = MockPlayerManager();
    mockLocalAudioService = MockLocalAudioService();
    mockPodcastService = MockPodcastService();
    mockRadioService = MockRadioService();

    when(mockPlayerManager.queue).thenReturn(const Queue.empty());
    when(mockPlayerManager.isPlaying).thenReturn(false);
    when(mockPlayerManager.play(
      audios: anyNamed('audios'),
      listName: anyNamed('listName'),
    )).thenAnswer((_) async {});
    when(mockPlayerManager.pause()).thenAnswer((_) async {});
    when(mockPlayerManager.resume()).thenAnswer((_) async {});

    di.registerSingleton<PlayerManager>(mockPlayerManager);
    di.registerSingleton<LocalAudioService>(mockLocalAudioService);
    di.registerSingleton<PodcastService>(mockPodcastService);
    di.registerSingleton<RadioService>(mockRadioService);

    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('PlayAnywhereManager', () {
    test('initial state is AsyncData(null) and activeParam is null', () {
      final state = container.read(playAnywhereManagerProvider);
      expect(state, const AsyncData<PlayAnywhereResult?>(null));
      expect(container.read(playAnywhereManagerProvider.notifier).activeParam, isNull);
    });

    test('plays playlist successfully when not currently enqueued', () async {
      when(mockLocalAudioService.findPlaylistById('playlist-1'))
          .thenAnswer((_) async => [testAudio]);

      final notifier = container.read(playAnywhereManagerProvider.notifier);
      final result = await notifier.play(
        const PlayAnywhereParam(
          pageId: 'playlist-1',
          audioPageType: AudioPageType.playlist,
        ),
      );

      expect(result, isNotNull);
      expect(result!.audios, [testAudio]);
      expect(result.param.pageId, 'playlist-1');
      expect(container.read(playAnywhereManagerProvider).value, result);
      expect(notifier.activeParam, isNull);

      verify(mockPlayerManager.play(
        audios: [testAudio],
        listName: 'playlist-1',
      )).called(1);
      verifyNever(mockPlayerManager.pause());
      verifyNever(mockPlayerManager.resume());
    });

    test('pauses if playlist is already enqueued and playing', () async {
      when(mockLocalAudioService.findPlaylistById('playlist-1'))
          .thenAnswer((_) async => [testAudio]);
      when(mockPlayerManager.queue)
          .thenReturn(const Queue(name: 'playlist-1', audios: [testAudio]));
      when(mockPlayerManager.isPlaying).thenReturn(true);

      final notifier = container.read(playAnywhereManagerProvider.notifier);
      final result = await notifier.play(
        const PlayAnywhereParam(
          pageId: 'playlist-1',
          audioPageType: AudioPageType.playlist,
        ),
      );

      expect(result, isNotNull);
      verify(mockPlayerManager.pause()).called(1);
      verifyNever(mockPlayerManager.play(
        audios: anyNamed('audios'),
        listName: anyNamed('listName'),
      ));
    });

    test('resumes if playlist is already enqueued and not playing', () async {
      when(mockLocalAudioService.findPlaylistById('playlist-1'))
          .thenAnswer((_) async => [testAudio]);
      when(mockPlayerManager.queue)
          .thenReturn(const Queue(name: 'playlist-1', audios: [testAudio]));
      when(mockPlayerManager.isPlaying).thenReturn(false);

      final notifier = container.read(playAnywhereManagerProvider.notifier);
      final result = await notifier.play(
        const PlayAnywhereParam(
          pageId: 'playlist-1',
          audioPageType: AudioPageType.playlist,
        ),
      );

      expect(result, isNotNull);
      verify(mockPlayerManager.resume()).called(1);
      verifyNever(mockPlayerManager.play(
        audios: anyNamed('audios'),
        listName: anyNamed('listName'),
      ));
    });

    test('plays liked audios', () async {
      when(mockLocalAudioService.findLikedAudios())
          .thenAnswer((_) async => [testAudio]);

      final notifier = container.read(playAnywhereManagerProvider.notifier);
      final result = await notifier.play(
        const PlayAnywhereParam(
          pageId: 'liked',
          audioPageType: AudioPageType.likedAudio,
        ),
      );

      expect(result?.audios, [testAudio]);
      verify(mockPlayerManager.play(
        audios: [testAudio],
        listName: 'liked',
      )).called(1);
    });

    test('plays album', () async {
      when(mockLocalAudioService.findAlbum(42))
          .thenAnswer((_) async => [testAudio]);

      final notifier = container.read(playAnywhereManagerProvider.notifier);
      final result = await notifier.play(
        const PlayAnywhereParam(
          pageId: '42',
          audioPageType: AudioPageType.album,
        ),
      );

      expect(result?.audios, [testAudio]);
      verify(mockPlayerManager.play(
        audios: [testAudio],
        listName: '42',
      )).called(1);
    });

    test('plays artist', () async {
      when(mockLocalAudioService.findTitlesOfArtist('Artist X'))
          .thenAnswer((_) async => [testAudio]);

      final notifier = container.read(playAnywhereManagerProvider.notifier);
      final result = await notifier.play(
        const PlayAnywhereParam(
          pageId: 'Artist X',
          audioPageType: AudioPageType.artist,
        ),
      );

      expect(result?.audios, [testAudio]);
      verify(mockPlayerManager.play(
        audios: [testAudio],
        listName: 'Artist X',
      )).called(1);
    });

    test('plays podcast', () async {
      when(mockPodcastService.findEpisodes(
        feedUrl: 'https://feed.xml',
        tryFromDbOnly: true,
      )).thenAnswer((_) async => [testAudio]);

      final notifier = container.read(playAnywhereManagerProvider.notifier);
      final result = await notifier.play(
        const PlayAnywhereParam(
          pageId: 'https://feed.xml',
          audioPageType: AudioPageType.podcast,
        ),
      );

      expect(result?.audios, [testAudio]);
      verify(mockPlayerManager.play(
        audios: [testAudio],
        listName: 'https://feed.xml',
      )).called(1);
    });

    test('plays radio using stationManagerProvider override', () async {
      final customContainer = ProviderContainer(
        overrides: [
          stationManagerProvider('station-uuid')
              .overrideWith(() => FakeStationManager(testAudio)),
        ],
      );
      addTearDown(customContainer.dispose);

      final notifier = customContainer.read(playAnywhereManagerProvider.notifier);
      final result = await notifier.play(
        const PlayAnywhereParam(
          pageId: 'station-uuid',
          audioPageType: AudioPageType.radio,
        ),
      );

      expect(result?.audios, [testAudio]);
      verify(mockPlayerManager.play(
        audios: [testAudio],
        listName: 'station-uuid',
      )).called(1);
    });

    test('plays radio falling back to radioService', () async {
      when(mockRadioService.getAudioByUUID('station-uuid', fromDBOnly: false))
          .thenAnswer((_) async => testAudio);

      final notifier = container.read(playAnywhereManagerProvider.notifier);
      final result = await notifier.play(
        const PlayAnywhereParam(
          pageId: 'station-uuid',
          audioPageType: AudioPageType.radio,
        ),
      );

      expect(result?.audios, [testAudio]);
      verify(mockPlayerManager.play(
        audios: [testAudio],
        listName: 'station-uuid',
      )).called(1);
    });

    test('throws PlayAnywhereBadAudiosException when audios is empty', () async {
      when(mockLocalAudioService.findPlaylistById('empty-pl'))
          .thenAnswer((_) async => []);

      final notifier = container.read(playAnywhereManagerProvider.notifier);
      final result = await notifier.play(
        const PlayAnywhereParam(
          pageId: 'empty-pl',
          audioPageType: AudioPageType.playlist,
        ),
      );

      expect(result, isNull);
      final state = container.read(playAnywhereManagerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<PlayAnywhereBadAudiosException>());
      expect(notifier.activeParam, isNull);
      verifyNever(mockPlayerManager.play(
        audios: anyNamed('audios'),
        listName: anyNamed('listName'),
      ));
    });
  });
}
