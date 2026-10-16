import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/player/data/player_change.dart';
import 'package:musicpod/player/manager/current_audio_manager.dart';
import 'package:musicpod/player/service/player_service.dart';

import 'mpv_metadata_manager_test.mocks.dart';

void main() {
  group('CurrentAudioManager', () {
    late MockPlayerService mockPlayerService;
    late StreamController<PlayerChange> changesController;
    late ProviderContainer container;

    const testAudio = Audio(
      title: 'Test Song',
      artist: 'Test Artist',
      url: 'file:///path/to/test.mp3',
      audioType: AudioType.local,
    );

    setUp(() {
      GetIt.I.pushNewScope();
      mockPlayerService = MockPlayerService();
      changesController = StreamController<PlayerChange>.broadcast();

      when(
        mockPlayerService.changes,
      ).thenAnswer((_) => changesController.stream);
      when(mockPlayerService.audio).thenReturn(testAudio);

      GetIt.I.registerSingleton<PlayerService>(mockPlayerService);

      container = ProviderContainer();
    });

    tearDown(() async {
      container.dispose();
      await changesController.close();
      await GetIt.I.popScope();
    });

    test('initial state reads audio from PlayerService', () {
      expect(container.read(currentAudioManagerProvider), testAudio);
    });

    test('play delegates to PlayerService', () async {
      when(
        mockPlayerService.play(
          audios: anyNamed('audios'),
          listName: anyNamed('listName'),
          index: anyNamed('index'),
        ),
      ).thenAnswer((_) async {});

      await container
          .read(currentAudioManagerProvider.notifier)
          .play(audios: [testAudio], listName: 'Test Queue', index: 0);

      verify(
        mockPlayerService.play(
          audios: [testAudio],
          listName: 'Test Queue',
          index: 0,
        ),
      ).called(1);
    });

    test('safeCurrentAudioPosition delegates to PlayerService', () async {
      when(
        mockPlayerService.safeCurrentAudioPosition(),
      ).thenAnswer((_) async {});

      await container
          .read(currentAudioManagerProvider.notifier)
          .safeCurrentAudioPosition();

      verify(mockPlayerService.safeCurrentAudioPosition()).called(1);
    });

    test('updates state on AudioChange event', () async {
      expect(container.read(currentAudioManagerProvider), testAudio);

      const newAudio = Audio(
        title: 'New Song',
        artist: 'New Artist',
        url: 'file:///path/to/new.mp3',
        audioType: AudioType.local,
      );

      changesController.add(const AudioChange(newAudio));
      await pumpEventQueue();

      expect(container.read(currentAudioManagerProvider), newAudio);
    });

    test('ignores unrelated PlayerChange events', () async {
      expect(container.read(currentAudioManagerProvider), testAudio);

      changesController.add(const IsPlayingChange(true));
      await pumpEventQueue();

      expect(container.read(currentAudioManagerProvider), testAudio);
    });
  });
}
