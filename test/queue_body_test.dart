import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/common/view/progress.dart';
import 'package:musicpod/l10n/app_localizations.dart';
import 'package:musicpod/player/data/player_change.dart';
import 'package:musicpod/player/data/queue.dart';
import 'package:musicpod/player/service/player_service.dart';
import 'package:musicpod/player/view/queue/queue_body.dart';
import 'package:musicpod/settings/service/settings_service.dart';

import 'mpv_metadata_manager_test.mocks.dart';

void main() {
  group('QueueBody widget', () {
    late MockPlayerService mockPlayerService;
    late MockSettingsService mockSettingsService;
    late StreamController<PlayerChange> changesController;

    setUp(() async {
      await GetIt.I.reset();
      mockPlayerService = MockPlayerService();
      mockSettingsService = MockSettingsService();
      changesController = StreamController<PlayerChange>.broadcast();

      when(
        mockPlayerService.changes,
      ).thenAnswer((_) => changesController.stream);
      when(mockPlayerService.audio).thenReturn(null);
      when(mockPlayerService.queue).thenReturn(const Queue.empty());

      when(mockSettingsService.getInt(any)).thenReturn(0);
      when(mockSettingsService.getBool(any)).thenReturn(false);
      when(mockSettingsService.getString(any)).thenReturn(null);

      GetIt.I.registerSingleton<PlayerService>(mockPlayerService);
      GetIt.I.registerSingleton<SettingsService>(mockSettingsService);
    });

    tearDown(() async {
      await changesController.close();
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
      when(mockPlayerService.audio).thenReturn(audio1);
      when(mockPlayerService.queue).thenReturn(queue);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: QueueBody()),
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

    testWidgets('track transition does not show spinner or drop list opacity', (
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
      when(mockPlayerService.audio).thenReturn(audio1);
      when(mockPlayerService.queue).thenReturn(queue);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: QueueBody()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Simulate track change to song 2
      when(mockPlayerService.audio).thenReturn(audio2);
      changesController.add(const AudioChange(audio2));

      // Advance frames during jump transition
      await tester.pump();

      // Spinner must NOT be shown between tracks
      expect(find.byType(Progress), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pumpAndSettle();
      expect(find.byType(Progress), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
