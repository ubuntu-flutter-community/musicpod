import 'package:drift/drift.dart';

class PodcastTable extends Table {
  late final feedUrl = text()();
  late final name = text()();
  late final artist = text()();
  late final description = text()();
  late final imageUrl = text().nullable()();
  late final lastUpdated = dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {feedUrl};
}

class PodcastEpisodeTable extends Table {
  late final id = integer().autoIncrement()();
  late final podcastFeedUrl = text().references(PodcastTable, #feedUrl)();
  late final title = text()();
  late final description = text()();
  late final audioUrl = text()();
  late final publicationDate = dateTime()();
  late final durationMs = integer().nullable()();
  late final positionMs = integer().withDefault(const Constant(0))();
  late final imageUrl = text().nullable()();
  late final isPlayed = boolean().withDefault(const Constant(false))();
}
