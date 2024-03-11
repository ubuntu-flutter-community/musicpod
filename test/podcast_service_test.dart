// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/data.dart';
import 'package:musicpod/podcasts.dart';
import 'package:musicpod/src/notifications/notifications_service.dart';
import 'package:musicpod/src/settings/settings_service.dart';
import 'package:podcast_search/podcast_search.dart';

import 'podcast_service_test.mocks.dart';

const Audio episodeOneAudio = Audio(
  url:
      'https://aphid.fireside.fm/d/1437767933/f31a453c-fa15-491f-8618-3f71f1d565e5/1c572137-1d75-4eb6-a07b-0bd4859d6e1a.mp3',
  website: 'https://feeds.jupiterbroadcasting.com/lup',
  album: 'LUP LIVE Only - From Yuba City California',
  artist: 'Jupiter Broadcasting',
  title: 'Episode 1: Too Much Choice | LU1',
);

@GenerateMocks([NotificationsService, SettingsService])
Future<void> main() async {
  final mockNotificationsService = MockNotificationsService();
  final mockSettingsService = MockSettingsService();

  when(mockSettingsService.usePodcastIndex)
      .thenAnswer((realInvocation) => false);

  final service = PodcastService(
    notificationsService: mockNotificationsService,
    settingsService: mockSettingsService,
  );
  await service.init();

  test('searchByQuery', () async {
    final result = await service.search(searchQuery: 'LINUX Unplugged');
    final feedUrl = result?.items.first.feedUrl;
    Set<Audio>? episodes;
    if (feedUrl != null) {
      episodes = await findEpisodes(feedUrl: feedUrl);
    }

    expect(episodes?.last.url == episodeOneAudio.url, true);
    expect(episodes?.last.website == episodeOneAudio.website, true);
    expect(episodes?.last.artist == episodeOneAudio.artist, true);
    expect(episodes?.last.title == episodeOneAudio.title, true);
    expect(episodes?.last.album == episodeOneAudio.album, true);
  });

  test('searchChartsByCountry', () async {
    final result = await service.search(
      country: Country.germany,
      podcastGenre: PodcastGenre.fiction,
    );
    expect(
      result?.items.isNotEmpty,
      true,
    );
  });
}
