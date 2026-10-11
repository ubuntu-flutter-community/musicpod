import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/common/view/safe_network_image.dart';
import 'package:musicpod/common/view/side_bar_fall_back_image.dart';
import 'package:musicpod/podcasts/data/podcast_short_info.dart';
import 'package:musicpod/podcasts/service/podcast_service.dart';
import 'package:musicpod/podcasts/view/podcast_page_side_bar_icon.dart';
import 'package:musicpod/settings/service/settings_service.dart';

import 'podcast_page_side_bar_icon_test.mocks.dart';

@GenerateMocks([SettingsService, PodcastService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const feed1 = 'https://example.com/podcast1.xml';
  const feed2 = 'https://example.com/podcast2.xml';

  setUp(() async {
    await GetIt.I.reset();
    final mockSettings = MockSettingsService();
    when(mockSettings.getInt(any)).thenReturn(0);
    when(mockSettings.getBool(any)).thenReturn(false);
    when(mockSettings.getString(any)).thenReturn(null);
    GetIt.I.registerSingleton<SettingsService>(mockSettings);

    final mockPodcastService = MockPodcastService();
    when(mockPodcastService.getPodcastShortInfo(any))
        .thenAnswer((invocation) async {
      final feedUrl = invocation.positionalArguments[0] as String;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return PodcastShortInfo(
        name: 'Podcast $feedUrl',
        artist: 'Artist',
        imageUrl: 'https://example.com/$feedUrl.png',
      );
    });
    GetIt.I.registerSingleton<PodcastService>(mockPodcastService);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('PodcastPageSideBarIcon & Riverpod lifecycle', () {
    testWidgets(
      're-subscribes and loads correctly after widget unmount and remount',
      (WidgetTester tester) async {
        bool showWidget = true;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
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
          ),
        );

        // Initially loading
        expect(find.byType(SideBarFallBackImage), findsOneWidget);
        expect(find.byType(SafeNetworkImage), findsNothing);

        // Wait for future to complete
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

        // Remount widget - because provider auto-disposes on unmount, it reloads
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // While it reloads, fallback is shown
        expect(find.byType(SideBarFallBackImage), findsOneWidget);

        // Wait for future to complete
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump();

        // Image is successfully loaded and displayed!
        expect(find.byType(SafeNetworkImage), findsOneWidget);
        final image2 = tester.widget<SafeNetworkImage>(
          find.byType(SafeNetworkImage),
        );
        expect(image2.url, 'https://example.com/$feed1.png');
      },
    );

    testWidgets(
      'updates observable when feedUrl parameter changes in-place on the same element',
      (WidgetTester tester) async {
        String currentFeed = feed1;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
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
          ),
        );

        // Wait for feed1 to load
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump();
        expect(find.byType(SideBarFallBackImage), findsNothing);
        expect(find.byType(SafeNetworkImage), findsOneWidget);
        expect(
          tester.widget<SafeNetworkImage>(find.byType(SafeNetworkImage)).url,
          'https://example.com/$feed1.png',
        );

        // Switch feedUrl to feed2 without unmounting the element
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Wait for feed2 to complete
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump();

        // SafeNetworkImage now displays feed2's URL!
        expect(find.byType(SafeNetworkImage), findsOneWidget);
        expect(
          tester.widget<SafeNetworkImage>(find.byType(SafeNetworkImage)).url,
          'https://example.com/$feed2.png',
        );
      },
    );
  });
}
