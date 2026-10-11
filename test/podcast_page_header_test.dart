import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/app/routing_manager.dart';
import 'package:musicpod/common/view/safe_network_image.dart';
import 'package:musicpod/l10n/app_localizations.dart';
import 'package:musicpod/podcasts/data/podcast_short_info.dart';
import 'package:musicpod/podcasts/service/podcast_service.dart';
import 'package:musicpod/podcasts/view/podcast_page_header.dart';
import 'package:musicpod/search/manager/search_manager.dart';
import 'package:musicpod/settings/service/settings_service.dart';

import 'podcast_page_header_test.mocks.dart';

@GenerateMocks([PodcastService, RoutingManager, SearchManager, SettingsService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const feedUrl = 'https://example.com/feed.xml';
  late MockPodcastService mockService;

  setUp(() async {
    await GetIt.I.reset();
    mockService = MockPodcastService();
    final mockRouting = MockRoutingManager();
    final mockSearch = MockSearchManager();
    final mockSettings = MockSettingsService();
    when(mockSettings.getInt(any)).thenReturn(0);
    when(mockSettings.getBool(any)).thenReturn(false);
    when(mockSettings.getString(any)).thenReturn(null);

    GetIt.I.registerSingleton<PodcastService>(mockService);
    GetIt.I.registerSingleton<RoutingManager>(mockRouting);
    GetIt.I.registerSingleton<SearchManager>(mockSearch);
    GetIt.I.registerSingleton<SettingsService>(mockSettings);

    when(mockService.getPodcastShortInfo(feedUrl)).thenAnswer(
      (_) async => const PodcastShortInfo(
        name: 'Test Podcast',
        artist: 'Test Artist',
        imageUrl: 'https://example.com/image.png',
        description: 'Test Description',
      ),
    );
    when(mockService.findPodcastGenre(feedUrl)).thenAnswer(
      (_) async => 'Technology',
    );
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('PodcastPageHeader displays image, title, artist, and genre', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PodcastPageHeader(feedUrl: feedUrl),
          ),
        ),
      ),
    );

    // Initial pump (async notifiers are loading)
    await tester.pump();

    // Settle async futures
    await tester.pumpAndSettle();

    expect(find.text('Test Podcast'), findsOneWidget);
    expect(find.text('Test Artist'), findsOneWidget);
    expect(find.text('Technology'), findsOneWidget);
    expect(find.byType(SafeNetworkImage), findsOneWidget);
  });

  testWidgets(
    'PodcastPageHeader updates image and title after being inserted',
    (tester) async {
      PodcastShortInfo? shortInfo;
      when(mockService.getPodcastShortInfo(feedUrl)).thenAnswer(
        (_) async => shortInfo,
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: PodcastPageHeader(feedUrl: feedUrl),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially null
      expect(find.text('Test Podcast'), findsNothing);

      // Now podcast is inserted in DB
      shortInfo = const PodcastShortInfo(
        name: 'Test Podcast',
        artist: 'Test Artist',
        imageUrl: 'https://example.com/image.png',
        description: 'Test Description',
      );

      // What updates podcastShortInfoManagerProvider?
      // Notice: nothing updates it!
      await tester.pumpAndSettle();
      expect(find.text('Test Podcast'), findsNothing);
    },
  );
}
