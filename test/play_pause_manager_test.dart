import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/player/data/player_change.dart';
import 'package:musicpod/player/manager/play_pause_manager.dart';

import 'mpv_metadata_manager_test.mocks.dart';

void main() {
  group('PlayPauseManager', () {
    late MockPlayerService mockPlayerService;
    late StreamController<PlayerChange> changesController;
    late ProviderContainer container;

    setUp(() async {
      await GetIt.I.reset();
      mockPlayerService = MockPlayerService();
      changesController = StreamController<PlayerChange>.broadcast();

      when(mockPlayerService.changes)
          .thenAnswer((_) => changesController.stream);
      when(mockPlayerService.isPlaying).thenReturn(false);

      container = ProviderContainer(
        overrides: [
          playPauseManagerProvider.overrideWith(
            () => PlayPauseManager(playerService: mockPlayerService),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await changesController.close();
      await GetIt.I.reset();
    });

    test('initial state reads isPlaying value from PlayerService', () {
      expect(container.read(playPauseManagerProvider), isFalse);
    });

    test('playOrPause delegates to PlayerService', () async {
      when(mockPlayerService.playOrPause()).thenAnswer((_) async {});

      await container.read(playPauseManagerProvider.notifier).playOrPause();
      verify(mockPlayerService.playOrPause()).called(1);
    });

    test('pause delegates to PlayerService', () async {
      when(mockPlayerService.pause()).thenAnswer((_) async {});

      await container.read(playPauseManagerProvider.notifier).pause();
      verify(mockPlayerService.pause()).called(1);
    });

    test('resume delegates to PlayerService', () async {
      when(mockPlayerService.resume()).thenAnswer((_) async {});

      await container.read(playPauseManagerProvider.notifier).resume();
      verify(mockPlayerService.resume()).called(1);
    });

    test('stop delegates to PlayerService', () async {
      when(mockPlayerService.stop()).thenAnswer((_) async {});

      await container.read(playPauseManagerProvider.notifier).stop();
      verify(mockPlayerService.stop()).called(1);
    });

    test('updates state on IsPlayingChange event', () async {
      expect(container.read(playPauseManagerProvider), isFalse);

      changesController.add(const IsPlayingChange(true));
      await pumpEventQueue();

      expect(container.read(playPauseManagerProvider), isTrue);
    });

    test('ignores unrelated PlayerChange events', () async {
      expect(container.read(playPauseManagerProvider), isFalse);

      changesController.add(const PositionChange(Duration(seconds: 15)));
      await pumpEventQueue();

      expect(container.read(playPauseManagerProvider), isFalse);
    });

    test('defaults to false when PlayerService is not registered', () {
      final emptyContainer = ProviderContainer();
      expect(emptyContainer.read(playPauseManagerProvider), isFalse);
      emptyContainer.dispose();
    });
  });
}
