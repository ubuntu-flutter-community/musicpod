import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/player/data/player_change.dart';
import 'package:musicpod/player/manager/buffer_manager.dart';

import 'mpv_metadata_manager_test.mocks.dart';

void main() {
  group('BufferManager', () {
    late MockPlayerService mockPlayerService;
    late StreamController<PlayerChange> changesController;
    late ProviderContainer container;

    setUp(() async {
      await GetIt.I.reset();
      mockPlayerService = MockPlayerService();
      changesController = StreamController<PlayerChange>.broadcast();

      when(mockPlayerService.changes)
          .thenAnswer((_) => changesController.stream);
      when(mockPlayerService.buffer).thenReturn(const Duration(seconds: 5));

      container = ProviderContainer(
        overrides: [
          bufferManagerProvider.overrideWith(
            () => BufferManager(playerService: mockPlayerService),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await changesController.close();
      await GetIt.I.reset();
    });

    test('initial state reads buffer from PlayerService', () {
      expect(container.read(bufferManagerProvider), const Duration(seconds: 5));
    });

    test('updates state on BufferChange event', () async {
      expect(container.read(bufferManagerProvider), const Duration(seconds: 5));

      changesController.add(const BufferChange(Duration(seconds: 12)));
      await pumpEventQueue();

      expect(container.read(bufferManagerProvider), const Duration(seconds: 12));
    });

    test('ignores unrelated PlayerChange events', () async {
      expect(container.read(bufferManagerProvider), const Duration(seconds: 5));

      changesController.add(const RateChange(1.5));
      await pumpEventQueue();

      expect(container.read(bufferManagerProvider), const Duration(seconds: 5));
    });

    test('defaults to Duration.zero when PlayerService is not registered', () {
      final emptyContainer = ProviderContainer();
      expect(emptyContainer.read(bufferManagerProvider), Duration.zero);
      emptyContainer.dispose();
    });
  });
}
