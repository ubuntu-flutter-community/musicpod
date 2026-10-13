import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/app/routing_manager.dart';
import 'package:musicpod/common/view/progress.dart';
import 'package:musicpod/l10n/app_localizations.dart';
import 'package:musicpod/local_audio/data/local_audio_state.dart';
import 'package:musicpod/local_audio/manager/local_audio_manager.dart';
import 'package:musicpod/local_audio/service/local_audio_service.dart';
import 'package:musicpod/local_audio/view/local_audio_page.dart';
import 'package:musicpod/search/manager/search_manager.dart';
import 'package:musicpod/settings/data/shared_preferences_keys.dart';
import 'package:musicpod/settings/service/settings_service.dart';
import 'package:yaru/yaru.dart';

import 'local_audio_progress_test.mocks.dart';

@GenerateMocks([
  LocalAudioService,
  SettingsService,
  RoutingManager,
  SearchManager,
])
void main() {
  late MockLocalAudioService mockAudioService;
  late MockSettingsService mockSettingsService;
  late MockSearchManager mockSearchManager;

  void Function(double progress)? capturedUpdateProgress;
  Completer<({List<String> failedImports})>? initCompleter;

  void setupMockAudioService() {
    when(
      mockAudioService.init(
        newDirectory: anyNamed('newDirectory'),
        forceInit: anyNamed('forceInit'),
        updateProgress: anyNamed('updateProgress'),
      ),
    ).thenAnswer((invocation) {
      capturedUpdateProgress =
          invocation.namedArguments[#updateProgress]
              as void Function(double progress)?;
      initCompleter = Completer<({List<String> failedImports})>();
      return initCompleter!.future;
    });

    when(mockAudioService.areTracksSynced()).thenAnswer((_) async => true);
    when(mockAudioService.findAllTracks()).thenAnswer((_) async => const []);
    when(mockAudioService.findAllAlbumIDs()).thenAnswer((_) async => const []);
    when(mockAudioService.findAllArtists()).thenAnswer((_) async => const []);
    when(mockAudioService.findAllGenres()).thenAnswer((_) async => const []);
    when(
      mockAudioService.findAllPlaylistIDs(),
    ).thenAnswer((_) async => const []);
  }

  void setupMockSettingsService() {
    when(mockSettingsService.getInt(any)).thenReturn(0);
    when(mockSettingsService.getBool(any)).thenReturn(false);
    when(mockSettingsService.getString(any)).thenReturn(null);
  }

  setUp(() async {
    await GetIt.I.reset();
    mockAudioService = MockLocalAudioService();
    mockSettingsService = MockSettingsService();
    mockSearchManager = MockSearchManager();
    setupMockAudioService();
    setupMockSettingsService();

    GetIt.I.registerSingleton<LocalAudioService>(mockAudioService);
    GetIt.I.registerSingleton<SettingsService>(mockSettingsService);
    GetIt.I.registerSingleton<SearchManager>(mockSearchManager);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  void emitProgress(double progress) {
    capturedUpdateProgress?.call(progress);
  }

  void completeInit([List<String> failedImports = const []]) {
    if (initCompleter?.isCompleted == false) {
      initCompleter!.complete((failedImports: failedImports));
    }
  }

  group('LocalAudioManager progress tracking', () {
    test(
      'build() uses updateProgress to set AsyncLoading(progress: ...) on LocalAudioManager',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Listen to localAudioManagerProvider to trigger its build()
        final subscription = container.listen(
          localAudioManagerProvider,
          (_, __) {},
        );
        addTearDown(subscription.close);

        // Initially loading
        expect(container.read(localAudioManagerProvider).isLoading, isTrue);

        // LocalAudioService emits 0.25 progress (parsing metadata)
        emitProgress(0.25);
        final state25 = container.read(localAudioManagerProvider);
        expect(state25, isA<AsyncLoading<LocalAudioState>>());
        expect(state25.progress, equals(0.25));

        // LocalAudioService emits 0.50 progress (persisting metadata)
        emitProgress(0.50);
        final state50 = container.read(localAudioManagerProvider);
        expect(state50, isA<AsyncLoading<LocalAudioState>>());
        expect(state50.progress, equals(0.50));

        // LocalAudioService emits 0.75 progress (building library)
        emitProgress(0.75);
        final state75 = container.read(localAudioManagerProvider);
        expect(state75, isA<AsyncLoading<LocalAudioState>>());
        expect(state75.progress, equals(0.75));

        // Completion
        completeInit();
        await pumpEventQueue();

        final stateComplete = container.read(localAudioManagerProvider);
        expect(stateComplete.isLoading, isFalse);
        expect(stateComplete.hasValue, isTrue);
        expect(stateComplete.value?.failedImports, isEmpty);
      },
    );

    test(
      'initAudios() updates AsyncLoading(progress: ...) as updateProgress fires',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final subscription = container.listen(
          localAudioManagerProvider,
          (_, __) {},
        );
        addTearDown(subscription.close);

        // Complete initial build
        emitProgress(1.0);
        completeInit();
        await pumpEventQueue();

        expect(container.read(localAudioManagerProvider).hasValue, isTrue);

        // Start initAudios
        final future = container
            .read(localAudioManagerProvider.notifier)
            .initAudios(forceInit: true);

        // Immediately in AsyncLoading with initial progress 0.0
        final initialLoading = container.read(localAudioManagerProvider);
        expect(initialLoading.isLoading, isTrue);
        expect(initialLoading.progress, equals(0.0));

        // Simulate scanning progress steps
        emitProgress(0.25);
        expect(
          container.read(localAudioManagerProvider).progress,
          equals(0.25),
        );

        emitProgress(0.50);
        expect(
          container.read(localAudioManagerProvider).progress,
          equals(0.50),
        );

        emitProgress(0.75);
        expect(
          container.read(localAudioManagerProvider).progress,
          equals(0.75),
        );

        // Complete initAudios
        completeInit();
        final result = await future;

        expect(result.failedImports, isEmpty);
        final doneState = container.read(localAudioManagerProvider);
        expect(doneState.isLoading, isFalse);
        expect(doneState.hasValue, isTrue);
      },
    );
  });

  group('LocalAudioPage UI progress updates', () {
    testWidgets(
      'UI displays updated progress value in Progress indicator and percentage label with standard theme',
      (tester) async {
        late AppLocalizations l10n;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) {
                  l10n = AppLocalizations.of(context);
                  return const LocalAudioPage();
                },
              ),
            ),
          ),
        );

        // Step 1: 25% progress
        emitProgress(0.25);
        await tester.pump();

        // Verify Progress widget receives 0.25
        final progressFinder = find.byType(Progress);
        expect(progressFinder, findsOneWidget);
        expect(tester.widget<Progress>(progressFinder).value, equals(0.25));

        // Verify CircularProgressIndicator receives 0.25
        final cpiFinder = find.byType(CircularProgressIndicator);
        expect(cpiFinder, findsOneWidget);
        expect(
          tester.widget<CircularProgressIndicator>(cpiFinder).value,
          equals(0.25),
        );

        // Verify status text shows 25% and parsing label
        expect(
          find.text('25% ... ${l10n.parsingLocalAudioFilesMetadataPleaseWait}'),
          findsOneWidget,
        );

        // Step 2: 50% progress
        emitProgress(0.50);
        await tester.pump();

        expect(tester.widget<Progress>(progressFinder).value, equals(0.50));
        expect(
          tester.widget<CircularProgressIndicator>(cpiFinder).value,
          equals(0.50),
        );
        expect(
          find.text(
            '50% ... ${l10n.persistingLocalAudioFilesMetadataPleaseWait}',
          ),
          findsOneWidget,
        );

        // Step 3: 75% progress
        emitProgress(0.75);
        await tester.pump();

        expect(tester.widget<Progress>(progressFinder).value, equals(0.75));
        expect(
          tester.widget<CircularProgressIndicator>(cpiFinder).value,
          equals(0.75),
        );
        expect(
          find.text('75% ... ${l10n.buildingLocalAudioLibraryPleaseWait}'),
          findsOneWidget,
        );

        // Step 4: Scanning completes
        completeInit();
        await tester.pumpAndSettle();

        // Progress indicator should be gone once loading finishes
        expect(find.byType(Progress), findsNothing);
      },
    );

    testWidgets(
      'UI displays updated progress value in YaruCircularProgressIndicator when useYaruTheme is true',
      (tester) async {
        when(mockSettingsService.getBool(SPKeys.useYaruTheme)).thenReturn(true);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: LocalAudioPage(),
            ),
          ),
        );

        emitProgress(0.50);
        await tester.pump();

        final yaruProgressFinder = find.byType(YaruCircularProgressIndicator);
        expect(yaruProgressFinder, findsOneWidget);
        expect(
          tester
              .widget<YaruCircularProgressIndicator>(yaruProgressFinder)
              .value,
          equals(0.50),
        );

        completeInit();
        await tester.pumpAndSettle();
      },
    );

    testWidgets('UI shows loading progress when initAudios() is retriggered', (
      tester,
    ) async {
      // Mount page and finish initial scan
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: LocalAudioPage(),
          ),
        ),
      );
      emitProgress(1.0);
      completeInit();
      await tester.pumpAndSettle();

      expect(find.byType(Progress), findsNothing);

      // Trigger initAudios via the notifier
      final container = ProviderScope.containerOf(
        tester.element(find.byType(LocalAudioPage)),
      );
      unawaited(
        container
            .read(localAudioManagerProvider.notifier)
            .initAudios(forceInit: true),
      );
      await tester.pump();

      // Shows 0.0 initially
      final progressFinder = find.byType(Progress);
      expect(progressFinder, findsOneWidget);
      expect(tester.widget<Progress>(progressFinder).value, equals(0.0));
      expect(find.textContaining('0% ...'), findsOneWidget);

      // Update to 0.50
      emitProgress(0.50);
      await tester.pump();

      expect(tester.widget<Progress>(progressFinder).value, equals(0.50));
      expect(find.textContaining('50% ...'), findsOneWidget);

      // Complete
      completeInit();
      await tester.pumpAndSettle();

      expect(find.byType(Progress), findsNothing);
    });
  });
}
