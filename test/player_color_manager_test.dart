import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/player/data/player_change.dart';
import 'package:musicpod/player/manager/player_color_manager.dart';

import 'mpv_metadata_manager_test.mocks.dart';

void main() {
  group('PlayerColorManager', () {
    late MockPlayerService mockPlayerService;
    late StreamController<PlayerChange> changesController;
    late ProviderContainer container;

    const testColor = Colors.blue;

    setUp(() async {
      await GetIt.I.reset();
      mockPlayerService = MockPlayerService();
      changesController = StreamController<PlayerChange>.broadcast();

      when(mockPlayerService.changes)
          .thenAnswer((_) => changesController.stream);
      when(mockPlayerService.color).thenReturn(testColor);

      container = ProviderContainer(
        overrides: [
          playerColorManagerProvider.overrideWith(
            () => PlayerColorManager(playerService: mockPlayerService),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await changesController.close();
      await GetIt.I.reset();
    });

    test('initial state reads color from PlayerService', () {
      expect(container.read(playerColorManagerProvider), testColor);
    });

    test('setRemoteColorFromImageProvider delegates to PlayerService', () async {
      when(mockPlayerService.setRemoteColorFromImageProvider(any))
          .thenAnswer((_) async {});

      const provider = NetworkImage('https://example.com/cover.jpg');
      await container
          .read(playerColorManagerProvider.notifier)
          .setRemoteColorFromImageProvider(provider);

      verify(mockPlayerService.setRemoteColorFromImageProvider(provider))
          .called(1);
    });

    test('updates state on ColorChange event', () async {
      expect(container.read(playerColorManagerProvider), testColor);

      const newColor = Colors.red;
      changesController.add(const ColorChange(newColor));
      await pumpEventQueue();

      expect(container.read(playerColorManagerProvider), newColor);
    });

    test('ignores unrelated PlayerChange events', () async {
      expect(container.read(playerColorManagerProvider), testColor);

      changesController.add(const ShuffleChange(true));
      await pumpEventQueue();

      expect(container.read(playerColorManagerProvider), testColor);
    });

    test('defaults to null when PlayerService is not registered', () {
      final emptyContainer = ProviderContainer();
      expect(emptyContainer.read(playerColorManagerProvider), isNull);
      emptyContainer.dispose();
    });
  });
}
