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
  int get schemaVersion => 6;

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
      if (from < 4) {
        await m.deleteTable(podcastGenreRelationTable.actualTableName);
        await m.createTable(podcastGenreRelationTable);
      }
      if (from < 5) {
        await m.addColumn(starredStationTable, starredStationTable.changeUuid);
        await m.addColumn(starredStationTable, starredStationTable.serverUuid);
        await m.addColumn(starredStationTable, starredStationTable.name);
        await m.addColumn(starredStationTable, starredStationTable.url);
        await m.addColumn(starredStationTable, starredStationTable.urlResolved);
        await m.addColumn(starredStationTable, starredStationTable.homepage);
        await m.addColumn(starredStationTable, starredStationTable.favicon);
        await m.addColumn(starredStationTable, starredStationTable.tags);
        await m.addColumn(starredStationTable, starredStationTable.country);
        await m.addColumn(starredStationTable, starredStationTable.countryCode);
        await m.addColumn(starredStationTable, starredStationTable.state);
        await m.addColumn(starredStationTable, starredStationTable.language);
        await m.addColumn(
          starredStationTable,
          starredStationTable.languageCodes,
        );
        await m.addColumn(starredStationTable, starredStationTable.votes);
        await m.addColumn(
          starredStationTable,
          starredStationTable.lastChangeTime,
        );
        await m.addColumn(starredStationTable, starredStationTable.codec);
        await m.addColumn(starredStationTable, starredStationTable.bitrate);
        await m.addColumn(starredStationTable, starredStationTable.hls);
        await m.addColumn(starredStationTable, starredStationTable.lastCheckOk);
        await m.addColumn(
          starredStationTable,
          starredStationTable.lastCheckTime,
        );
        await m.addColumn(
          starredStationTable,
          starredStationTable.lastCheckOkTime,
        );
        await m.addColumn(
          starredStationTable,
          starredStationTable.lastLocalCheckTime,
        );
        await m.addColumn(
          starredStationTable,
          starredStationTable.clickTimestamp,
        );
        await m.addColumn(starredStationTable, starredStationTable.clickCount);
        await m.addColumn(starredStationTable, starredStationTable.clickTrend);
        await m.addColumn(starredStationTable, starredStationTable.sslError);
        await m.addColumn(starredStationTable, starredStationTable.geoLat);
        await m.addColumn(starredStationTable, starredStationTable.geoLong);
        await m.addColumn(
          starredStationTable,
          starredStationTable.hasExtendedInfo,
        );
      }
      if (from < 6) {
        await m.addColumn(podcastTable, podcastTable.subscribed);
      }
    },
  );
}
