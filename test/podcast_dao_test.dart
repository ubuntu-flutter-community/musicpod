import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/common/persistence/database.dart';
import 'package:musicpod/podcasts/persistence/podcast_dao.dart';

void main() {
  late Database db;
  late PodcastDao dao;

  setUp(() {
    db = Database(NativeDatabase.memory());
    dao = PodcastDao(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('PodcastDao.getEpisodes', () {
    const feedUrl = 'https://example.com/feed.xml';
    const podcastImageUrl = 'https://example.com/podcast_cover.png';
    const episodeImageUrl = 'https://example.com/episode_cover.png';

    test(
      'preserves episode-specific imageUrl and assigns podcast imageUrl as albumArtUrl',
      () async {
        await dao.addPodcast(
          feedUrl: feedUrl,
          subscribe: true,
          imageUrl: podcastImageUrl,
          name: 'Show Name',
          artist: 'Show Artist',
        );

        const episodeWithCustomImage = Audio(
          url: 'https://example.com/ep1.mp3',
          title: 'Episode 1',
          audioType: AudioType.podcast,
          imageUrl: episodeImageUrl,
          albumArtUrl: podcastImageUrl,
          feedUrl: feedUrl,
          podcastTitle: 'Show Name',
        );

        const episodeWithoutCustomImage = Audio(
          url: 'https://example.com/ep2.mp3',
          title: 'Episode 2',
          audioType: AudioType.podcast,
          imageUrl: null,
          albumArtUrl: podcastImageUrl,
          feedUrl: feedUrl,
          podcastTitle: 'Show Name',
        );

        await dao.upsertEpisodes(
          feedUrl: feedUrl,
          podcastDescription: 'Description',
          episodes: [episodeWithCustomImage, episodeWithoutCustomImage],
        );

        final loadedEpisodes = await dao.getEpisodes(feedUrl);
        expect(loadedEpisodes.length, 2);

        final ep1 = loadedEpisodes.firstWhere(
          (e) => e.url == 'https://example.com/ep1.mp3',
        );
        expect(ep1.imageUrl, episodeImageUrl);
        expect(ep1.albumArtUrl, podcastImageUrl);

        final ep2 = loadedEpisodes.firstWhere(
          (e) => e.url == 'https://example.com/ep2.mp3',
        );
        expect(ep2.imageUrl, isNull);
        expect(ep2.albumArtUrl, podcastImageUrl);
      },
    );
  });
}
