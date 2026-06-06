import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../common/data/audio.dart';
import '../../common/persistence/database.dart';

@lazySingleton
class PlayerDao {
  PlayerDao({required Database db}) : _db = db;

  final Database _db;

  Future<void> addLastPosition(String key, Duration lastPosition) async {
    await (_db.podcastEpisodeTable.update()
          ..where((t) => t.contentUrl.equals(key)))
        .write(
          PodcastEpisodeTableCompanion(
            positionMs: Value(lastPosition.inMilliseconds),
          ),
        );
  }

  Future<Map<String, Duration>> getLastPositions() async {
    final rows =
        await (_db.podcastEpisodeTable.select()
              ..where((t) => t.positionMs.isBiggerThanValue(0)))
            .get();
    return {
      for (final row in rows)
        row.contentUrl: Duration(milliseconds: row.positionMs),
    };
  }

  Future<void> addLastPositions(List<Audio> audios) => _db.batch((batch) {
    for (final e in audios) {
      batch.update(
        _db.podcastEpisodeTable,
        PodcastEpisodeTableCompanion(
          durationMs: Value(e.durationMs!.toInt()),
          positionMs: Value(e.durationMs!.toInt()),
        ),
        where: (t) => t.contentUrl.equals(e.url!),
      );
    }
  });

  Future<void> deleteLastPositions(List<Audio> audios) async {
    final urls = audios.where((e) => e.url != null).map((e) => e.url!).toList();
    if (urls.isEmpty) return;
    await (_db.podcastEpisodeTable.update()
          ..where((t) => t.contentUrl.isIn(urls)))
        .write(const PodcastEpisodeTableCompanion(positionMs: Value(0)));
  }

  Future<void> resetAllLastPositions() async {
    await _db.podcastEpisodeTable.update().write(
      const PodcastEpisodeTableCompanion(positionMs: Value(0)),
    );
  }

  Future<
    ({
      String? audioJson,
      String? duration,
      String? position,
      String? volume,
      String? rate,
    })
  >
  getPlayerState() async {
    final row = await (_db.select(
      _db.playerStateTable,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    return (
      audioJson: row?.audioJson,
      duration: row?.duration,
      position: row?.position,
      volume: row?.volume,
      rate: row?.rate,
    );
  }

  Future<void> setPlayerState({
    String? audioJson,
    String? duration,
    String? position,
    String? volume,
    String? rate,
  }) => _db
      .into(_db.playerStateTable)
      .insertOnConflictUpdate(
        PlayerStateTableCompanion.insert(
          id: const Value(1),
          audioJson: Value(audioJson),
          position: Value(position),
          duration: Value(duration),
          volume: Value(volume),
          rate: Value(rate),
        ),
      );

  Future<void> deletePlayerState() => _db.delete(_db.playerStateTable).go();
}
