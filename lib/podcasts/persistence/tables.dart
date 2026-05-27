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

class PodcastGenreTable extends Table {
  late final id = text()();
  late final name = text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PodcastGenreRelationTable extends Table {
  late final feedUrl = text().references(PodcastTable, #feedUrl)();
  late final genreId = text().references(PodcastGenreTable, #id)();

  @override
  Set<Column<Object>> get primaryKey => {feedUrl, genreId};
}

class PodcastUpdateTable extends Table {
  late final id = integer().autoIncrement()();

  late final podcastFeedUrl = text().references(PodcastTable, #feedUrl)();
}

@TableIndex(name: 'podcast_episode_content_url', columns: {#contentUrl})
class PodcastEpisodeTable extends Table {
  @ReferenceName('episodesByFeedUrl')
  late final podcastFeedUrl = text().references(PodcastTable, #feedUrl)();
  late final title = text()();
  late final episodeDescription = text()();
  @ReferenceName('episodesByDescription')
  late final podcastDescription = text().references(
    PodcastTable,
    #description,
  )();
  late final contentUrl = text()();

  @override
  Set<Column<Object>> get primaryKey => {contentUrl};

  late final publicationDate = dateTime()();
  late final durationMs = integer().nullable()();
  late final positionMs = integer().withDefault(const Constant(0))();
  late final imageUrl = text().nullable()();
}

class DownloadedPodcastEpisodeTable extends Table {
  late final id = integer().autoIncrement()();
  late final episodeId = text().references(PodcastEpisodeTable, #contentUrl)();
  late final filePath = text()();
}

class DownloadTable extends Table {
  late final url = text()();
  late final filePath = text()();
  late final feedUrl = text()();

  @override
  Set<Column<Object>> get primaryKey => {url};
}
