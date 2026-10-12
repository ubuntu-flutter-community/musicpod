import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/player/data/player_change.dart';
import 'package:musicpod/player/manager/position_manager.dart';

import 'mpv_metadata_manager_test.mocks.dart';

void main() {
  group('PositionManager', () {
    late MockPlayerService mockPlayerService;
    late StreamController<PlayerChange> changesController;
    late ProviderContainer container;

    setUp(() async {
      await GetIt.I.reset();
      mockPlayerService = MockPlayerService();
      changesController = StreamController<PlayerChange>.broadcast();

      when(mockPlayerService.changes)
          .thenAnswer((_) => changesController.stream);
      when(mockPlayerService.position).thenReturn(const Duration(seconds: 10));

      container = ProviderContainer(
        overrides: [
          positionManagerProvider.overrideWith(
            () => PositionManager(playerService: mockPlayerService),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await changesController.close();
      await GetIt.I.reset();
    });

    test('initial state reads position value from PlayerService', () {
      expect(container.read(positionManagerProvider), const Duration(seconds: 10));
    });

    test('seek delegates to PlayerService', () async {
      when(mockPlayerService.seek(any)).thenAnswer((_) async {});

      await container
          .read(positionManagerProvider.notifier)
          .seek(const Duration(seconds: 30));
      verify(mockPlayerService.seek(const Duration(seconds: 30))).called(1);
    });

    test('seekInSeconds advances position correctly', () async {
      when(mockPlayerService.seek(any)).thenAnswer((_) async {});

      await container
          .read(positionManagerProvider.notifier)
          .seekInSeconds(15);
      verify(mockPlayerService.seek(const Duration(seconds: 25))).called(1);
    });

    test('seekInSeconds ignores seeks that would go negative', () async {
      await container
          .read(positionManagerProvider.notifier)
          .seekInSeconds(-20);
      verifyNever(mockPlayerService.seek(any));
    });

    test('updates state on PositionChange event', () async {
      expect(container.read(positionManagerProvider), const Duration(seconds: 10));

      changesController.add(const PositionChange(Duration(seconds: 45)));
      await pumpEventQueue();

      expect(container.read(positionManagerProvider), const Duration(seconds: 45));
    });

    test('ignores unrelated PlayerChange events', () async {
      expect(container.read(positionManagerProvider), const Duration(seconds: 10));

      changesController.add(const IsPlayingChange(true));
      await pumpEventQueue();

      expect(container.read(positionManagerProvider), const Duration(seconds: 10));
    });

    test('defaults to Duration.zero when PlayerService is not registered', () {
      final emptyContainer = ProviderContainer();
      expect(emptyContainer.read(positionManagerProvider), Duration.zero);
      emptyContainer.dispose();
    });
  });
}
