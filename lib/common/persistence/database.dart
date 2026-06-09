import 'package:drift/drift.dart';

import '../../local_audio/persistence/tables.dart';
import '../../player/persistence/tables.dart';
import '../../podcasts/persistence/tables.dart';
import '../../radio/persistence/tables.dart';
import '../logging.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    ArtistTable,
    AlbumTable,
    AlbumArtTable,
    GenreTable,
    TrackTable,
    PlaylistTable,
    PlaylistTrackTable,
    LikedTrackTable,
    StarredStationTable,
    FavoriteRadioTagTable,
    PodcastTable,
    PodcastUpdateTable,
    PodcastEpisodeTable,
    PodcastGenreTable,
    PodcastGenreRelationTable,
    DownloadedPodcastEpisodeTable,
    DownloadTable,
    PlayerStateTable,
  ],
)
class Database extends _$Database {
  Database(super.e);

  @override
  int get schemaVersion => 3;

  Future<void> reclaimDiskSpace() async {
    try {
      printInfoInDebugMode('Reclaiming disk space...', tag: '$Database');
      await customStatement('VACUUM;');
      printInfoInDebugMode(
        'Database defragmented and shrunk successfully.',
        tag: '$Database',
      );
    } catch (e, stackTrace) {
      printErrorInDebugMode(
        'Failed to vacuum database: $e',
        trace: stackTrace,
        tag: '$Database',
      );
    }
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createIndex(
          Index(
            'podcast_episode_content_url',
            'CREATE INDEX IF NOT EXISTS podcast_episode_content_url'
                ' ON podcast_episode_table (content_url)',
          ),
        );
      }
      if (from < 3) {
        await m.createTable(podcastGenreTable);
        await m.createTable(podcastGenreRelationTable);
      }
    },
  );
}
