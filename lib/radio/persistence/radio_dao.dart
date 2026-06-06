import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import '../../common/persistence/database.dart';

@lazySingleton
class RadioDao {
  final Database _db;

  RadioDao({required Database db}) : _db = db;

  Future<List<String>> getStarredStations() async {
    final rows = await _db.select(_db.starredStationTable).get();
    return rows.map((r) => r.uuid).toList();
  }

  Future<void> insertStarredStation(String uuid) => _db
      .into(_db.starredStationTable)
      .insert(
        StarredStationTableCompanion.insert(uuid: uuid),
        mode: InsertMode.insert,
      );

  Future<void> insertStarredStations(List<String> uuids) async {
    if (uuids.isEmpty) return;
    await _db.batch(
      (batch) => batch.insertAll(
        _db.starredStationTable,
        uuids
            .map((uuid) => StarredStationTableCompanion.insert(uuid: uuid))
            .toList(),
        mode: InsertMode.insert,
      ),
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
}
