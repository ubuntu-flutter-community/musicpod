import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/podcasts/data/podcast_toggle_capsule.dart';
import 'package:musicpod/podcasts/manager/podcast_manager.dart';
import 'package:musicpod/podcasts/manager/subscribed_podcasts_manager.dart';

import 'subscribed_podcasts_manager_test.mocks.dart';
import 'test_audios.dart';

@GenerateMocks([PodcastManager])
Future<void> main() async {
  late SubscribedPodcastsManager manager;
  late MockPodcastManager mockPodcastManager;

  setUpAll(() {
    Command.globalExceptionHandler = (error, stackTrace) {};
  });

  setUp(() {
    mockPodcastManager = MockPodcastManager();
    when(
      mockPodcastManager.getSubscribedPodcasts(),
    ).thenAnswer((_) async => {episodeOneAudio.feedUrl!});
    when(mockPodcastManager.feedsWithDownloads).thenReturn({});

    when(
      mockPodcastManager.wipeCommand,
    ).thenAnswer((_) => Command.createAsyncNoParamNoResult(() async {}));

    manager = SubscribedPodcastsManager(podcastManager: mockPodcastManager);
  });

  group('PodcastManager', () {
    test('togglePodcastCommand', () async {
      manager.command.run();

      manager.command.listen((result, sub) {
        expect(result, isA<Set<String>>());
        expect(result, contains(episodeOneAudio.feedUrl));
        sub.cancel();
      });
    });

    test('togglePodcastCommand with adding a feed', () async {
      const newFeedUrl = 'https://example.com/new_feed.xml';
      when(
        mockPodcastManager.getSubscribedPodcasts(),
      ).thenAnswer((_) async => {episodeOneAudio.feedUrl!, newFeedUrl});

      manager.command.run(PodcastToggleCapsule(feedUrl: newFeedUrl));

      manager.command.listen((result, sub) {
        expect(result, isA<Set<String>>());
        expect(result, contains(episodeOneAudio.feedUrl));
        expect(result, contains(newFeedUrl));
        sub.cancel();
      });
    });

    test('togglePodcastCommand with removing a feed', () async {
      const newFeedUrl = 'https://example.com/new_feed.xml';

      await manager.command.runAsync(PodcastToggleCapsule(feedUrl: newFeedUrl));
      manager.command.run(PodcastToggleCapsule(feedUrl: newFeedUrl));

      manager.command.listen((result, sub) {
        expect(result, isA<Set<String>>());
        expect(result, isNot(contains(newFeedUrl)));
        sub.cancel();
      });
    });
  });
}
