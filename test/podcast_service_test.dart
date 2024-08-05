import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/podcast_genre.dart';
import 'package:musicpod/notifications/notifications_service.dart';
import 'package:musicpod/podcasts/podcast_service.dart';
import 'package:musicpod/podcasts/podcast_utils.dart';
import 'package:musicpod/settings/settings_service.dart';
import 'package:podcast_search/podcast_search.dart';

import 'podcast_service_test.mocks.dart';

const Audio episodeOneAudio = Audio(
  url:
      'https://audio2.redcircle.com/episodes/28b15c18-4d42-4036-a6f2-dc403fa7c8a4/stream.mp3',
  website: 'https://feeds.redcircle.com/1e717ca8-94d4-4a39-807e-a148884a9786',
  artist: 'Allen Wyma',
  title:
      'Introduction to Flying High with Flutter - Flying High with Flutter #1',
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
    final result =
        await service.search(searchQuery: 'Flying High with Flutter');
    final feedUrl = result?.items.first.feedUrl;
    List<Audio>? episodes;
    if (feedUrl != null) {
      episodes = await findEpisodes(feedUrl: feedUrl);
    }

    expect(episodes?.last.url == episodeOneAudio.url, true);
    expect(episodes?.last.website == episodeOneAudio.website, true);
    expect(episodes?.last.artist == episodeOneAudio.artist, true);
    expect(episodes?.last.title == episodeOneAudio.title, true);
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
