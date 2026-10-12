import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/podcasts/data/podcast_toggle_capsule.dart';
import 'package:musicpod/podcasts/manager/subscribed_podcasts_manager.dart';
import 'package:musicpod/podcasts/service/podcast_service.dart';

import 'subscribed_podcasts_manager_test.mocks.dart';
import 'test_audios.dart';

@GenerateMocks([PodcastService])
void main() {
  late MockPodcastService mockPodcastService;

  setUp(() async {
    await GetIt.I.reset();
    mockPodcastService = MockPodcastService();
    GetIt.I.registerSingleton<PodcastService>(mockPodcastService);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('SubscribedPodcastsManager', () {
    test('loads subscribed podcasts', () async {
      when(
        mockPodcastService.getSubscribedPodcasts(),
      ).thenAnswer((_) async => {episodeOneAudio.feedUrl!});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        subscribedPodcastsManagerProvider.future,
      );
      expect(result, contains(episodeOneAudio.feedUrl));
    });

    test('togglePodcastSubscription adds and removes feed', () async {
      const newFeedUrl = 'https://example.com/new_feed.xml';
      final feeds = <String>{episodeOneAudio.feedUrl!};

      when(
        mockPodcastService.getSubscribedPodcasts(),
      ).thenAnswer((_) async => Set.from(feeds));
      when(
        mockPodcastService.togglePodcastSubscription(feedUrl: newFeedUrl),
      ).thenAnswer((_) async {
        if (feeds.contains(newFeedUrl)) {
          feeds.remove(newFeedUrl);
        } else {
          feeds.add(newFeedUrl);
        }
      });
      when(
        mockPodcastService.isPodcastSubscribed(newFeedUrl),
      ).thenAnswer((_) async => feeds.contains(newFeedUrl));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initial read
      expect(
        await container.read(subscribedPodcastsManagerProvider.future),
        contains(episodeOneAudio.feedUrl),
      );

      // Add feed
      await container
          .read(subscribedPodcastsManagerProvider.notifier)
          .togglePodcastSubscription(feedUrl: newFeedUrl);

      expect(
        container.read(subscribedPodcastsManagerProvider).value,
        contains(newFeedUrl),
      );

      // Remove feed
      await container
          .read(subscribedPodcastsManagerProvider.notifier)
          .toggleSubscription(PodcastToggleCapsule(feedUrl: newFeedUrl));

      expect(
        container.read(subscribedPodcastsManagerProvider).value,
        isNot(contains(newFeedUrl)),
      );
    });
  });
}
