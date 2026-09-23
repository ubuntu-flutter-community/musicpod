import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/persistence/database.dart';
import 'package:musicpod/podcasts/data/podcast_genre.dart';
import 'package:musicpod/podcasts/persistence/podcast_dao.dart';
import 'package:musicpod/podcasts/service/podcast_service.dart';
import 'package:musicpod/settings/service/settings_service.dart';
import 'package:podcast_search/podcast_search.dart';

import 'podcast_service_test.mocks.dart';
import 'test_audios.dart';

@GenerateMocks([SettingsService])
Future<void> main() async {
  final mockSettingsService = MockSettingsService();

  when(mockSettingsService.getBool(any)).thenAnswer((realInvocation) => false);

  final dao = PodcastDao(db: Database(NativeDatabase.memory()));
  final service = PodcastService(
    settingsService: mockSettingsService,
    dao: dao,
  );

  test('searchByQuery', () async {
    final result = await service.search(
      searchQuery: 'Flying High with Flutter',
    );
    final feedUrl = result?.items.first.feedUrl;
    List<Audio>? episodes;
    if (feedUrl != null) {
      episodes = await service.findEpisodes(
        feedUrl: feedUrl,
        tryFromDbOnly: false,
      );
    }

    expect(episodes?.last.url == episodeOneAudio.url, true);
    expect(episodes?.last.feedUrl == episodeOneAudio.feedUrl, true);
    expect(episodes?.last.copyright == episodeOneAudio.copyright, true);
    expect(episodes?.last.title == episodeOneAudio.title, true);
  });

  test('searchChartsByCountry', () async {
    final result = await service.search(
      country: Country.germany,
      podcastGenre: PodcastGenre.fiction,
    );
    expect(result?.items.isNotEmpty, true);
  });

  test(
    'togglePodcastSubscription subscribe, unsubscribe, check status',
    () async {
      const feedUrl = 'https://example.com/test_podcast.xml';
      // Initially not subscribed
      expect(await service.isPodcastSubscribed(feedUrl), false);

      // 1. First add podcast like findEpisodes does
      await dao.addPodcast(
        feedUrl: feedUrl,
        subscribe: false,
        imageUrl: 'https://example.com/image.png',
        name: 'Test Podcast',
        artist: 'Test Artist',
      );
      expect(await service.isPodcastSubscribed(feedUrl), false);

      // 2. Subscribe
      await service.togglePodcastSubscription(feedUrl: feedUrl);
      expect(await service.isPodcastSubscribed(feedUrl), true);

      // 3. Unsubscribe
      await service.togglePodcastSubscription(feedUrl: feedUrl);
      expect(await service.isPodcastSubscribed(feedUrl), false);

      // 4. cleanUpUnusedPodcasts
      await service.deleteUnsubscribedPodcastData();
      expect(await service.isPodcastSubscribed(feedUrl), false);
    },
  );
}
