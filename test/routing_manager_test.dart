import 'package:flutter/material.dart';
import 'package:musicpod/dependencies.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/app/app_router.dart';
import 'package:musicpod/app/page_ids.dart';
import 'package:musicpod/app/routing_manager.dart';
import 'package:musicpod/settings/service/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late SettingsService settingsService;

  setUp(() async {
    await GetIt.I.reset();
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    settingsService = SettingsService(sharedPreferences: sp);
    di.registerSingleton<SettingsService>(settingsService);

    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test(
    'initial state and setSelectedPageId updates state and selectedPageId',
    () async {
      final routingManager = container.read(routingManagerProvider.notifier);
      expect(
        container.read(routingManagerProvider),
        equals(PageIDs.searchPage),
      );
      expect(routingManager.selectedPageId, equals(PageIDs.searchPage));

      await routingManager.setSelectedPageId(PageIDs.localAudio);
      expect(
        container.read(routingManagerProvider),
        equals(PageIDs.localAudio),
      );
      expect(routingManager.selectedPageId, equals(PageIDs.localAudio));
    },
  );

  testWidgets('RoutingManager push and pop updates currentRouteName', (
    tester,
  ) async {
    final routingManager = container.read(routingManagerProvider.notifier);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: shellNavigatorKey,
          navigatorObservers: [routingManager],
          home: const Scaffold(body: Text('Home')),
        ),
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
      final routingManager = container.read(routingManagerProvider.notifier);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: shellNavigatorKey,
            navigatorObservers: [routingManager],
            home: const Scaffold(body: Text('Search Page')),
          ),
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

  testWidgets('RoutingManager push, pop, and push again', (tester) async {
    final routingManager = container.read(routingManagerProvider.notifier);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: shellNavigatorKey,
          navigatorObservers: [routingManager],
          home: const Scaffold(body: Text('Search Page')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(routingManager.currentRouteName, equals(PageIDs.searchPage));

    // 1. Push podcast page
    const feedUrl = 'https://example.com/podcast.xml';
    await routingManager.push(
      pageId: feedUrl,
      builder: (context) => const Scaffold(body: Text('Podcast Page')),
    );
    await tester.pumpAndSettle();

    expect(routingManager.currentRouteName, equals(feedUrl));

    // 2. Navigate back
    routingManager.pop();
    await tester.pumpAndSettle();

    expect(routingManager.currentRouteName, equals(PageIDs.searchPage));

    // 3. Click on podcast_card again
    await routingManager.push(
      pageId: feedUrl,
      builder: (context) => const Scaffold(body: Text('Podcast Page')),
    );
    await tester.pumpAndSettle();

    expect(routingManager.currentRouteName, equals(feedUrl));
  });

  testWidgets(
    'RoutingManager correctly ignores GoRouter route names starting with /',
    (tester) async {
      final routingManager = container.read(routingManagerProvider.notifier);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: shellNavigatorKey,
            navigatorObservers: [routingManager],
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                settings: const RouteSettings(name: '/search'),
                builder: (context) => const Scaffold(body: Text('Search Page')),
              );
            },
          ),
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
