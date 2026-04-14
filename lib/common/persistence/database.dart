import 'package:drift/drift.dart';

import '../../local_audio/persistence/tables.dart';
import '../../player/persistence/tables.dart';
import '../../podcasts/persistence/tables.dart';
import '../../radio/persistence/tables.dart';

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
  int get schemaVersion => 1;
}
