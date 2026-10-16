import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/player/data/player_change.dart';
import 'package:musicpod/player/data/queue.dart';
import 'package:musicpod/player/manager/queue_manager.dart';

import 'package:musicpod/player/service/player_service.dart';

import 'mpv_metadata_manager_test.mocks.dart';

void main() {
  group('QueueManager', () {
    late MockPlayerService mockPlayerService;
    late StreamController<PlayerChange> changesController;
    late ProviderContainer container;

    const testAudio1 = Audio(
      title: 'Song 1',
      url: 'file:///song1.mp3',
      audioType: AudioType.local,
    );
    const testAudio2 = Audio(
      title: 'Song 2',
      url: 'file:///song2.mp3',
      audioType: AudioType.local,
    );
    const initialQueue = Queue(
      name: 'Test Queue',
      audios: [testAudio1, testAudio2],
    );

    setUp(() {
      GetIt.I.pushNewScope();
      mockPlayerService = MockPlayerService();
      changesController = StreamController<PlayerChange>.broadcast();

      when(
        mockPlayerService.changes,
      ).thenAnswer((_) => changesController.stream);
      when(mockPlayerService.queue).thenReturn(initialQueue);

      GetIt.I.registerSingleton<PlayerService>(mockPlayerService);

      container = ProviderContainer();
    });

    tearDown(() async {
      container.dispose();
      await changesController.close();
      await GetIt.I.popScope();
    });

    test('initial state reads queue from PlayerService', () {
      expect(container.read(queueManagerProvider), initialQueue);
    });

    test('clearQueue delegates to PlayerService', () {
      container.read(queueManagerProvider.notifier).clearQueue();
      verify(mockPlayerService.clearQueue()).called(1);
    });

    test('insertIntoQueue delegates to PlayerService', () async {
      when(mockPlayerService.insertIntoQueue(any)).thenAnswer((_) async {});

      await container.read(queueManagerProvider.notifier).insertIntoQueue([
        testAudio1,
      ]);
      verify(mockPlayerService.insertIntoQueue([testAudio1])).called(1);
    });

    test('moveAudioInQueue delegates to PlayerService', () async {
      when(
        mockPlayerService.moveAudioInQueue(any, any),
      ).thenAnswer((_) async {});

      await container
          .read(queueManagerProvider.notifier)
          .moveAudioInQueue(0, 1);
      verify(mockPlayerService.moveAudioInQueue(0, 1)).called(1);
    });

    test('remove delegates to PlayerService', () async {
      when(mockPlayerService.remove(any)).thenAnswer((_) async {});

      await container.read(queueManagerProvider.notifier).remove(testAudio1);
      verify(mockPlayerService.remove(testAudio1)).called(1);
    });

    test('playNext delegates to PlayerService', () async {
      when(mockPlayerService.playNext()).thenAnswer((_) async {});

      await container.read(queueManagerProvider.notifier).playNext();
      verify(mockPlayerService.playNext()).called(1);
    });

    test('playPrevious delegates to PlayerService', () async {
      when(mockPlayerService.playPrevious()).thenAnswer((_) async {});

      await container.read(queueManagerProvider.notifier).playPrevious();
      verify(mockPlayerService.playPrevious()).called(1);
    });

    test('updates state on QueueChange event', () async {
      expect(container.read(queueManagerProvider), initialQueue);

      const newQueue = Queue(name: 'Updated Queue', audios: [testAudio2]);
      changesController.add(const QueueChange(newQueue));
      await pumpEventQueue();

      expect(container.read(queueManagerProvider), newQueue);
    });

    test('ignores unrelated PlayerChange events', () async {
      expect(container.read(queueManagerProvider), initialQueue);

      changesController.add(const ShuffleChange(true));
      await pumpEventQueue();

      expect(container.read(queueManagerProvider), initialQueue);
    });
  });
}
