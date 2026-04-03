import 'package:drift/drift.dart';

import '../../local_audio/persistence/tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    ArtistTable,
    AlbumTable,
    TrackTable,
    PlaylistTable,
    PlaylistTrackTable,
  ],
)
class Database extends _$Database {
  Database(super.e);

  @override
  int get schemaVersion => 1;
}
