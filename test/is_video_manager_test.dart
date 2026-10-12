import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/player/data/player_change.dart';
import 'package:musicpod/player/manager/is_video_manager.dart';

import 'mpv_metadata_manager_test.mocks.dart';

void main() {
  group('IsVideoManager', () {
    late MockPlayerService mockPlayerService;
    late StreamController<PlayerChange> changesController;
    late ProviderContainer container;

    setUp(() async {
      await GetIt.I.reset();
      mockPlayerService = MockPlayerService();
      changesController = StreamController<PlayerChange>.broadcast();

      when(mockPlayerService.changes)
          .thenAnswer((_) => changesController.stream);
      when(mockPlayerService.isVideo).thenReturn(false);

      container = ProviderContainer(
        overrides: [
          isVideoManagerProvider.overrideWith(
            () => IsVideoManager(playerService: mockPlayerService),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await changesController.close();
      await GetIt.I.reset();
    });

    test('initial state reads isVideo from PlayerService', () {
      expect(container.read(isVideoManagerProvider), isFalse);
    });

    test('updates state on IsVideoChange event', () async {
      expect(container.read(isVideoManagerProvider), isFalse);

      changesController.add(const IsVideoChange(true));
      await pumpEventQueue();

      expect(container.read(isVideoManagerProvider), isTrue);
    });

    test('ignores unrelated PlayerChange events', () async {
      expect(container.read(isVideoManagerProvider), isFalse);

      changesController.add(const ShuffleChange(true));
      await pumpEventQueue();

      expect(container.read(isVideoManagerProvider), isFalse);
    });

    test('defaults to false when PlayerService is not registered', () {
      final emptyContainer = ProviderContainer();
      expect(emptyContainer.read(isVideoManagerProvider), isFalse);
      emptyContainer.dispose();
    });
  });
}
