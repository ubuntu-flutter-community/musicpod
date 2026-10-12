import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/player/data/player_change.dart';
import 'package:musicpod/player/manager/rate_manager.dart';

import 'mpv_metadata_manager_test.mocks.dart';

void main() {
  group('RateManager', () {
    late MockPlayerService mockPlayerService;
    late StreamController<PlayerChange> changesController;
    late ProviderContainer container;

    setUp(() async {
      await GetIt.I.reset();
      mockPlayerService = MockPlayerService();
      changesController = StreamController<PlayerChange>.broadcast();

      when(mockPlayerService.changes)
          .thenAnswer((_) => changesController.stream);
      when(mockPlayerService.rate).thenReturn(1.0);

      container = ProviderContainer(
        overrides: [
          rateManagerProvider.overrideWith(
            () => RateManager(playerService: mockPlayerService),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await changesController.close();
      await GetIt.I.reset();
    });

    test('initial state reads rate from PlayerService', () {
      expect(container.read(rateManagerProvider), 1.0);
    });

    test('setRate delegates to PlayerService', () async {
      when(mockPlayerService.setRate(any)).thenAnswer((_) async {});

      await container.read(rateManagerProvider.notifier).setRate(1.5);
      verify(mockPlayerService.setRate(1.5)).called(1);
    });

    test('updates state on RateChange event directly from payload', () async {
      expect(container.read(rateManagerProvider), 1.0);

      changesController.add(const RateChange(1.25));
      await pumpEventQueue();

      expect(container.read(rateManagerProvider), 1.25);
    });

    test('ignores unrelated PlayerChange events like PositionChange', () async {
      expect(container.read(rateManagerProvider), 1.0);

      changesController.add(const PositionChange(Duration(seconds: 1)));
      await pumpEventQueue();

      expect(container.read(rateManagerProvider), 1.0);
    });

    test('gracefully defaults to 1.0 when PlayerService is not registered', () {
      final emptyContainer = ProviderContainer();
      expect(emptyContainer.read(rateManagerProvider), 1.0);
      emptyContainer.dispose();
    });
  });
}
