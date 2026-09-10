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

  Future<void> _addColumnIfMissing(
    Migrator m,
    TableInfo table,
    GeneratedColumn column,
  ) async {
    final existingColumns = (await customSelect(
      'PRAGMA table_info("${table.actualTableName}")',
    ).get()).map((row) => row.read<String>('name')).toSet();

    if (!existingColumns.contains(column.$name)) {
      await m.addColumn(table, column);
    }
  }

  @override
  int get schemaVersion => 6;

  Future<void> reclaimDiskSpace() async {
    try {
      Logger.i('Reclaiming disk space...', tag: '$Database');
      await customStatement('VACUUM;');
      Logger.i(
        'Database defragmented and shrunk successfully.',
        tag: '$Database',
      );
    } catch (e, stackTrace) {
      Logger.e(
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
      if (from < 4) {
        await m.deleteTable(podcastGenreRelationTable.actualTableName);
        await m.createTable(podcastGenreRelationTable);
      }
      if (from < 5) {
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.changeUuid,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.serverUuid,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.name,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.url,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.urlResolved,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.homepage,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.favicon,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.tags,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.country,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.countryCode,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.state,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.language,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.languageCodes,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.votes,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.lastChangeTime,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.codec,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.bitrate,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.hls,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.lastCheckOk,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.lastCheckTime,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.lastCheckOkTime,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.lastLocalCheckTime,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.clickTimestamp,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.clickCount,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.clickTrend,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.sslError,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.geoLat,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.geoLong,
        );
        await _addColumnIfMissing(
          m,
          starredStationTable,
          starredStationTable.hasExtendedInfo,
        );
      }
      if (from < 6) {
        await _addColumnIfMissing(m, podcastTable, podcastTable.subscribed);
      }
    },
  );
}
