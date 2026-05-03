import 'package:drift/drift.dart';

class StarredStationTable extends Table {
  late final uuid = text()();

  @override
  Set<Column<Object>> get primaryKey => {uuid};
}

class FavoriteRadioTagTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}
