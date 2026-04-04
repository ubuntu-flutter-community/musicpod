import 'package:drift/drift.dart';

class ArtistTable extends Table {
  late final id = integer().autoIncrement()();
  late final name = text()();
}

class AlbumTable extends Table {
  late final id = integer().autoIncrement()();
  late final name = text()();
  late final artist = integer().references(ArtistTable, #id)();
}

class AlbumArtTable extends Table {
  late final id = integer().autoIncrement()();
  late final album = integer().unique().references(AlbumTable, #id)();
  late final pictureData = blob()();
  late final pictureMimeType = text()();
}

class GenreTable extends Table {
  late final id = integer().autoIncrement()();
  late final name = text()();
}

class TrackTable extends Table {
  late final id = integer().autoIncrement()();
  late final name = text()();
  late final path = text()();
  late final album = integer().nullable().references(AlbumTable, #id)();
  @ReferenceName('tracksByArtist')
  late final artist = integer().nullable().references(ArtistTable, #id)();
  @ReferenceName('tracksByAlbumArtist')
  late final albumArtist = integer().nullable().references(ArtistTable, #id)();
  late final discNumber = integer().nullable()();
  late final discTotal = integer().nullable()();
  late final durationMs = real().nullable()();
  @ReferenceName('tracksByGenre')
  late final genre = integer().nullable().references(GenreTable, #id)();
  late final trackNumber = integer().nullable()();
  late final year = integer().nullable()();
  late final lyrics = text().nullable()();
}

class PlaylistTable extends Table {
  late final id = integer().autoIncrement()();
  late final name = text()();
}

class PlaylistTrackTable extends Table {
  late final id = integer().autoIncrement()();
  late final playlist = integer().references(PlaylistTable, #id)();
  late final track = integer().references(TrackTable, #id)();
}

class LikedTrackTable extends Table {
  late final id = integer().autoIncrement()();
  late final trackId = integer().references(TrackTable, #id)();
}

class PinnedAlbumTable extends Table {
  late final id = integer().autoIncrement()();
  late final albumId = integer().references(AlbumTable, #id)();
}
