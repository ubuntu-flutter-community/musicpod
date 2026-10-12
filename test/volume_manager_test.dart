import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/player/data/player_change.dart';
import 'package:musicpod/player/manager/volume_manager.dart';

import 'mpv_metadata_manager_test.mocks.dart';

void main() {
  group('VolumeManager', () {
    late MockPlayerService mockPlayerService;
    late StreamController<PlayerChange> changesController;
    late ProviderContainer container;

    setUp(() async {
      await GetIt.I.reset();
      mockPlayerService = MockPlayerService();
      changesController = StreamController<PlayerChange>.broadcast();

      when(
        mockPlayerService.changes,
      ).thenAnswer((_) => changesController.stream);
      when(mockPlayerService.volume).thenReturn(100.0);

      container = ProviderContainer(
        overrides: [
          volumeManagerProvider.overrideWith(
            () => VolumeManager(playerService: mockPlayerService),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await changesController.close();
      await GetIt.I.reset();
    });

    test('initial state reads volume from PlayerService', () {
      expect(container.read(volumeManagerProvider), 100.0);
    });

    test('setVolume delegates to PlayerService', () async {
      when(mockPlayerService.setVolume(any)).thenAnswer((_) async {});

      await container.read(volumeManagerProvider.notifier).setVolume(75.0);
      verify(mockPlayerService.setVolume(75.0)).called(1);
    });

    test('updates state on VolumeChange event directly from payload', () async {
      expect(container.read(volumeManagerProvider), 100.0);

      changesController.add(const VolumeChange(50.0));
      await pumpEventQueue();

      expect(container.read(volumeManagerProvider), 50.0);
    });

    test('ignores unrelated PlayerChange events like PositionChange', () async {
      expect(container.read(volumeManagerProvider), 100.0);

      changesController.add(const PositionChange(Duration(seconds: 5)));
      await pumpEventQueue();

      expect(container.read(volumeManagerProvider), 100.0);
    });

    test(
      'gracefully defaults to null when PlayerService is not registered',
      () {
        final emptyContainer = ProviderContainer();
        expect(emptyContainer.read(volumeManagerProvider), isNull);
        emptyContainer.dispose();
      },
    );
  });
}
