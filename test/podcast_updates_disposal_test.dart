import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/l10n/app_localizations.dart';
import 'package:musicpod/podcasts/data/podcast_short_info.dart';
import 'package:musicpod/podcasts/data/podcast_update_capsule.dart';
import 'package:musicpod/podcasts/manager/podcast_updated_feeds_manager.dart';
import 'package:musicpod/podcasts/manager/podcast_updates_manager.dart';
import 'package:musicpod/podcasts/service/podcast_service.dart';
import 'package:musicpod/podcasts/view/podcast_page_title.dart';
import 'package:musicpod/podcasts/view/podcasts_collection_body.dart';
import 'package:musicpod/settings/service/settings_service.dart';

import 'podcast_updates_disposal_test.mocks.dart';

@GenerateMocks([
  PodcastService,
  SettingsService,
])
void main() {
  const feedUrl = 'https://example.com/podcast.xml';

  const episode1 = Audio(
    audioType: AudioType.podcast,
    url: 'https://example.com/ep1.mp3',
    feedUrl: feedUrl,
    title: 'Episode 1',
  );

  const episode2 = Audio(
    audioType: AudioType.podcast,
    url: 'https://example.com/ep2.mp3',
    feedUrl: feedUrl,
    title: 'Episode 2',
  );

  late MockPodcastService mockPodcastService;
  late MockSettingsService mockSettingsService;

  setUp(() async {
    await GetIt.I.reset();
    mockPodcastService = MockPodcastService();
    mockSettingsService = MockSettingsService();
    when(mockSettingsService.getInt(any)).thenReturn(0);
    when(mockSettingsService.getBool(any)).thenReturn(false);
    when(mockSettingsService.getString(any)).thenReturn(null);
    when(mockPodcastService.getSubscribedPodcasts()).thenAnswer((_) async => {});

    GetIt.I.registerSingleton<PodcastService>(mockPodcastService);
    GetIt.I.registerSingleton<SettingsService>(mockSettingsService);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('PodcastUpdatesManager & PodcastUpdatedFeedsManager', () {
    test(
      'checking for updates populates updates, and removal clears updates and updates feeds manager',
      () async {
        final updatesInDb = <String>{};
        final removedFeedUrls = <String>[];

        when(
          mockPodcastService.checkForUpdates(
            feedUrls: anyNamed('feedUrls'),
            updateProgress: anyNamed('updateProgress'),
          ),
        ).thenAnswer((inv) async {
          final progress =
              inv.namedArguments[#updateProgress] as void Function(double)?;
          progress?.call(1.0);
          updatesInDb.add(feedUrl);
          return {
            feedUrl: {episode1, episode2},
          };
        });

        when(
          mockPodcastService.removePodcastUpdates(
            feedUrls: anyNamed('feedUrls'),
            updateProgress: anyNamed('updateProgress'),
          ),
        ).thenAnswer((inv) async {
          final urls = inv.namedArguments[#feedUrls] as Iterable<String>;
          final progress =
              inv.namedArguments[#updateProgress] as void Function(double)?;
          for (final (index, url) in urls.indexed) {
            removedFeedUrls.add(url);
            updatesInDb.remove(url);
            progress?.call((index + 1) / (urls.isEmpty ? 1 : urls.length));
          }
        });

        when(
          mockPodcastService.getPodcastUpdates(),
        ).thenAnswer((_) async => Set.from(updatesInDb));

        final container = ProviderContainer();
        addTearDown(container.dispose);

        // 1. Initial state
        expect(container.read(podcastUpdatesManagerProvider).updates, isEmpty);
        expect(
          await container.read(podcastUpdatedFeedsManagerProvider.future),
          isEmpty,
        );

        // 2. Check for updates
        await container
            .read(podcastUpdatesManagerProvider.notifier)
            .run(const PodcastUpdateCapsule.updateAll());

        final updatesState = container.read(podcastUpdatesManagerProvider);
        expect(updatesState.updates.containsKey(feedUrl), isTrue);
        expect(
          updatesState.updates[feedUrl],
          containsAll([episode1, episode2]),
        );
        expect(
          await container.read(podcastUpdatedFeedsManagerProvider.future),
          contains(feedUrl),
        );

        // 3. Remove updates
        await container
            .read(podcastUpdatesManagerProvider.notifier)
            .run(
              const PodcastUpdateCapsule(
                feedUrls: [feedUrl],
                type: PodcastUpdateType.remove,
              ),
            );

        expect(removedFeedUrls, contains(feedUrl));
        final clearedUpdates = container
            .read(podcastUpdatesManagerProvider)
            .updates;
        expect(clearedUpdates[feedUrl] ?? {}, isEmpty);
        expect(
          await container.read(podcastUpdatedFeedsManagerProvider.future),
          isNot(contains(feedUrl)),
        );
      },
    );
  });

  group('SliverNewEpispdesList widget disposal', () {
    testWidgets(
      'disposing SliverNewEpispdesList triggers removePodcastUpdates on PodcastUpdatesManager',
      (WidgetTester tester) async {
        final removedFeedUrls = <String>[];

        when(
          mockPodcastService.removePodcastUpdates(
            feedUrls: anyNamed('feedUrls'),
            updateProgress: anyNamed('updateProgress'),
          ),
        ).thenAnswer((inv) async {
          final urls = inv.namedArguments[#feedUrls] as Iterable<String>;
          removedFeedUrls.addAll(urls);
        });

        when(
          mockPodcastService.getPodcastUpdates(),
        ).thenAnswer((_) async => {});

        final showList = ValueNotifier<bool>(true);

        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: ValueListenableBuilder<bool>(
                  valueListenable: showList,
                  builder: (context, show, _) {
                    return CustomScrollView(
                      slivers: [
                        if (show)
                          SliverNewEpispdesList(
                            updates: {
                              feedUrl: {episode1, episode2},
                            },
                          )
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
          ),
        );
        await tester.pump();

        expect(find.byType(SliverNewEpispdesList), findsOneWidget);
        expect(find.text(episode1.title!), findsOneWidget);
        expect(find.text(episode2.title!), findsOneWidget);

        // Unmount SliverNewEpispdesList
        showList.value = false;
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(SliverNewEpispdesList), findsNothing);
        expect(find.text('Left SliverNewEpispdesList'), findsOneWidget);

        // Verify removePodcastUpdates was called
        expect(removedFeedUrls, contains(feedUrl));
      },
    );
  });

  group('PodcastPageTitle badge & updatedFeedsManager', () {
    testWidgets(
      'PodcastPageTitle badge observes podcastUpdatedFeedsManagerProvider',
      (WidgetTester tester) async {
        final updatedFeeds = <String>{};

        when(
          mockPodcastService.getPodcastUpdates(),
        ).thenAnswer((_) async => Set.from(updatedFeeds));
        when(mockPodcastService.getPodcastShortInfo(feedUrl)).thenAnswer(
          (_) async => const PodcastShortInfo(
            name: 'Test Podcast',
            artist: 'Test Artist',
          ),
        );

        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(body: PodcastPageTitle(feedUrl: feedUrl)),
            ),
          ),
        );
        await tester.pump();

        // Initially no updates -> badge hidden
        Badge badge = tester.widget(find.byType(Badge));
        expect(badge.isLabelVisible, isFalse);

        // Add feed to updated feeds
        container.read(podcastUpdatedFeedsManagerProvider.notifier).updateFeeds(
          {feedUrl},
        );
        await tester.pump();

        // Badge is visible
        badge = tester.widget(find.byType(Badge));
        expect(badge.isLabelVisible, isTrue);

        // Remove from updated feeds
        container
            .read(podcastUpdatedFeedsManagerProvider.notifier)
            .updateFeeds({});
        await tester.pump();

        // Badge is hidden again
        badge = tester.widget(find.byType(Badge));
        expect(badge.isLabelVisible, isFalse);
      },
    );
  });
}
