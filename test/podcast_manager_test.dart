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

  setUp(() {
    mockPodcastService = MockPodcastService();
    when(
      mockPodcastService.podcastFeedUrls,
    ).thenReturn([episodeOneAudio.feedUrl!]);
    when(mockPodcastService.feedsWithDownloads).thenReturn({});

    manager = PodcastManager(podcastService: mockPodcastService);
  });

  group('PodcastManager', () {
    test('initSearchCommand', () async {
      manager.initSearchCommand.run((forceInit: true));

      manager.initSearchCommand.listen(
        (_, _) => expect(manager.showSearch.value, false),
      );
      ;
    });

    test('togglePodcastCommand', () async {
      manager.togglePodcastCommand.run();

      manager.togglePodcastCommand.listen((result, _) {
        expect(result, isA<List<String>>());
        expect(result, contains(episodeOneAudio.feedUrl));
      });
    });

    test('togglePodcastCommand with adding a feed', () async {
      const newFeedUrl = 'https://example.com/new_feed.xml';
      when(
        mockPodcastService.podcastFeedUrls,
      ).thenReturn([episodeOneAudio.feedUrl!, newFeedUrl]);

      manager.togglePodcastCommand.run(
        PodcastToggleCapsule(feedUrl: newFeedUrl),
      );

      manager.togglePodcastCommand.listen((result, _) {
        expect(result, isA<List<String>>());
        expect(result, contains(episodeOneAudio.feedUrl));
        expect(result, contains(newFeedUrl));
      });
    });

    test('togglePodcastCommand with removing a feed', () async {
      manager.togglePodcastCommand.run(
        PodcastToggleCapsule(feedUrl: episodeOneAudio.feedUrl!),
      );

      manager.togglePodcastCommand.listen((result, _) {
        expect(result, isA<List<String>>());
        expect(result, isNot(contains(episodeOneAudio.feedUrl)));
      });
    });
  });
}
