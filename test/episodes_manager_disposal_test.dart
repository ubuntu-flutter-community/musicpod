import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/util/family.dart';
import 'package:musicpod/common/view/audio_filter.dart';
import 'package:musicpod/extensions/command_x.dart';
import 'package:musicpod/player/manager/player_manager.dart';
import 'package:musicpod/podcasts/data/podcast_download.dart';
import 'package:musicpod/podcasts/data/podcast_short_info.dart';
import 'package:musicpod/podcasts/manager/download_manager.dart';
import 'package:musicpod/podcasts/manager/episodes_manager.dart';
import 'package:musicpod/podcasts/manager/podcast_manager.dart';
import 'package:musicpod/podcasts/manager/podcast_short_info_manager.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class FakePodcastManagerForEpisodes extends Fake implements PodcastManager {
  final updatesOnly = SafeValueNotifier<bool>(false);
  final downloadsOnly = SafeValueNotifier<bool>(false);
  List<Audio> episodesToReturn = [];

  @override
  Future<Set<String>> get ascendingPodcasts async => {};

  @override
  Future<List<Audio>> findEpisodes({
    required String feedUrl,
    required bool tryFromDbOnly,
    AudioSortOrder? order,
  }) async => List.from(episodesToReturn);
}

class FakePlayerManagerForEpisodes extends Fake implements PlayerManager {
  @override
  Map<String, Duration>? lastPositions;
}

class FakeDownloadManagerForEpisodes extends Fake implements DownloadManager {
  @override
  final downloadCommands =
      MapNotifier<Audio, Command<void, PodcastDownload?>>();

  @override
  bool hasDownload(Audio audio) => false;
}

class FakePodcastShortInfoManagerForEpisodes extends Fake
    implements PodcastShortInfoManager {
  @override
  late final Command<void, PodcastShortInfo?> command =
      Command.createSyncNoParam(() => null, initialValue: null);
}

class EpisodeWatcherWidget extends WatchingWidget {
  const EpisodeWatcherWidget({super.key, required this.feedUrl});
  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final data = watchValue((EpisodesManager m) => m.command, param1: feedUrl);
    return Text('Episodes: ${data?.episodes?.length ?? 0}');
  }
}

class EpisodeResultsWatcherWidget extends WatchingWidget {
  const EpisodeResultsWatcherWidget({super.key, required this.feedUrl});
  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final results = watchValue(
      (EpisodesManager m) => m.command.results,
      param1: feedUrl,
    );
    return Text('IsRunning: ${results.isRunning}');
  }
}

void main() {
  const feedUrl = 'https://example.com/podcast.xml';

  setUp(() async {
    await Family.reset();
    await GetIt.I.reset();

    final fakePodcastManager = FakePodcastManagerForEpisodes();
    final fakeDownloadManager = FakeDownloadManagerForEpisodes();
    final fakePlayerManager = FakePlayerManagerForEpisodes();

    GetIt.I.registerSingleton<PodcastManager>(fakePodcastManager);
    GetIt.I.registerSingleton<DownloadManager>(fakeDownloadManager);
    GetIt.I.registerSingleton<PlayerManager>(fakePlayerManager);

    GetIt.I.registerFactoryParam<PodcastShortInfoManager, String, void>(
      (url, _) => FakePodcastShortInfoManagerForEpisodes(),
    );

    GetIt.I.registerFactoryParam<EpisodesManager, String, void>(
      (url, _) => EpisodesManager.create(
        feedUrl: url,
        podcastManager: fakePodcastManager,
        downloadsManager: fakeDownloadManager,
        playerManager: fakePlayerManager,
      ),
    );
  });

  tearDown(() async {
    await Family.reset();
    await GetIt.I.reset();
  });

  testWidgets(
    'EpisodesManager is created in Family when watched, and removed when widget is disposed',
    (tester) async {
      bool showWidget = true;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    if (showWidget)
                      const EpisodeWatcherWidget(feedUrl: feedUrl),
                    ElevatedButton(
                      onPressed: () => setState(() => showWidget = false),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Wait for initial command to finish running
      await tester.pumpAndSettle();

      // 1. EpisodesManager is registered and active in Family
      expect(Family.isRegistered<EpisodesManager>(feedUrl), isTrue);
      final manager = Family.get<EpisodesManager>(feedUrl)!;
      expect(manager.command.listenerCount, greaterThan(0));
      expect(manager.command.safeToDispose, isFalse);

      // 2. Widget unmounts (e.g. user leaves the podcast page)
      await tester.tap(find.text('Close'));
      await tester.pump();

      // The listener is removed!
      expect(find.byType(EpisodeWatcherWidget), findsNothing);
      expect(manager.command.listenerCount, equals(0));
      expect(manager.command.safeToDispose, isTrue);

      // Still in Family during grace period (5 seconds)
      expect(Family.isRegistered<EpisodesManager>(feedUrl), isTrue);

      // 3. Fast-forward past the 5-second grace period
      await tester.pump(const Duration(seconds: 6));

      // 4. VERIFY: EpisodesManager is COMPLETELY REMOVED from Family!
      expect(Family.isRegistered<EpisodesManager>(feedUrl), isFalse);
      expect(Family.get<EpisodesManager>(feedUrl), isNull);
    },
  );

  testWidgets(
    'EpisodesManager stays alive while at least one widget watches it, and disposes after all unmount',
    (tester) async {
      bool showWidgetA = true;
      bool showWidgetB = true;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    if (showWidgetA)
                      const EpisodeWatcherWidget(feedUrl: feedUrl),
                    if (showWidgetB)
                      const EpisodeWatcherWidget(feedUrl: feedUrl),
                    ElevatedButton(
                      onPressed: () => setState(() => showWidgetA = false),
                      child: const Text('Close A'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => showWidgetB = false),
                      child: const Text('Close B'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(Family.isRegistered<EpisodesManager>(feedUrl), isTrue);
      final manager = Family.get<EpisodesManager>(feedUrl)!;
      expect(manager.command.listenerCount, equals(2));

      // 1. Close Widget A only (Widget B is still watching)
      await tester.tap(find.text('Close A'));
      await tester.pump();

      expect(manager.command.listenerCount, equals(1));
      expect(manager.command.safeToDispose, isFalse);

      // Fast forward past 5s grace period — must STILL be alive because Widget B is alive
      await tester.pump(const Duration(seconds: 6));
      expect(Family.isRegistered<EpisodesManager>(feedUrl), isTrue);

      // 2. Close Widget B (last remaining watcher)
      await tester.tap(find.text('Close B'));
      await tester.pump();

      expect(manager.command.listenerCount, equals(0));
      expect(manager.command.safeToDispose, isTrue);

      // Still alive during grace period
      expect(Family.isRegistered<EpisodesManager>(feedUrl), isTrue);

      // Fast forward past 5s grace period
      await tester.pump(const Duration(seconds: 6));

      // Completely removed and disposed!
      expect(Family.isRegistered<EpisodesManager>(feedUrl), isFalse);
      expect(Family.get<EpisodesManager>(feedUrl), isNull);
    },
  );
}
