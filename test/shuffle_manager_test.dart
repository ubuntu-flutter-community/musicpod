import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/player/data/player_change.dart';
import 'package:musicpod/player/manager/shuffle_manager.dart';

import 'mpv_metadata_manager_test.mocks.dart';

void main() {
  group('ShuffleManager', () {
    late MockPlayerService mockPlayerService;
    late StreamController<PlayerChange> changesController;
    late ProviderContainer container;

    setUp(() async {
      await GetIt.I.reset();
      mockPlayerService = MockPlayerService();
      changesController = StreamController<PlayerChange>.broadcast();

      when(mockPlayerService.changes)
          .thenAnswer((_) => changesController.stream);
      when(mockPlayerService.shuffle).thenReturn(false);

      container = ProviderContainer(
        overrides: [
          shuffleManagerProvider.overrideWith(
            () => ShuffleManager(playerService: mockPlayerService),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await changesController.close();
      await GetIt.I.reset();
    });

    test('initial state reads shuffle value from PlayerService', () {
      expect(container.read(shuffleManagerProvider), isFalse);
    });

    test('toggle calls setShuffle with negated value', () async {
      when(mockPlayerService.setShuffle(any)).thenAnswer((_) async {});

      await container.read(shuffleManagerProvider.notifier).toggle();
      verify(mockPlayerService.setShuffle(true)).called(1);
    });

    test('setShuffle delegates directly to PlayerService', () async {
      when(mockPlayerService.setShuffle(any)).thenAnswer((_) async {});

      await container.read(shuffleManagerProvider.notifier).setShuffle(true);
      verify(mockPlayerService.setShuffle(true)).called(1);
    });

    test('updates state on ShuffleChange event directly from payload', () async {
      expect(container.read(shuffleManagerProvider), isFalse);

      changesController.add(const ShuffleChange(true));
      await pumpEventQueue();

      expect(container.read(shuffleManagerProvider), isTrue);
    });

    test('ignores unrelated PlayerChange events like PositionChange', () async {
      expect(container.read(shuffleManagerProvider), isFalse);

      changesController.add(const PositionChange(Duration(seconds: 15)));
      await pumpEventQueue();

      expect(container.read(shuffleManagerProvider), isFalse);
    });

    test('gracefully defaults to false when PlayerService is not registered', () {
      final emptyContainer = ProviderContainer();
      expect(emptyContainer.read(shuffleManagerProvider), isFalse);
      emptyContainer.dispose();
    });
  });
}
