import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:media_kit/media_kit.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/player/data/player_change.dart';
import 'package:musicpod/player/manager/playlist_mode_manager.dart';

import 'package:musicpod/player/service/player_service.dart';

import 'mpv_metadata_manager_test.mocks.dart';

void main() {
  group('PlaylistModeManager', () {
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
      when(mockPlayerService.playlistMode).thenReturn(PlaylistMode.none);

      GetIt.I.registerSingleton<PlayerService>(mockPlayerService);

      container = ProviderContainer();
    });

    tearDown(() async {
      container.dispose();
      await changesController.close();
      await GetIt.I.popScope();
    });

    test('initial state reads playlistMode from PlayerService', () {
      expect(container.read(playlistModeManagerProvider), PlaylistMode.none);
    });

    test('cycle calls setPlaylistMode on PlayerService', () {
      container.read(playlistModeManagerProvider.notifier).cycle();
      verify(mockPlayerService.setPlaylistMode()).called(1);
    });

    test(
      'updates state on PlaylistModeChange event directly from payload',
      () async {
        expect(container.read(playlistModeManagerProvider), PlaylistMode.none);

        changesController.add(const PlaylistModeChange(PlaylistMode.loop));
        await pumpEventQueue();

        expect(container.read(playlistModeManagerProvider), PlaylistMode.loop);
      },
    );

    test('ignores unrelated PlayerChange events like PositionChange', () async {
      expect(container.read(playlistModeManagerProvider), PlaylistMode.none);

      changesController.add(const PositionChange(Duration(seconds: 10)));
      await pumpEventQueue();

      expect(container.read(playlistModeManagerProvider), PlaylistMode.none);
    });
  });
}
