import 'package:drift/drift.dart';

class FavoriteCountryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().withLength(min: 2, max: 2)();
}

class FavoriteLanguageTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get isoCode => text().withLength(min: 2, max: 2)();
}

class AppSettingTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
