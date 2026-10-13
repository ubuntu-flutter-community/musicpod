import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/app/view/common_handlers_and_commands.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/l10n/app_localizations.dart';
import 'package:musicpod/notifications/notifications_service.dart';
import 'package:musicpod/podcasts/data/podcast_short_info.dart';
import 'package:musicpod/podcasts/data/podcast_update_capsule.dart';
import 'package:musicpod/podcasts/manager/podcast_updates_manager.dart';
import 'package:musicpod/podcasts/service/podcast_service.dart';
import 'package:musicpod/settings/service/settings_service.dart';

import 'podcast_updates_disposal_test.mocks.dart';

class FakeNotificationsService implements NotificationsService {
  int notifyCount = 0;
  final List<String> messages = [];

  @override
  Future<void> notify({required String message}) async {
    notifyCount++;
    messages.add(message);
  }
}

class TestHostWidget extends ConsumerStatefulWidget {
  const TestHostWidget({super.key});

  @override
  ConsumerState<TestHostWidget> createState() => _TestHostWidgetState();
}

class _TestHostWidgetState extends ConsumerState<TestHostWidget>
    with CommonHandlersAndCommandsMixin {
  @override
  Widget build(BuildContext context) {
    registerCommonHandlers(context, ref);
    return const SizedBox();
  }
}

void main() {
  const feedUrl = 'https://example.com/podcast.xml';
  const episode1 = Audio(
    audioType: AudioType.podcast,
    url: 'https://example.com/ep1.mp3',
    feedUrl: feedUrl,
    title: 'Episode 1',
  );

  late MockPodcastService mockPodcastService;
  late MockSettingsService mockSettingsService;
  late FakeNotificationsService fakeNotificationsService;

  setUp(() async {
    await GetIt.I.reset();
    mockPodcastService = MockPodcastService();
    mockSettingsService = MockSettingsService();
    fakeNotificationsService = FakeNotificationsService();

    when(mockSettingsService.getInt(any)).thenReturn(0);
    when(mockSettingsService.getBool(any)).thenReturn(false);
    when(mockSettingsService.getString(any)).thenReturn(null);
    when(
      mockPodcastService.getSubscribedPodcasts(),
    ).thenAnswer((_) async => {feedUrl});
    when(mockPodcastService.getPodcastShortInfo(any)).thenAnswer(
      (_) async => const PodcastShortInfo(name: 'Tech News', artist: 'Author'),
    );

    GetIt.I.registerSingleton<PackageInfo>(
      PackageInfo(
        appName: 'musicpod',
        packageName: 'com.example.musicpod',
        version: '1.0.0',
        buildNumber: '1',
      ),
    );
    GetIt.I.registerSingleton<PodcastService>(mockPodcastService);
    GetIt.I.registerSingleton<SettingsService>(mockSettingsService);
    GetIt.I.registerSingleton<NotificationsService>(fakeNotificationsService);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets(
    'triggers notification exactly once when updates found, even across multiple rebuilds',
    (tester) async {
      when(
        mockPodcastService.checkForUpdates(
          feedUrls: anyNamed('feedUrls'),
          updateProgress: anyNamed('updateProgress'),
        ),
      ).thenAnswer(
        (_) async => {
          feedUrl: {episode1},
        },
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: TestHostWidget()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Trigger multiple rebuilds (simulating window resize or state changes)
      for (var i = 0; i < 5; i++) {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(body: TestHostWidget()),
            ),
          ),
        );
      }
      await tester.pumpAndSettle();

      expect(fakeNotificationsService.notifyCount, 0);

      // Run check for updates
      await container
          .read(podcastUpdatesManagerProvider.notifier)
          .run(const PodcastUpdateCapsule.updateAll());

      await tester.pumpAndSettle();

      // Should be notified exactly ONCE despite 5 prior rebuilds
      expect(fakeNotificationsService.notifyCount, 1);
      expect(fakeNotificationsService.messages.first, contains('Tech News'));
    },
  );

  testWidgets('does not trigger notification when no new updates found', (
    tester,
  ) async {
    when(
      mockPodcastService.checkForUpdates(
        feedUrls: anyNamed('feedUrls'),
        updateProgress: anyNamed('updateProgress'),
      ),
    ).thenAnswer((_) async => {});

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: TestHostWidget()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await container
        .read(podcastUpdatesManagerProvider.notifier)
        .run(const PodcastUpdateCapsule.updateAll());

    await tester.pumpAndSettle();

    expect(fakeNotificationsService.notifyCount, 0);
  });

  testWidgets('does not trigger notification for remove capsule', (
    tester,
  ) async {
    when(
      mockPodcastService.removePodcastUpdates(
        feedUrls: anyNamed('feedUrls'),
        updateProgress: anyNamed('updateProgress'),
      ),
    ).thenAnswer((_) async {});
    when(
      mockPodcastService.getPodcastUpdates(),
    ).thenAnswer((_) async => {feedUrl});

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: TestHostWidget()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await container
        .read(podcastUpdatesManagerProvider.notifier)
        .run(
          const PodcastUpdateCapsule(
            feedUrls: [feedUrl],
            type: PodcastUpdateType.remove,
          ),
        );

    await tester.pumpAndSettle();

    expect(fakeNotificationsService.notifyCount, 0);
  });
}
