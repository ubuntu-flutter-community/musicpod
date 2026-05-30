import 'package:drift/drift.dart';

import '../../common/persistence/database.dart';

class StarredStationTable extends Table {
  late final uuid = text()();

  @override
  Set<Column<Object>> get primaryKey => {uuid};
}

class FavoriteRadioTagTable extends Table {
  TextColumn get name => text()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}

extension StationExtension on Database {
  Future<void> insertStarredStation(String uuid) =>
      into(starredStationTable).insert(
        StarredStationTableCompanion.insert(uuid: uuid),
        mode: InsertMode.insert,
      );

  Future<void> insertStarredStations(List<String> uuids) async {
    if (uuids.isEmpty) return;
    await batch(
      (batch) => batch.insertAll(
        starredStationTable,
        uuids
            .map((uuid) => StarredStationTableCompanion.insert(uuid: uuid))
            .toList(),
        mode: InsertMode.insert,
      ),
    );
  }

  Future<void> deleteStarredStation(String uuid) =>
      (delete(starredStationTable)..where((t) => t.uuid.equals(uuid))).go();

  Future<void> insertFavoriteRadioTag(String name) =>
      into(favoriteRadioTagTable).insert(
        FavoriteRadioTagTableCompanion.insert(name: name),
        mode: InsertMode.insert,
      );

  Future<void> deleteFavoriteRadioTag(String name) =>
      (delete(favoriteRadioTagTable)..where((t) => t.name.equals(name))).go();

  Future<void> deleteRadioTables() => Future.wait([
    delete(starredStationTable).go(),

    delete(favoriteRadioTagTable).go(),
  ]);
}
