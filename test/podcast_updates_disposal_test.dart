import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/common/util/family.dart';
import 'package:musicpod/l10n/app_localizations.dart';
import 'package:musicpod/player/manager/player_manager.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:musicpod/podcasts/data/podcast_update_capsule.dart';
import 'package:musicpod/podcasts/manager/episodes_manager.dart';
import 'package:musicpod/podcasts/manager/podcast_updates_manager.dart';
import 'package:musicpod/podcasts/manager/podcast_updated_feeds_manager.dart';
import 'package:musicpod/podcasts/data/podcast_download.dart';
import 'package:musicpod/podcasts/data/podcast_toggle_capsule.dart';
import 'package:musicpod/podcasts/manager/download_manager.dart';
import 'package:musicpod/podcasts/manager/subscribed_podcasts_manager.dart';
import 'package:musicpod/podcasts/service/podcast_service.dart';
import 'package:musicpod/podcasts/view/podcasts_collection_body.dart';
import 'package:musicpod/podcasts/data/podcast_short_info.dart';
import 'package:musicpod/podcasts/manager/podcast_short_info_manager.dart';
import 'package:musicpod/podcasts/view/podcast_page_title.dart';
import 'package:musicpod/settings/manager/settings_manager.dart';
import 'package:musicpod/settings/service/settings_service.dart';

class FakePodcastService implements PodcastService {
  FakePodcastService({
    required this.updatesToReturn,
    this.subscribedFeeds = const {},
  });

  final Map<String, Set<Audio>> updatesToReturn;
  final Set<String> subscribedFeeds;
  final List<String> removedFeedUrls = [];
  final Set<String> updatesInDb = {};

  @override
  Future<Map<String, Set<Audio>>> checkForUpdates({
    required Iterable<String> feedUrls,
    void Function(double progress)? updateProgress,
  }) async {
    updateProgress?.call(1.0);
    updatesInDb.addAll(updatesToReturn.keys);
    return updatesToReturn;
  }

  @override
  Future<void> removePodcastUpdates({
    required Iterable<String> feedUrls,
    required void Function(double) updateProgress,
  }) async {
    for (final (index, url) in feedUrls.indexed) {
      removedFeedUrls.add(url);
      updatesInDb.remove(url);
      updateProgress((index + 1) / (feedUrls.isEmpty ? 1 : feedUrls.length));
    }
  }

  @override
  Future<Set<String>> getPodcastUpdates() async => Set.from(updatesInDb);

