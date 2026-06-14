import 'package:drift/drift.dart';

class StarredStationTable extends Table {
  /// Maps to [Station.stationUUID].
  late final uuid = text()();
  late final changeUuid = text().nullable()();
  late final serverUuid = text().nullable()();
  late final name = text().nullable()();
  late final url = text().nullable()();
  late final urlResolved = text().nullable()();
  late final homepage = text().nullable()();
  late final favicon = text().nullable()();
  late final tags = text().nullable()();
  late final country = text().nullable()();
  late final countryCode = text().nullable()();
  late final state = text().nullable()();
  late final language = text().nullable()();
  late final languageCodes = text().nullable()();
  late final votes = integer().nullable()();
  late final lastChangeTime = dateTime().nullable()();
  late final codec = text().nullable()();
  late final bitrate = integer().nullable()();
  late final hls = boolean().nullable()();
  late final lastCheckOk = boolean().nullable()();
  late final lastCheckTime = dateTime().nullable()();
  late final lastCheckOkTime = dateTime().nullable()();
  late final lastLocalCheckTime = dateTime().nullable()();
  late final clickTimestamp = dateTime().nullable()();
  late final clickCount = integer().nullable()();
  late final clickTrend = integer().nullable()();
  late final sslError = boolean().nullable()();
  late final geoLat = real().nullable()();
  late final geoLong = real().nullable()();
  late final hasExtendedInfo = boolean().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {uuid};
}

class FavoriteRadioTagTable extends Table {
  TextColumn get name => text()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}
