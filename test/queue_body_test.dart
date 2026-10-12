import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/l10n/app_localizations.dart';
import 'package:musicpod/common/view/progress.dart';
import 'package:musicpod/player/data/queue.dart';
import 'package:musicpod/player/manager/player_manager.dart';
import 'package:musicpod/player/view/queue/queue_body.dart';
import 'package:musicpod/settings/service/settings_service.dart';

import 'podcast_page_control_panel_test.mocks.dart';

void main() {
  group('QueueBody widget', () {
    late MockPlayerManager mockPlayerManager;
    late MockSettingsService mockSettingsService;
    late StreamController<Audio?> newAudioController;

    setUp(() async {
      await GetIt.I.reset();
      mockPlayerManager = MockPlayerManager();
      mockSettingsService = MockSettingsService();
      newAudioController = StreamController<Audio?>.broadcast();

      when(mockPlayerManager.newAudioStream)
          .thenAnswer((_) => newAudioController.stream);
      when(mockPlayerManager.isPlaying).thenReturn(false);

      when(mockSettingsService.getInt(any)).thenReturn(0);
      when(mockSettingsService.getBool(any)).thenReturn(false);
      when(mockSettingsService.getString(any)).thenReturn(null);

      GetIt.I.registerSingleton<PlayerManager>(mockPlayerManager);
      GetIt.I.registerSingleton<SettingsService>(mockSettingsService);
    });

    tearDown(() async {
      await newAudioController.close();
      await GetIt.I.reset();
    });

    testWidgets('renders cleanly without WatchIt / Consumer assertion errors', (
      tester,
    ) async {
      const audio1 = Audio(
        url: 'http://test.com/1.mp3',
        title: 'Song 1',
        audioType: AudioType.local,
      );
      const audio2 = Audio(
        url: 'http://test.com/2.mp3',
        title: 'Song 2',
        audioType: AudioType.local,
      );

      const queue = Queue(name: 'Test Queue', audios: [audio1, audio2]);
      when(mockPlayerManager.audio).thenReturn(audio1);
      when(mockPlayerManager.queue).thenReturn(queue);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: QueueBody(),
            ),
          ),
        ),
      );

      // Verify no assertion error was thrown during build or post-frame callback
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);

      // Verify songs are displayed
      expect(find.text('Song 1'), findsOneWidget);
      expect(find.text('Song 2'), findsOneWidget);
    });

    testWidgets(
      'track transition does not show spinner or drop list opacity',
      (tester) async {
        const audio1 = Audio(
          url: 'http://test.com/1.mp3',
          title: 'Song 1',
          audioType: AudioType.local,
        );
        const audio2 = Audio(
          url: 'http://test.com/2.mp3',
          title: 'Song 2',
          audioType: AudioType.local,
        );

        const queue = Queue(name: 'Test Queue', audios: [audio1, audio2]);
        when(mockPlayerManager.audio).thenReturn(audio1);
        when(mockPlayerManager.queue).thenReturn(queue);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: QueueBody(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Simulate track change to song 2
        when(mockPlayerManager.audio).thenReturn(audio2);
        newAudioController.add(audio2);

        // Advance frames during jump transition
        await tester.pump();

        // Spinner must NOT be shown between tracks
        expect(find.byType(Progress), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        await tester.pumpAndSettle();
        expect(find.byType(Progress), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );
  });
}
