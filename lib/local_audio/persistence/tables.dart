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

class TrackTable extends Table {
  late final id = integer().autoIncrement()();
  late final name = text()();
  late final path = text()();
  late final album = integer().nullable().references(AlbumTable, #id)();
  late final artist = integer().nullable().references(ArtistTable, #id)();
  late final albumArtist = integer().nullable().references(ArtistTable, #id)();
  late final discNumber = integer().nullable()();
  late final discTotal = integer().nullable()();
  late final durationMs = real().nullable()();
  late final genre = text().nullable()();
  late final pictureData = blob().nullable()();
  late final pictureMimeType = text().nullable()();
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
