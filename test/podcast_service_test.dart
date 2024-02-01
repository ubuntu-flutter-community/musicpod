// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/data.dart';
import 'package:musicpod/podcasts.dart';
import 'package:musicpod/src/notifications/notifications_service.dart';
import 'package:podcast_search/podcast_search.dart';

const Audio episodeOneAudio = Audio(
  url:
      'https://aphid.fireside.fm/d/1437767933/f31a453c-fa15-491f-8618-3f71f1d565e5/1c572137-1d75-4eb6-a07b-0bd4859d6e1a.mp3',
  website: 'https://feeds.fireside.fm/linuxunplugged/rss',
  album: 'LINUX Unplugged',
  artist: 'Jupiter Broadcasting',
  title: 'Episode 1: Too Much Choice | LU1',
);

void main() {
  final notificationService = MockNotificationService();
  final service = PodcastService(notificationService);

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

class MockNotificationService implements NotificationsService {
  @override
  Future<void> dispose() {
    return Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> notify({required String message, String? uri}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print(message);
  }
}
