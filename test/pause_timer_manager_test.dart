import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/player/data/player_change.dart';
import 'package:musicpod/player/manager/pause_timer_manager.dart';

import 'package:musicpod/player/service/player_service.dart';

import 'mpv_metadata_manager_test.mocks.dart';

void main() {
  group('PauseTimerManager', () {
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
      when(mockPlayerService.timer).thenReturn(null);

      GetIt.I.registerSingleton<PlayerService>(mockPlayerService);

      container = ProviderContainer();
    });

    tearDown(() async {
      container.dispose();
      await changesController.close();
      await GetIt.I.popScope();
    });

    test('initial state is false when timer is null', () {
      final state = container.read(pauseTimerManagerProvider);
      expect(state, isFalse);
    });

    test('initial state is true when timer is active', () {
      final timer = Timer(const Duration(minutes: 5), () {});
      addTearDown(timer.cancel);
      when(mockPlayerService.timer).thenReturn(timer);

      final customContainer = ProviderContainer();

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

    test('updates state on TimerChange event directly from payload', () async {
      expect(container.read(pauseTimerManagerProvider), isFalse);

      changesController.add(const TimerChange(true));
      await pumpEventQueue();

      expect(container.read(pauseTimerManagerProvider), isTrue);
    });
  });
}
