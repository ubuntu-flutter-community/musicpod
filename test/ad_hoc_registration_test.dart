import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/common/logging.dart';
import 'package:musicpod/common/util/family.dart';
import 'package:watch_it/watch_it.dart';

class PodcastManager extends ChangeNotifier {
  PodcastManager(this.feedUrl);
  final String feedUrl;
  int episodeCount = 10;
  bool isDisposed = false;

  bool get canBeDisposed => !hasListeners;

  void addEpisode() {
    episodeCount++;
    notifyListeners();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }
}

/// Helper that simulates ad-hoc registration using `instanceName` to tell instances apart.
PodcastManager getOrRegisterAdHoc(String feedUrl) {
  if (!GetIt.I.isRegistered<PodcastManager>(instanceName: feedUrl)) {
    GetIt.I.registerSingleton<PodcastManager>(
      PodcastManager(feedUrl),
      instanceName: feedUrl,
      dispose: (m) => m.dispose(),
    );
  }
  return GetIt.I<PodcastManager>(instanceName: feedUrl);
}

/// Sidebar tile displaying podcast episode count
class PodcastSidebarTile extends WatchingWidget {
  const PodcastSidebarTile({
    super.key,
    required this.feedUrl,
    this.unregisterOnDispose = false,
  });

  final String feedUrl;
  final bool unregisterOnDispose;

  @override
  Widget build(BuildContext context) {
    getOrRegisterAdHoc(feedUrl);

    if (unregisterOnDispose) {
      onDispose(() {
        if (GetIt.I.isRegistered<PodcastManager>(instanceName: feedUrl)) {
          GetIt.I.unregister<PodcastManager>(instanceName: feedUrl);
        }
      });
    }

    final count = watchPropertyValue(
      (PodcastManager m) => m.episodeCount,
      instanceName: feedUrl,
    );

    return Text('Sidebar count: $count');
  }
}

/// Main Page displaying the same podcast
class PodcastPage extends WatchingWidget {
  const PodcastPage({super.key, required this.feedUrl});
  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    getOrRegisterAdHoc(feedUrl);

    final count = watchPropertyValue(
      (PodcastManager m) => m.episodeCount,
      instanceName: feedUrl,
    );

    return Text('Page count: $count');
  }
}

