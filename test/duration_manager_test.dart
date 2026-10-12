import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/player/data/player_change.dart';
import 'package:musicpod/player/manager/duration_manager.dart';

import 'mpv_metadata_manager_test.mocks.dart';

void main() {
  group('DurationManager', () {
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
      when(mockPlayerService.duration).thenReturn(const Duration(minutes: 3));

      container = ProviderContainer(
        overrides: [
          durationManagerProvider.overrideWith(
            () => DurationManager(playerService: mockPlayerService),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await changesController.close();
      await GetIt.I.reset();
    });

    test('initial state reads duration from PlayerService', () {
      expect(
        container.read(durationManagerProvider),
        const Duration(minutes: 3),
      );
    });

    test('updates state on DurationChange event', () async {
      expect(
        container.read(durationManagerProvider),
        const Duration(minutes: 3),
      );

      changesController.add(const DurationChange(Duration(minutes: 4)));
      await pumpEventQueue();

      expect(
        container.read(durationManagerProvider),
        const Duration(minutes: 4),
      );
    });

    test('ignores unrelated PlayerChange events', () async {
      expect(
        container.read(durationManagerProvider),
        const Duration(minutes: 3),
      );

      changesController.add(const ShuffleChange(true));
      await pumpEventQueue();

      expect(
        container.read(durationManagerProvider),
        const Duration(minutes: 3),
      );
    });

    test('defaults to null when PlayerService is not registered', () {
      final emptyContainer = ProviderContainer();
      expect(emptyContainer.read(durationManagerProvider), isNull);
      emptyContainer.dispose();
    });
  });
}
