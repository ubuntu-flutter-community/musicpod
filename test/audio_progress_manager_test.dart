import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/player/data/player_change.dart';
import 'package:musicpod/player/manager/audio_progress_manager.dart';

import 'package:musicpod/player/service/player_service.dart';

import 'mpv_metadata_manager_test.mocks.dart';

void main() {
  group('AudioProgressManager', () {
    late MockPlayerService mockPlayerService;
    late StreamController<PlayerChange> changesController;
    late ProviderContainer container;

    setUp(() {
      GetIt.I.pushNewScope();
      mockPlayerService = MockPlayerService();
      changesController = StreamController<PlayerChange>.broadcast();

      when(
        mockPlayerService.changes,
      ).thenAnswer((_) => changesController.stream);
      when(mockPlayerService.lastPositions).thenReturn({});

      GetIt.I.registerSingleton<PlayerService>(mockPlayerService);

      container = ProviderContainer();
    });

    tearDown(() async {
      container.dispose();
      await changesController.close();
      await GetIt.I.popScope();
    });

    test('initial state reads lastPositions from PlayerService', () {
      when(
        mockPlayerService.lastPositions,
      ).thenReturn({'url1': const Duration(seconds: 10)});

      final customContainer = ProviderContainer();

      final state = customContainer.read(audioProgressManagerProvider);
      expect(state.lastPositions, {'url1': const Duration(seconds: 10)});
      expect(state.isToggling, isFalse);
      expect(state.hasMissingDuration, isFalse);

      customContainer.dispose();
    });

    test('toggleAudiosProgress with complete duration updates state', () async {
      const audio = Audio(
        url: 'http://test.mp3',
        title: 'Episode 1',
        audioType: AudioType.podcast,
        durationMs: 60000,
      );

      when(
        mockPlayerService.toggleAudiosProgress([audio], markComplete: true),
      ).thenAnswer((_) async {});
      when(
        mockPlayerService.lastPositions,
      ).thenReturn({'http://test.mp3': const Duration(seconds: 60)});

      final manager = container.read(audioProgressManagerProvider.notifier);
      await manager.toggleAudiosProgress(audios: [audio], markComplete: true);

      verify(
        mockPlayerService.toggleAudiosProgress([audio], markComplete: true),
      ).called(1);

      final state = container.read(audioProgressManagerProvider);
      expect(state.hasMissingDuration, isFalse);
      expect(state.isToggling, isFalse);
      expect(
        state.lastPositions['http://test.mp3'],
        const Duration(seconds: 60),
      );
    });

    test(
      'toggleAudiosProgress with missing duration sets hasMissingDuration true',
      () async {
        const audio = Audio(
          url: 'http://test.mp3',
          title: 'Episode 1',
          audioType: AudioType.podcast,
          durationMs: null,
        );

        when(
          mockPlayerService.toggleAudiosProgress([audio], markComplete: true),
        ).thenAnswer((_) async {});
        when(mockPlayerService.lastPositions).thenReturn({});

        final manager = container.read(audioProgressManagerProvider.notifier);
        await manager.toggleAudiosProgress(audios: [audio], markComplete: true);

        final state = container.read(audioProgressManagerProvider);
        expect(state.hasMissingDuration, isTrue);
        expect(state.isToggling, isFalse);
      },
    );

    test(
      'toggleAudiosProgress with markComplete false sets hasMissingDuration false',
      () async {
        const audio = Audio(
          url: 'http://test.mp3',
          title: 'Episode 1',
          audioType: AudioType.podcast,
          durationMs: null,
        );

        when(
          mockPlayerService.toggleAudiosProgress([audio], markComplete: false),
        ).thenAnswer((_) async {});
        when(mockPlayerService.lastPositions).thenReturn({});

        final manager = container.read(audioProgressManagerProvider.notifier);
        await manager.toggleAudiosProgress(
          audios: [audio],
          markComplete: false,
        );

        final state = container.read(audioProgressManagerProvider);
        expect(state.hasMissingDuration, isFalse);
        expect(state.isToggling, isFalse);
      },
    );

    test(
      'clearAll delegates to playerService and empties lastPositions',
      () async {
        when(
          mockPlayerService.clearAllLastPositions(),
        ).thenAnswer((_) async {});

        final manager = container.read(audioProgressManagerProvider.notifier);
        await manager.clearAll();

        verify(mockPlayerService.clearAllLastPositions()).called(1);
        final state = container.read(audioProgressManagerProvider);
        expect(state.lastPositions, isEmpty);
      },
    );

    test('updates lastPositions on LastPositionsChange event', () async {
      expect(
        container.read(audioProgressManagerProvider).lastPositions,
        isEmpty,
      );

      changesController.add(
        const LastPositionsChange({'url2': Duration(seconds: 45)}),
      );
      await pumpEventQueue();

      final state = container.read(audioProgressManagerProvider);
      expect(state.lastPositions, {'url2': const Duration(seconds: 45)});
    });
  });
}
