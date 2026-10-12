import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/player/manager/pause_timer_manager.dart';

import 'mpv_metadata_manager_test.mocks.dart';

void main() {
  group('PauseTimerManager', () {
    late MockPlayerService mockPlayerService;
    late StreamController<bool> propertiesChangedController;
    late ProviderContainer container;

    setUp(() async {
      await GetIt.I.reset();
      mockPlayerService = MockPlayerService();
      propertiesChangedController = StreamController<bool>.broadcast();

      when(mockPlayerService.propertiesChanged)
          .thenAnswer((_) => propertiesChangedController.stream);
      when(mockPlayerService.timer).thenReturn(null);

      container = ProviderContainer(
        overrides: [
          pauseTimerManagerProvider.overrideWith(
            () => PauseTimerManager(playerService: mockPlayerService),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await propertiesChangedController.close();
      await GetIt.I.reset();
    });

    test('initial state is false when timer is null', () {
      final state = container.read(pauseTimerManagerProvider);
      expect(state, isFalse);
    });

    test('initial state is true when timer is active', () {
      final timer = Timer(const Duration(minutes: 5), () {});
      addTearDown(timer.cancel);
      when(mockPlayerService.timer).thenReturn(timer);

      final customContainer = ProviderContainer(
        overrides: [
          pauseTimerManagerProvider.overrideWith(
            () => PauseTimerManager(playerService: mockPlayerService),
          ),
        ],
      );

      final state = customContainer.read(pauseTimerManagerProvider);
      expect(state, isTrue);

      customContainer.dispose();
    });

    test('setTimer sets timer on PlayerService and updates state', () {
      final timer = Timer(const Duration(minutes: 10), () {});
      addTearDown(timer.cancel);

      when(
        mockPlayerService.setPauseTimer(
          const Duration(minutes: 10),
          message: 'Paused',
        ),
      ).thenAnswer((_) {
        when(mockPlayerService.timer).thenReturn(timer);
      });

      final manager = container.read(pauseTimerManagerProvider.notifier);
      manager.setTimer(const Duration(minutes: 10), message: 'Paused');

      verify(
        mockPlayerService.setPauseTimer(
          const Duration(minutes: 10),
          message: 'Paused',
        ),
      ).called(1);

      expect(container.read(pauseTimerManagerProvider), isTrue);
    });

    test('setTimer with null cancels timer on PlayerService', () {
      when(
        mockPlayerService.setPauseTimer(null, message: 'Cancelled'),
      ).thenAnswer((_) {
        when(mockPlayerService.timer).thenReturn(null);
      });

      final manager = container.read(pauseTimerManagerProvider.notifier);
      manager.setTimer(null, message: 'Cancelled');

      verify(
        mockPlayerService.setPauseTimer(null, message: 'Cancelled'),
      ).called(1);

      expect(container.read(pauseTimerManagerProvider), isFalse);
    });

    test('updates state on propertiesChanged stream event', () async {
      expect(container.read(pauseTimerManagerProvider), isFalse);

      final timer = Timer(const Duration(minutes: 1), () {});
      addTearDown(timer.cancel);
      when(mockPlayerService.timer).thenReturn(timer);

      propertiesChangedController.add(true);
      await pumpEventQueue();

      expect(container.read(pauseTimerManagerProvider), isTrue);
    });

    test('gracefully defaults to false when PlayerService is not registered', () {
      final emptyContainer = ProviderContainer();
      final state = emptyContainer.read(pauseTimerManagerProvider);
      expect(state, isFalse);
      emptyContainer.dispose();
    });
  });
}
