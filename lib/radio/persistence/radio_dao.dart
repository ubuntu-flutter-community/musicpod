import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:radio_browser_api/radio_browser_api.dart';
import '../../common/data/audio.dart';
import '../../common/persistence/database.dart';

@Injectable(cache: true)
class RadioDao {
  final Database _db;

  RadioDao({required Database db}) : _db = db;

  Future<Set<String>> getStarredStations() async {
    final rows = await _db.select(_db.starredStationTable).get();
    return rows.map((r) => r.uuid).toSet();
  }

  Future<Station?> getStationByUuid(String uuid) async {
    final row = await (_db.select(
      _db.starredStationTable,
    )..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
    if (row == null) return null;
    return _stationFromRow(row);
  }

  Future<void> insertStarredStation(Audio audio) => _db
      .into(_db.starredStationTable)
      .insertOnConflictUpdate(_companionFromAudio(audio));

  Future<void> insertStarredStations(List<String> uuids) async {
    if (uuids.isEmpty) return;
    await _db.batch(
      (batch) => batch.insertAll(
        _db.starredStationTable,
        uuids
            .map((uuid) => StarredStationTableCompanion.insert(uuid: uuid))
            .toList(),
        mode: InsertMode.insertOrIgnore,
      ),
    );
  }

  Future<void> deleteStarredStations(List<String> uuids) async {
    if (uuids.isEmpty) return;
    await _db.batch(
      (batch) =>
          batch.deleteWhere(_db.starredStationTable, (t) => t.uuid.isIn(uuids)),
    );
  }

  Future<void> deleteStarredStation(String uuid) => (_db.delete(
    _db.starredStationTable,
  )..where((t) => t.uuid.equals(uuid))).go();

  Future<Set<String>> getFavRadioTags() async {
    final rows = await _db.select(_db.favoriteRadioTagTable).get();
    return rows.map((r) => r.name).toSet();
  }

  Future<void> insertFavoriteRadioTag(String name) => _db
      .into(_db.favoriteRadioTagTable)
      .insert(
        FavoriteRadioTagTableCompanion.insert(name: name),
        mode: InsertMode.insert,
      );

  Future<void> deleteFavoriteRadioTag(String name) => (_db.delete(
    _db.favoriteRadioTagTable,
  )..where((t) => t.name.equals(name))).go();

  Future<void> deleteRadioTables() => Future.wait([
    _db.delete(_db.starredStationTable).go(),

    _db.delete(_db.favoriteRadioTagTable).go(),
  ]);

  StarredStationTableCompanion _companionFromAudio(Audio audio) =>
      StarredStationTableCompanion.insert(
        uuid: audio.uuid ?? '',
        name: Value(audio.title),
        urlResolved: Value(audio.url),
        favicon: Value(audio.imageUrl),
        homepage: Value(audio.website),
        language: Value(audio.language),
        tags: Value(audio.radioTags),
        codec: Value(audio.codec),
        clickCount: Value(audio.clicks),
        bitrate: Value(audio.bitRate),
      );

  Station _stationFromRow(StarredStationTableData row) => Station(
    changeUUID: row.changeUuid ?? '',
    stationUUID: row.uuid,
    serverUUID: row.serverUuid,
    name: row.name ?? '',
    url: row.url ?? '',
    urlResolved: row.urlResolved,
    homepage: row.homepage,
    favicon: row.favicon,
    tags: row.tags,
    // ignore: deprecated_member_use
    country: row.country ?? '',
    countryCode: row.countryCode ?? '',
    state: row.state,
    language: row.language,
    languageCodes: row.languageCodes,
    votes: row.votes ?? 0,
    lastChangeTime:
        row.lastChangeTime ?? DateTime.fromMillisecondsSinceEpoch(0),
    codec: row.codec,
    bitrate: row.bitrate ?? 0,
    hls: row.hls ?? false,
    lastCheckOk: row.lastCheckOk ?? false,
    lastCheckTime: row.lastCheckTime,
    lastCheckOkTime: row.lastCheckOkTime,
    lastLocalCheckTime: row.lastLocalCheckTime,
    clickTimestamp: row.clickTimestamp,
    clickCount: row.clickCount ?? 0,
    clickTrend: row.clickTrend ?? 0,
    sslError: row.sslError ?? false,
    geoLat: row.geoLat,
    geoLong: row.geoLong,
    hasExtendedInfo: row.hasExtendedInfo ?? false,
  );

  Future<bool> isStationStarred(String pageId) async {
    final row =
        await (await _db.select(_db.starredStationTable)
              ..where((t) => t.uuid.equals(pageId)))
            .getSingleOrNull();
    return row != null;
  }
}
