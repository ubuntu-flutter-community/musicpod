import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/app/app_router.dart';
import 'package:musicpod/app/page_ids.dart';
import 'package:musicpod/app/routing_manager.dart';
import 'package:musicpod/local_audio/service/local_audio_service.dart';
import 'package:musicpod/podcasts/service/podcast_service.dart';
import 'package:musicpod/radio/service/radio_service.dart';
import 'package:musicpod/settings/service/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockPodcastService extends Mock implements PodcastService {
  @override
  Future<bool> isPodcastSubscribed(String? feedUrl) async => false;
}

class MutableMockPodcastService extends Mock implements PodcastService {
  bool subscribed = false;
  @override
  Future<bool> isPodcastSubscribed(String? feedUrl) async => subscribed;
}

class MockLocalAudioService extends Mock implements LocalAudioService {
  @override
  Future<bool> isPinnedAlbum(int? id) async => false;
  @override
  Future<bool> isPlaylistSaved(String? id) async => false;
}

class MockRadioService extends Mock implements RadioService {
  @override
  Future<bool> isStarredStation(String? id) async => false;
}

void main() {
  testWidgets('RoutingManager push and pop updates currentRouteName', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    final settingsService = SettingsService(sharedPreferences: sp);

    final routingManager = RoutingManager(
      podcastService: MockPodcastService(),
      localAudioService: MockLocalAudioService(),
      radioService: MockRadioService(),
      settingsService: settingsService,
    );

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: shellNavigatorKey,
        navigatorObservers: [routingManager],
        home: const Scaffold(body: Text('Home')),
      ),
    );
    await tester.pumpAndSettle();

    // Step 1: Push station page
    await routingManager.push(
      pageId: 'station-uuid-1',
      builder: (context) => const Scaffold(body: Text('Station Page')),
    );
    await tester.pumpAndSettle();
    expect(routingManager.currentRouteName, equals('station-uuid-1'));

    // Step 2: Pop back
    routingManager.pop();
    await tester.pumpAndSettle();
    expect(routingManager.currentRouteName, equals(PageIDs.searchPage));

    // Step 3: Click station page again
    await routingManager.push(
      pageId: 'station-uuid-1',
      builder: (context) => const Scaffold(body: Text('Station Page')),
    );
    await tester.pumpAndSettle();
    expect(routingManager.currentRouteName, equals('station-uuid-1'));
  });

  testWidgets(
    'RoutingManager navigating back to search via push(pageId: searchPage)',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final settingsService = SettingsService(sharedPreferences: sp);

      final routingManager = RoutingManager(
        podcastService: MockPodcastService(),
        localAudioService: MockLocalAudioService(),
        radioService: MockRadioService(),
        settingsService: settingsService,
      );

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: shellNavigatorKey,
          navigatorObservers: [routingManager],
          home: const Scaffold(body: Text('Search Page')),
        ),
      );
      await tester.pumpAndSettle();

      // 1. User is on search page, taps station
      await routingManager.push(
        pageId: 'station-uuid-1',
        builder: (context) => const Scaffold(body: Text('Station Page')),
      );
      await tester.pumpAndSettle();
      expect(routingManager.currentRouteName, equals('station-uuid-1'));

      // 2. User navigates back to search page by clicking Search in sidebar
      await routingManager.push(pageId: PageIDs.searchPage);
      await tester.pumpAndSettle();
      expect(routingManager.currentRouteName, equals(PageIDs.searchPage));

      await routingManager.push(
        pageId: 'station-uuid-1',
        builder: (context) => const Scaffold(body: Text('Station Page')),
      );
      await tester.pumpAndSettle();
      expect(routingManager.currentRouteName, equals('station-uuid-1'));
    },
  );

  testWidgets(
    'RoutingManager push, subscribe, unsubscribe, pop, and push again',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final settingsService = SettingsService(sharedPreferences: sp);
      final podcastService = MutableMockPodcastService();

      final routingManager = RoutingManager(
        podcastService: podcastService,
        localAudioService: MockLocalAudioService(),
        radioService: MockRadioService(),
        settingsService: settingsService,
      );

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: shellNavigatorKey,
          navigatorObservers: [routingManager],
          home: const Scaffold(body: Text('Search Page')),
        ),
      );
      await tester.pumpAndSettle();

      expect(routingManager.currentRouteName, equals(PageIDs.searchPage));

      // 1. Click on podcast_card: push podcast page
      const feedUrl = 'https://example.com/podcast.xml';
      await routingManager.push(
        pageId: feedUrl,
        builder: (context) => const Scaffold(body: Text('Podcast Page')),
      );
      await tester.pumpAndSettle();

      expect(routingManager.currentRouteName, equals(feedUrl));

      // 2. Subscribe to podcast
      podcastService.subscribed = true;

      // 3. Unsubscribe from podcast
      podcastService.subscribed = false;

      // 4. Navigate back
      routingManager.pop();
      await tester.pumpAndSettle();

      expect(routingManager.currentRouteName, equals(PageIDs.searchPage));

      // 5. Click on podcast_card again
      await routingManager.push(
        pageId: feedUrl,
        builder: (context) => const Scaffold(body: Text('Podcast Page')),
      );
      await tester.pumpAndSettle();

      expect(routingManager.currentRouteName, equals(feedUrl));
    },
  );

  testWidgets(
    'RoutingManager correctly ignores GoRouter route names starting with /',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final settingsService = SettingsService(sharedPreferences: sp);

      final routingManager = RoutingManager(
        podcastService: MockPodcastService(),
        localAudioService: MockLocalAudioService(),
        radioService: MockRadioService(),
        settingsService: settingsService,
      );

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: shellNavigatorKey,
          navigatorObservers: [routingManager],
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              settings: const RouteSettings(name: '/search'),
              builder: (context) => const Scaffold(body: Text('Search Page')),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // The base route '/search' should NOT be treated as a top route
      expect(routingManager.currentRouteName, equals(PageIDs.searchPage));

      // Push detail route
      const feedUrl = 'https://example.com/podcast.xml';
      await routingManager.push(
        pageId: feedUrl,
        builder: (context) => const Scaffold(body: Text('Podcast Page')),
      );
      await tester.pumpAndSettle();
      expect(routingManager.currentRouteName, equals(feedUrl));

      // Pop back to /search: previousRoute is '/search'
      routingManager.pop();
      await tester.pumpAndSettle();

      // _topRouteName must be null because prevName '/search' starts with '/'
      expect(routingManager.currentRouteName, equals(PageIDs.searchPage));

      // Click on podcast again: must push successfully
      await routingManager.push(
        pageId: feedUrl,
        builder: (context) => const Scaffold(body: Text('Podcast Page')),
      );
      await tester.pumpAndSettle();
      expect(routingManager.currentRouteName, equals(feedUrl));
    },
  );
}