void main() {
  setUp(() async {
    await Family.reset();
    await GetIt.I.reset();
  });

  tearDown(() async {
    await Family.reset();
    await GetIt.I.reset();
  });

  const feedUrl = 'https://example.com/podcast.xml';

  testWidgets(
    'Case A: If Sidebar unregisters on dispose -> Main Page crashes when rebuilt',
    (tester) async {
      bool showSidebar = true;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    if (showSidebar)
                      const PodcastSidebarTile(
                        feedUrl: feedUrl,
                        unregisterOnDispose: true,
                      ),
                    const PodcastPage(feedUrl: feedUrl),
                    ElevatedButton(
                      onPressed: () => setState(() => showSidebar = false),
                      child: const Text('Hide Sidebar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Initially both render fine and share the same count
      expect(find.text('Sidebar count: 10'), findsOneWidget);
      expect(find.text('Page count: 10'), findsOneWidget);

      // 1. User performs an action that updates the manager state
      final managerBefore = GetIt.I<PodcastManager>(instanceName: feedUrl);
      managerBefore.addEpisode(); // episodeCount is now 11
      await tester.pump();

      expect(find.text('Sidebar count: 11'), findsOneWidget);
      expect(find.text('Page count: 11'), findsOneWidget);

      // 2. Sidebar unmounts (e.g. user toggles sidebar)
      await tester.tap(find.text('Hide Sidebar'));
      await tester.pump();

      // Sidebar unmounted and called unregister on GetIt!
      expect(find.byType(PodcastSidebarTile), findsNothing);
      expect(
        managerBefore.isDisposed,
        isTrue,
      ); // OLD MANAGER WAS DISPOSED WHILE PAGE IS STILL ACTIVE!

      // 3. Now Page triggers a rebuild (e.g. parent rebuild, window resize, theme change)
      // Since it was unregistered, Page's ad-hoc call creates a BRAND NEW instance with RESET state!
      expect(
        GetIt.I.isRegistered<PodcastManager>(instanceName: feedUrl),
        isFalse,
      );

      // Trigger a rebuild on the Scaffold/Page
      final pageElement = tester.element(find.byType(PodcastPage));
      pageElement.markNeedsBuild();
      await tester.pump();

      final managerAfter = GetIt.I<PodcastManager>(instanceName: feedUrl);
      Logger.i(
        'Is managerAfter the same as managerBefore? ${identical(managerBefore, managerAfter)}',
      );
      Logger.i('Page count after rebuild: ${managerAfter.episodeCount}');

      // The Page's state was WIPED OUT because Sidebar destroyed the registration!
      expect(identical(managerBefore, managerAfter), isFalse);
      expect(
        find.text('Page count: 10'),
        findsOneWidget,
      ); // Reset back to initial 10 instead of 11!
    },
  );

  testWidgets(
    'Case B: If neither unregisters on dispose -> Memory leak when user leaves the podcast',
    (tester) async {
      bool showPodcast = true;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    if (showPodcast) ...[
                      const PodcastSidebarTile(
                        feedUrl: feedUrl,
                        unregisterOnDispose:
                            false, // Does NOT unregister to avoid crashing Case A
                      ),
                      const PodcastPage(feedUrl: feedUrl),
                    ],
                    ElevatedButton(
                      onPressed: () => setState(() => showPodcast = false),
                      child: const Text('Close Podcast'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Sidebar count: 10'), findsOneWidget);
      expect(find.text('Page count: 10'), findsOneWidget);
      expect(
        GetIt.I.isRegistered<PodcastManager>(instanceName: feedUrl),
        isTrue,
      );

      // User navigates away / closes the podcast (both Sidebar and Page are gone)
      await tester.tap(find.text('Close Podcast'));
      await tester.pumpAndSettle();

      expect(find.byType(PodcastSidebarTile), findsNothing);
      expect(find.byType(PodcastPage), findsNothing);

      // PROBLEM: The manager is LEAKED forever in GetIt!
      final stillRegistered = GetIt.I.isRegistered<PodcastManager>(
        instanceName: feedUrl,
      );
      final manager = GetIt.I<PodcastManager>(instanceName: feedUrl);
      Logger.i(
        'Is still registered after all widgets unmounted? $stillRegistered',
      );
      Logger.i('Was manager disposed? ${manager.isDisposed}');

      expect(stillRegistered, isTrue); // Memory leak!
      expect(manager.isDisposed, isFalse); // Never cleaned up!
    },
  );

  testWidgets(
    'Case C: Family pattern solves both -> Shared state, survives Sidebar close, auto-disposed when Page closes',
    (tester) async {
      bool showSidebar = true;
      bool showPodcast = true;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              if (!showPodcast) return const SizedBox.shrink();
              return Scaffold(
                body: Column(
                  children: [
                    if (showSidebar) const _FamilySidebarTile(feedUrl: feedUrl),
                    const _FamilyPage(feedUrl: feedUrl),
                    ElevatedButton(
                      onPressed: () => setState(() => showSidebar = false),
                      child: const Text('Hide Sidebar'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => showPodcast = false),
                      child: const Text('Close Podcast'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Sidebar: 10'), findsOneWidget);
      expect(find.text('Page: 10'), findsOneWidget);

      // 1. Update state
      final familyManager = Family.get<PodcastManager>(feedUrl)!;
      familyManager.addEpisode(); // 11
      await tester.pump();

      expect(find.text('Sidebar: 11'), findsOneWidget);
      expect(find.text('Page: 11'), findsOneWidget);

      // 2. Hide sidebar only: Page still holds reference!
      await tester.tap(find.text('Hide Sidebar'));
      await tester.pump();

      // Page stays alive, state 11 is preserved (NOT reset to 10)!
      expect(find.text('Page: 11'), findsOneWidget);
      expect(familyManager.isDisposed, isFalse);
      expect(Family.isRegistered<PodcastManager>(feedUrl), isTrue);

      // 3. User navigates away completely
      await tester.tap(find.text('Close Podcast'));
      await tester.pump();

      // Fast-forward past the Family autoDispose grace period
      await tester.pump(const Duration(milliseconds: 100));

      // Result: Properly disposed and freed from memory!
      expect(Family.isRegistered<PodcastManager>(feedUrl), isFalse);
      expect(familyManager.isDisposed, isTrue);
    },
  );
}

class _FamilySidebarTile extends WatchingWidget {
  const _FamilySidebarTile({required this.feedUrl});
  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final manager = Family.of<PodcastManager>(
      feedUrl,
      () => PodcastManager(feedUrl),
      shouldDispose: (m) => m.canBeDisposed,
      onDispose: (m) => m.dispose(),
      autoDisposeAfter: const Duration(milliseconds: 50),
    );
    final count = watch(manager).episodeCount;
    return Text('Sidebar: $count');
  }
}

class _FamilyPage extends WatchingWidget {
  const _FamilyPage({required this.feedUrl});
  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final manager = Family.of<PodcastManager>(
      feedUrl,
      () => PodcastManager(feedUrl),
      shouldDispose: (m) => m.canBeDisposed,
      onDispose: (m) => m.dispose(),
      autoDisposeAfter: const Duration(milliseconds: 50),
    );
    final count = watch(manager).episodeCount;
    return Text('Page: $count');
  }
}