  @override
  Future<Set<String>> getSubscribedPodcasts() async =>
      Set.from(subscribedFeeds);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePlayerManager extends SafeChangeNotifier implements PlayerManager {
  @override
  Audio? audio;

  @override
  bool isPlaying = false;

  @override
  late final Command<
    ({List<Audio> audios, bool markComplete})?,
    Map<String, Duration>?
  >
  toggleAudiosProgressCommand = Command.createAsync(
    (_) async => {},
    initialValue: null,
  );

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSettingsService implements SettingsService {
  @override
  int? getInt(String key) => 0;

  @override
  bool? getBool(String key) => false;

  @override
  String? getString(String key) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSettingsManager extends SafeChangeNotifier
    implements SettingsManager {
  @override
  bool useYaruTheme = false;

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeDownloadManager implements DownloadManager {
  final Map<Audio, Command<void, PodcastDownload?>> _commands = {};

  @override
  Command<void, PodcastDownload?> getCommand(Audio audio) =>
      _commands.putIfAbsent(
        audio,
        () => Command.createAsyncNoParam(() async => null, initialValue: null),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSubscribedPodcastsManager implements SubscribedPodcastsManager {
  @override
  late final Command<PodcastToggleCapsule?, Set<String>> command =
      Command.createAsync((_) async => <String>{}, initialValue: <String>{});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePodcastShortInfoManager implements PodcastShortInfoManager {
  FakePodcastShortInfoManager({String? name})
    : command = Command.createSyncNoParam(
        () =>
            name != null ? PodcastShortInfo(name: name, artist: 'Host') : null,
        initialValue: name != null
            ? PodcastShortInfo(name: name, artist: 'Host')
            : null,
      );

  @override
  final Command<void, PodcastShortInfo?> command;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestWidget extends StatelessWidget with WatchItMixin {
  const _TestWidget({required this.onDisposed});
  final VoidCallback onDisposed;

  @override
  Widget build(BuildContext context) {
    onDispose(onDisposed);
    return const SizedBox();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const feedUrl = 'https://example.com/feed.xml';
  const episode1 = Audio(
    url: 'https://example.com/episode1.mp3',
    feedUrl: feedUrl,
    title: 'Episode 1: New Insights',
    podcastTitle: 'Tech Talk',
    audioType: AudioType.podcast,
  );
  const episode2 = Audio(
    url: 'https://example.com/episode2.mp3',
    feedUrl: feedUrl,
    title: 'Episode 2: Deep Dive',
    podcastTitle: 'Tech Talk',
    audioType: AudioType.podcast,
  );

  setUpAll(() {
    Command.globalExceptionHandler = (error, stackTrace) {};
  });

  setUp(() async {
    await Family.reset();
    await GetIt.I.reset();
  });

  tearDown(() async {
    await Family.reset();
    await GetIt.I.reset();
  });

  group('PodcastUpdatesManager memory & disposal', () {
    test(
      'checking for updates populates updates without eagerly instantiating EpisodesManager in Family, and removal clears audio memory',
      () async {
        final fakeService = FakePodcastService(
          updatesToReturn: {
            feedUrl: {episode1, episode2},
          },
          subscribedFeeds: {feedUrl},
        );

        GetIt.I.registerSingleton<PodcastUpdatedFeedsManager>(
          PodcastUpdatedFeedsManager.create(podcastService: fakeService),
        );
        final feedsManager = di<PodcastUpdatedFeedsManager>();

        final manager = PodcastUpdatesManager.create(
          podcastService: fakeService,
          feedsManager: feedsManager,
        );

        // 1. Initial state
        expect(Family.get<EpisodesManager>(feedUrl), isNull);
        expect(manager.command.value, isEmpty);
        expect(feedsManager.command.value, isEmpty);

        // 2. Check for updates
        await manager.command.runAsync(const PodcastUpdateCapsule.updateAll());

        // Updates are loaded into command.value
        expect(manager.command.value.containsKey(feedUrl), isTrue);
        expect(
          manager.command.value[feedUrl],
          containsAll([episode1, episode2]),
        );
        await pumpEventQueue();
        expect(feedsManager.command.value, contains(feedUrl));

        // Crucial test: checking for updates must NOT eagerly allocate EpisodesManager in Family
        expect(Family.get<EpisodesManager>(feedUrl), isNull);

        // 3. Remove updates (what SliverNewEpispdesList.onDispose triggers)
        await manager.command.runAsync(
          const PodcastUpdateCapsule(
            feedUrls: [feedUrl],
            type: PodcastUpdateType.remove,
          ),
        );

        // PodcastService.removePodcastUpdates was invoked
        expect(fakeService.removedFeedUrls, contains(feedUrl));
        await pumpEventQueue();
        expect(feedsManager.command.value, isNot(contains(feedUrl)));

        // Memory allocated for the Audio objects in command.value is cleared
        final currentUpdates = manager.command.value[feedUrl] ?? {};
        expect(currentUpdates, isEmpty);
        expect(
          manager.command.value.values.expand((set) => set),
          isEmpty,
          reason: 'All Audio references must be removed from command.value',
        );

        // EpisodesManager remains unallocated
        expect(Family.get<EpisodesManager>(feedUrl), isNull);

        // 4. Dispose manager from Family
        PodcastUpdatesManager.dispose();
        expect(
          Family.get<PodcastUpdatesManager>('$PodcastUpdatesManager'),
          isNull,
        );
      },
    );
  });

  group('WatchItMixin onDispose', () {
    testWidgets('calls onDispose when unmounted', (tester) async {
      bool disposed = false;
      final show = ValueNotifier<bool>(true);

      await tester.pumpWidget(
        ValueListenableBuilder<bool>(
          valueListenable: show,
          builder: (context, val, _) => val
              ? _TestWidget(onDisposed: () => disposed = true)
              : const SizedBox(),
        ),
      );
      await tester.pump();
      expect(disposed, isFalse);

      show.value = false;
      await tester.pump();
      expect(disposed, isTrue);
    });
  });

  group('SliverNewEpispdesList widget disposal', () {
    testWidgets(
      'leaving SliverNewEpispdesList triggers onDispose hook, calls removePodcastUpdates, and releases episode memory',
      (WidgetTester tester) async {
        final fakeService = FakePodcastService(
          updatesToReturn: {
            feedUrl: {episode1, episode2},
          },
          subscribedFeeds: {feedUrl},
        );

        // Register dependencies in GetIt
        GetIt.I.registerSingleton<PodcastService>(fakeService);
        GetIt.I.registerSingleton<PodcastUpdatedFeedsManager>(
          PodcastUpdatedFeedsManager.create(podcastService: fakeService),
        );
        GetIt.I.registerSingleton<PodcastUpdatesManager>(
          PodcastUpdatesManager.create(
            podcastService: fakeService,
            feedsManager: di<PodcastUpdatedFeedsManager>(),
          ),
        );
        GetIt.I.registerSingleton<PlayerManager>(FakePlayerManager());
        GetIt.I.registerSingleton<SettingsManager>(FakeSettingsManager());
        GetIt.I.registerSingleton<SettingsService>(FakeSettingsService());
        GetIt.I.registerSingleton<DownloadManager>(FakeDownloadManager());
        GetIt.I.registerSingleton<SubscribedPodcastsManager>(
          FakeSubscribedPodcastsManager(),
        );

        final updatesManager = di<PodcastUpdatesManager>();

        // Check for updates to populate memory
        updatesManager.command.run(const PodcastUpdateCapsule.updateAll());
        while (updatesManager.command.isRunning.value) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        await tester.pump(const Duration(milliseconds: 50));
        final updates = updatesManager.command.value;
        expect(updates[feedUrl], containsAll([episode1, episode2]));
        expect(Family.get<EpisodesManager>(feedUrl), isNull);

        final showList = ValueNotifier<bool>(true);

        // Build widget tree hosting SliverNewEpispdesList
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ValueListenableBuilder<bool>(
                valueListenable: showList,
                builder: (context, show, _) {
                  return CustomScrollView(
                    slivers: [
                      if (show)
                        SliverNewEpispdesList(updates: updates)
                      else
                        const SliverToBoxAdapter(
                          child: Text('Left SliverNewEpispdesList'),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
        await tester.pump();

        // Verify SliverNewEpispdesList is currently mounted and displaying episodes
        expect(find.byType(SliverNewEpispdesList), findsOneWidget);
        expect(find.text(episode1.title!), findsOneWidget);
        expect(find.text(episode2.title!), findsOneWidget);

        // Verify EpisodesManager was not created by SliverPodcastPageList
        // because audios was provided directly
        expect(Family.get<EpisodesManager>(feedUrl), isNull);
        expect(Family.get<EpisodesManager>('newPodcastEpisodes'), isNull);

        // Now LEAVE SliverNewEpispdesList
        showList.value = false;
        await tester
            .pump(); // unmounts widget, triggers onDispose -> command.run()

        // Advance time until the command is done and all listeners are notified
        while (updatesManager.command.isRunning.value) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        await tester.pump(const Duration(milliseconds: 50));

        // Verify SliverNewEpispdesList is unmounted
        expect(find.byType(SliverNewEpispdesList), findsNothing);
        expect(find.text('Left SliverNewEpispdesList'), findsOneWidget);

        // Verify that onDispose was executed:
        // 1. removePodcastUpdates was called on the service
        expect(fakeService.removedFeedUrls, contains(feedUrl));

        // 2. The Audio references in PodcastUpdatesManager.command.value were cleared
        final clearedSet = updatesManager.command.value[feedUrl] ?? {};
        expect(clearedSet, isEmpty);
        expect(
          updatesManager.command.value.values.expand((e) => e),
          isEmpty,
          reason:
              'No Audio objects should be retained in PodcastUpdatesManager after leaving',
        );

        // 3. EpisodesManager was never leaked into Family
        expect(Family.get<EpisodesManager>(feedUrl), isNull);
        expect(Family.get<EpisodesManager>('newPodcastEpisodes'), isNull);

        // 4. Disposing the manager clears it from Family and disposes the command
        PodcastUpdatesManager.dispose();
        await tester.pump(const Duration(milliseconds: 100));
        expect(
          Family.get<PodcastUpdatesManager>('$PodcastUpdatesManager'),
          isNull,
        );
        await Family.reset();
        await tester.pump(const Duration(milliseconds: 100));
      },
    );
  });

  group('PodcastPageTitle badge & updatedFeedsCommand memory separation', () {
    testWidgets(
      'PodcastPageTitle badge observes only updatedFeedsCommand, allowing audio objects to be cleared without losing badge status',
      (WidgetTester tester) async {
        final fakeService = FakePodcastService(
          updatesToReturn: {
            feedUrl: {episode1, episode2},
          },
          subscribedFeeds: {feedUrl},
        );

        GetIt.I.registerSingleton<PodcastService>(fakeService);
        GetIt.I.registerSingleton<PodcastUpdatedFeedsManager>(
          PodcastUpdatedFeedsManager.create(podcastService: fakeService),
        );
        GetIt.I.registerSingleton<PodcastUpdatesManager>(
          PodcastUpdatesManager.create(
            podcastService: fakeService,
            feedsManager: di<PodcastUpdatedFeedsManager>(),
          ),
        );
        GetIt.I.registerFactoryParam<PodcastShortInfoManager, String, void>(
          (url, _) => FakePodcastShortInfoManager(name: 'Tech Talk'),
        );

        final manager = di<PodcastUpdatesManager>();
        final feedsManager = di<PodcastUpdatedFeedsManager>();

        await tester.pumpWidget(
          const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: PodcastPageTitle(feedUrl: feedUrl)),
          ),
        );
        await tester.pump();

        // Initially no updates -> badge hidden
        Badge badge = tester.widget(find.byType(Badge));
        expect(badge.isLabelVisible, isFalse);

        // Check for updates
        manager.command.run(const PodcastUpdateCapsule.updateAll());
        while (manager.command.isRunning.value) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        await tester.pump(const Duration(milliseconds: 50));

        // Badge is now visible
        badge = tester.widget(find.byType(Badge));
        expect(badge.isLabelVisible, isTrue);
        expect(
          manager.command.value[feedUrl],
          containsAll([episode1, episode2]),
        );
        expect(feedsManager.command.value, contains(feedUrl));

        // Lifecycle separation:
        // We can completely dispose PodcastUpdatesManager!
        PodcastUpdatesManager.dispose();
        await tester.pump(const Duration(milliseconds: 100));

        // PodcastUpdatesManager is completely destroyed from Family (and all Audio memory freed)!
        expect(
          Family.get<PodcastUpdatesManager>('$PodcastUpdatesManager'),
          isNull,
        );

        // But PodcastUpdatedFeedsManager stays alive and holds the updated feedUrls!
        expect(
          Family.get<PodcastUpdatedFeedsManager>('$PodcastUpdatedFeedsManager'),
          isNotNull,
        );
        expect(feedsManager.command.value, contains(feedUrl));

        // And PodcastPageTitle's badge remains intact and visible!
        badge = tester.widget(find.byType(Badge));
        expect(badge.isLabelVisible, isTrue);

        // When the feed is removed from updates:
        await fakeService.removePodcastUpdates(
          feedUrls: [feedUrl],
          updateProgress: (_) {},
        );
        feedsManager.command.run();
        await tester.pump(const Duration(milliseconds: 50));

        // Badge is now hidden
        badge = tester.widget(find.byType(Badge));
        expect(badge.isLabelVisible, isFalse);
        expect(feedsManager.command.value, isNot(contains(feedUrl)));
        await Family.reset();
        await tester.pump(const Duration(milliseconds: 100));
      },
    );
  });
}
