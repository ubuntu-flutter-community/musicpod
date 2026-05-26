import 'package:drift/drift.dart';

class ArtistTable extends Table {
  late final name = text()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}

class AlbumTable extends Table {
  late final id = integer().autoIncrement()();
  late final name = text()();
  late final artist = text().references(ArtistTable, #name)();
  late final pinned = boolean().withDefault(const Constant(false))();
}

class AlbumArtTable extends Table {
  late final id = integer().autoIncrement()();
  late final album = integer().unique().references(AlbumTable, #id)();
  late final pictureData = blob()();
  late final pictureMimeType = text()();
}

class GenreTable extends Table {
  late final name = text()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}

class TrackTable extends Table {
  late final name = text()();
  late final path = text()();

  @override
  Set<Column<Object>> get primaryKey => {path};

  late final album = integer().nullable().references(AlbumTable, #id)();
  @ReferenceName('tracksByArtist')
  late final artist = text().nullable().references(ArtistTable, #name)();
  @ReferenceName('tracksByAlbumArtist')
  late final albumArtist = text().nullable().references(ArtistTable, #name)();
  late final discNumber = integer().nullable()();
  late final discTotal = integer().nullable()();
  late final durationMs = real().nullable()();
  @ReferenceName('tracksByGenre')
  late final genre = text().nullable().references(GenreTable, #name)();
  late final trackNumber = integer().nullable()();
  late final year = integer().nullable()();
  late final lyrics = text().nullable()();
}

class PlaylistTable extends Table {
  late final id = integer().autoIncrement()();
  late final name = text()();
  late final fromExternalSource = boolean().withDefault(
    const Constant(false),
  )();
}

class PlaylistTrackTable extends Table {
  late final id = integer().autoIncrement()();
  late final playlist = integer().references(PlaylistTable, #id)();
  late final track = text().references(TrackTable, #path)();
}

class LikedTrackTable extends Table {
  late final id = integer().autoIncrement()();
  late final trackId = text().references(TrackTable, #path)();
}
