import 'package:drift/drift.dart';

class PodcastTable extends Table {
  late final feedUrl = text()();
  late final name = text()();
  late final artist = text()();
  late final description = text()();
  late final imageUrl = text().nullable()();
  late final lastUpdated = dateTime()();
  late final ascending = boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {feedUrl};
}

class PodcastUpdateTable extends Table {
  late final id = integer().autoIncrement()();

  late final podcastFeedUrl = text().references(PodcastTable, #feedUrl)();
}

class PodcastEpisodeTable extends Table {
  late final id = integer().autoIncrement()();
  late final podcastFeedUrl = text().references(PodcastTable, #feedUrl)();
  late final title = text()();
  late final episodeDescription = text()();
  late final podcastDescription = text().references(
    PodcastTable,
    #description,
  )();
  late final contentUrl = text()();
  late final publicationDate = dateTime()();
  late final durationMs = integer().nullable()();
  late final positionMs = integer().withDefault(const Constant(0))();
  late final imageUrl = text().nullable()();
  late final isPlayedPercent = integer().withDefault(const Constant(0))();
}

class DownloadedPodcastEpisodeTable extends Table {
  late final id = integer().autoIncrement()();
  late final episodeId = integer().references(PodcastEpisodeTable, #id)();
  late final filePath = text()();
}

class DownloadTable extends Table {
  late final url = text()();
  late final filePath = text()();
  late final feedUrl = text()();

  @override
  Set<Column<Object>> get primaryKey => {url};
}
