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
    DownloadedPodcastEpisodeTable,
    DownloadTable,
    PlayerStateTable,
  ],
)
class Database extends _$Database {
  Database(super.e);

  @override
  int get schemaVersion => 2;

  Future<void> reclaimDiskSpace() async {
    try {
      printMessageInDebugMode('Reclaiming disk space...');
      await customStatement('VACUUM;');
      printMessageInDebugMode('Database defragmented and shrunk successfully.');
    } catch (e) {
      printMessageInDebugMode('Failed to vacuum database: $e');
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
    },
  );
}
