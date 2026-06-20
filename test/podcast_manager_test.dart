import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/podcasts/data/podcast_toggle_capsule.dart';
import 'package:musicpod/podcasts/podcast_manager.dart';
import 'package:musicpod/podcasts/podcast_service.dart';

import 'podcast_manager_test.mocks.dart';
import 'test_audios.dart';

@GenerateMocks([PodcastService])
Future<void> main() async {
  late PodcastManager manager;
  late MockPodcastService mockPodcastService;

  setUpAll(() {
    Command.globalExceptionHandler = (error, stackTrace) {};
  });

  setUp(() {
    mockPodcastService = MockPodcastService();
    when(
      mockPodcastService.getSubscribedPodcasts(),
    ).thenAnswer((_) async => {episodeOneAudio.feedUrl!});
    when(mockPodcastService.feedsWithDownloads).thenReturn({});

    manager = PodcastManager(podcastService: mockPodcastService);
  });

  group('PodcastManager', () {
    test('initSearchCommand', () async {
      manager.initSearchCommand.run((forceInit: true));

      manager.initSearchCommand.listen((_, sub) {
        expect(manager.showSearch.value, false);
        sub.cancel();
      });
    });

    test('togglePodcastCommand', () async {
      manager.togglePodcastCommand.run();

      manager.togglePodcastCommand.listen((result, sub) {
        expect(result, isA<Set<String>>());
        expect(result, contains(episodeOneAudio.feedUrl));
        sub.cancel();
      });
    });

    test('togglePodcastCommand with adding a feed', () async {
      const newFeedUrl = 'https://example.com/new_feed.xml';
      when(
        mockPodcastService.getSubscribedPodcasts(),
      ).thenAnswer((_) async => {episodeOneAudio.feedUrl!, newFeedUrl});

      manager.togglePodcastCommand.run(
        PodcastToggleCapsule(feedUrl: newFeedUrl),
      );

      manager.togglePodcastCommand.listen((result, sub) {
        expect(result, isA<Set<String>>());
        expect(result, contains(episodeOneAudio.feedUrl));
        expect(result, contains(newFeedUrl));
        sub.cancel();
      });
    });

    test('togglePodcastCommand with removing a feed', () async {
      const newFeedUrl = 'https://example.com/new_feed.xml';

      await manager.togglePodcastCommand.runAsync(
        PodcastToggleCapsule(feedUrl: newFeedUrl),
      );
      manager.togglePodcastCommand.run(
        PodcastToggleCapsule(feedUrl: newFeedUrl),
      );

      manager.togglePodcastCommand.listen((result, sub) {
        expect(result, isA<Set<String>>());
        expect(result, isNot(contains(newFeedUrl)));
        sub.cancel();
      });
    });
  });
}
