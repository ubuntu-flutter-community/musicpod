import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/persistence/database.dart';
import 'package:musicpod/podcasts/data/podcast_genre.dart';
import 'package:musicpod/podcasts/podcast_service.dart';
import 'package:musicpod/settings/settings_service.dart';
import 'package:podcast_search/podcast_search.dart';

import 'podcast_service_test.mocks.dart';
import 'test_audios.dart';

@GenerateMocks([SettingsService, Dio])
Future<void> main() async {
  final mockSettingsService = MockSettingsService();

  when(mockSettingsService.getBool(any)).thenAnswer((realInvocation) => false);

  final service = PodcastService(
    dio: MockDio(),
    settingsService: mockSettingsService,
    database: Database(NativeDatabase.memory()),
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
}
