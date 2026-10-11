import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/player/manager/player_manager.dart';
import 'package:musicpod/podcasts/manager/episodes_manager.dart';
import 'package:musicpod/podcasts/service/download_service.dart';
import 'package:musicpod/podcasts/service/podcast_service.dart';

import 'episodes_manager_disposal_test.mocks.dart';

@GenerateMocks([PodcastService, PlayerManager, DownloadService])
class EpisodeWatcherWidget extends ConsumerWidget {
  const EpisodeWatcherWidget({super.key, required this.feedUrl});
  final String feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(episodesManagerProvider(feedUrl)).value;
    return Text('Episodes: ${state?.episodes.length ?? 0}');
  }
}

void main() {
  const feedUrl = 'https://example.com/podcast.xml';

  late MockPodcastService mockPodcastService;
  late MockPlayerManager mockPlayerManager;
  late MockDownloadService mockDownloadService;

  setUp(() async {
    await GetIt.I.reset();

    mockPodcastService = MockPodcastService();
    mockPlayerManager = MockPlayerManager();
    mockDownloadService = MockDownloadService();

    when(mockPodcastService.ascendingPodcasts).thenAnswer((_) async => {});
    when(mockPodcastService.findEpisodes(
      feedUrl: anyNamed('feedUrl'),
      tryFromDbOnly: anyNamed('tryFromDbOnly'),
      order: anyNamed('order'),
    )).thenAnswer((_) async => []);
    when(mockPodcastService.getDownloadPath(any)).thenReturn(null);

    when(mockPlayerManager.lastPositions).thenReturn(null);

    when(
      mockDownloadService.setDownloadsDirectory(
        getDefault: anyNamed('getDefault'),
      ),
    ).thenAnswer((_) async => '/fake/downloads');

    GetIt.I.registerSingleton<PodcastService>(mockPodcastService);
    GetIt.I.registerSingleton<PlayerManager>(mockPlayerManager);
    GetIt.I.registerSingleton<DownloadService>(mockDownloadService);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets(
    'episodesManagerProvider is created when watched, and auto-disposes when widget unmounts',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      bool showWidget = true;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
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
        ),
      );

      await tester.pumpAndSettle();

      // 1. episodesManagerProvider is active
      expect(container.exists(episodesManagerProvider(feedUrl)), isTrue);

      // 2. Unmount widget
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // 3. Provider auto-disposes
      expect(container.exists(episodesManagerProvider(feedUrl)), isFalse);
    },
  );

  testWidgets(
    'episodesManagerProvider stays active while at least one widget watches it',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      bool showWidgetA = true;
      bool showWidgetB = true;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
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
        ),
      );

      await tester.pumpAndSettle();

      expect(container.exists(episodesManagerProvider(feedUrl)), isTrue);

      // Close Widget A only
      await tester.tap(find.text('Close A'));
      await tester.pumpAndSettle();

      // Still alive because Widget B is watching
      expect(container.exists(episodesManagerProvider(feedUrl)), isTrue);

      // Close Widget B (last remaining watcher)
      await tester.tap(find.text('Close B'));
      await tester.pumpAndSettle();

      // Auto-disposed!
      expect(container.exists(episodesManagerProvider(feedUrl)), isFalse);
    },
  );
}
