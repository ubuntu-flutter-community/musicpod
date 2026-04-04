import 'package:drift/drift.dart';

/// Single-row table that persists the last player state across restarts.
/// Audio is stored as a full JSON blob because we don't know which
/// collection (local, podcast, radio) it came from.
class PlayerStateTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get audioJson => text().nullable()();
  TextColumn get position => text().nullable()();
  TextColumn get duration => text().nullable()();
  TextColumn get volume => text().nullable()();
  TextColumn get rate => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
