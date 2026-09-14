import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/common/util/family.dart';
import 'package:musicpod/common/view/safe_network_image.dart';
import 'package:musicpod/common/view/side_bar_fall_back_image.dart';
import 'package:musicpod/extensions/command_x.dart';
import 'package:musicpod/podcasts/data/podcast_short_info.dart';
import 'package:musicpod/podcasts/manager/podcast_short_info_manager.dart';
import 'package:musicpod/podcasts/view/podcast_page_side_bar_icon.dart';

import 'package:musicpod/settings/service/settings_service.dart';

class FakePodcastShortInfoManagerForIcon implements PodcastShortInfoManager {
  FakePodcastShortInfoManagerForIcon(this.feedUrl, {this.imageUrl})
    : command = Command.createAsyncNoParam(() async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return PodcastShortInfo(
          name: 'Podcast $feedUrl',
          artist: 'Artist',
          imageUrl: imageUrl ?? 'https://example.com/$feedUrl.png',
        );
      }, initialValue: null) {
    command.run();
  }

  final String feedUrl;
  final String? imageUrl;

  @override
  final Command<void, PodcastShortInfo?> command;

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const feed1 = 'https://example.com/podcast1.xml';
  const feed2 = 'https://example.com/podcast2.xml';

  setUp(() async {
    await GetIt.I.reset();
    await Family.reset();

    GetIt.I.registerSingleton<SettingsService>(FakeSettingsService());

    GetIt.I.registerFactoryParam<PodcastShortInfoManager, String, void>(
      (feedUrl, _) => Family.of(
        feedUrl,
        () => FakePodcastShortInfoManagerForIcon(feedUrl),
        autoDisposeAfter: const Duration(milliseconds: 50),
        shouldDispose: (m) => m.command.safeToDispose,
        onDispose: (m) => m.command.dispose(),
      ),
    );
  });

  tearDown(() async {
    await Family.reset();
    await GetIt.I.reset();
  });

  group('PodcastPageSideBarIcon & Family & watchValue lifecycle', () {
    testWidgets(
      're-subscribes and loads correctly after manager disposal and recreation',
      (WidgetTester tester) async {
        bool showWidget = true;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Column(
                    children: [
                      if (showWidget)
                        const PodcastPageSideBarIcon(
                          key: ValueKey(feed1),
                          feedUrl: feed1,
                        ),
                      ElevatedButton(
                        onPressed: () =>
                            setState(() => showWidget = !showWidget),
                        child: const Text('Toggle'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        // Initially loading (command is running)
        expect(find.byType(SideBarFallBackImage), findsOneWidget);
        expect(find.byType(SafeNetworkImage), findsNothing);

        // Wait for command to complete
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump();

        // Loaded
        expect(find.byType(SafeNetworkImage), findsOneWidget);
        final image1 = tester.widget<SafeNetworkImage>(
          find.byType(SafeNetworkImage),
        );
        expect(image1.url, 'https://example.com/$feed1.png');

        // Unmount widget to simulate drawer closing or scrolling away
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        expect(find.byType(PodcastPageSideBarIcon), findsNothing);

        // Wait for Family auto-dispose timer (50ms) to fire and dispose instance 1
        await tester.pump(const Duration(milliseconds: 100));
        expect(Family.get<PodcastShortInfoManager>(feed1), isNull);

        // Remount widget (instance 2 is created by Family)
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // While instance 2 runs, fallback is shown
        expect(find.byType(SideBarFallBackImage), findsOneWidget);

        // Wait for instance 2 command to complete
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump();

        // Instance 2 image is successfully loaded and displayed!
        expect(find.byType(SafeNetworkImage), findsOneWidget);
        final image2 = tester.widget<SafeNetworkImage>(
          find.byType(SafeNetworkImage),
        );
        expect(image2.url, 'https://example.com/$feed1.png');

        // Clean up widget tree and drain pending Family & Command timers
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 150));
      },
    );

    testWidgets(
      'updates observable when feedUrl parameter changes in-place on the same element',
      (WidgetTester tester) async {
        String currentFeed = feed1;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Column(
                    children: [
                      // Reused element by not changing key
                      PodcastPageSideBarIcon(feedUrl: currentFeed),
                      ElevatedButton(
                        onPressed: () => setState(() => currentFeed = feed2),
                        child: const Text('Switch'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        // Wait for feed1 to load
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump();
        expect(find.byType(SafeNetworkImage), findsOneWidget);
        expect(
          tester.widget<SafeNetworkImage>(find.byType(SafeNetworkImage)).url,
          'https://example.com/$feed1.png',
        );

        // Switch feedUrl to feed2 without unmounting the element
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Wait for feed2 command to complete
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump();

        // SafeNetworkImage now displays feed2's URL!
        expect(find.byType(SafeNetworkImage), findsOneWidget);
        expect(
          tester.widget<SafeNetworkImage>(find.byType(SafeNetworkImage)).url,
          'https://example.com/$feed2.png',
        );

        // Clean up widget tree and drain pending Family & Command timers
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 150));
      },
    );
  });
}
