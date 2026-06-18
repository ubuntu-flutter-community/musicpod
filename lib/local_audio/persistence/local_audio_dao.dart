import 'package:audio_metadata_reader/audio_metadata_reader.dart' show Picture;
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../app/page_ids.dart';
import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/logging.dart';
import '../../common/persistence/database.dart';
import '../../common/view/audio_filter.dart';
import '../local_search_result.dart';

@lazySingleton
class LocalAudioDao {
  LocalAudioDao({required Database database}) : _db = database;

  final Database _db;

  Audio trackToAudio(
    TrackTableData track,
    AlbumTableData? albumRow,
    ArtistTableData? artistRow,
    GenreTableData? genreRow,
  ) {
    return Audio(
      path: track.path,
      audioType: AudioType.local,
      title: track.name,
      album: albumRow?.name,
      albumDbId: albumRow?.id,
      artist: artistRow?.name,
      albumArtist: artistRow?.name,
      discNumber: track.discNumber,
      discTotal: track.discTotal,
      durationMs: track.durationMs,
      genre: genreRow?.name,
      trackNumber: track.trackNumber,
      year: track.year,
      lyrics: track.lyrics,
    );
  }

  /// The album name a local track should be grouped under. Tracks that lack an
  /// album tag fall back to their title and finally their path, so that every
  /// local track is linked to an album row (and therefore has an [Audio.albumDbId]).
  String? _albumNameFor(Audio audio) {
    if (audio.album?.isNotEmpty == true) return audio.album;
    if (audio.title?.isNotEmpty == true) return audio.title;
    return audio.path;
  }

  Future<Uint8List?> getAlbumCover(int albumId) async {
    final row = await (_db.select(
      _db.albumArtTable,
    )..where((t) => t.album.equals(albumId))).getSingleOrNull();
    return row?.pictureData;
  }

  Future<void> addAlbumCover(int albumId, Uint8List data) async {
    final existing = await (_db.select(
      _db.albumArtTable,
    )..where((t) => t.album.equals(albumId))).getSingleOrNull();

    if (existing == null) {
      await _db
          .into(_db.albumArtTable)
          .insert(
            AlbumArtTableCompanion.insert(
              album: albumId,
              pictureData: data,
              pictureMimeType: 'image/png',
            ),
            mode: InsertMode.insertOrReplace,
          );
    } else {
      await (_db.update(_db.albumArtTable)
            ..where((t) => t.album.equals(albumId)))
          .write(AlbumArtTableCompanion(pictureData: Value(data)));
    }
  }

  JoinedSelectStatement trackJoin(SimpleSelectStatement base) => base.join([
    innerJoin(
      _db.trackTable,
      _db.trackTable.path.equalsExp(_db.likedTrackTable.trackId),
    ),
    leftOuterJoin(
      _db.albumTable,
      _db.albumTable.id.equalsExp(_db.trackTable.album),
    ),
    leftOuterJoin(
      _db.artistTable,
      _db.artistTable.name.equalsExp(_db.trackTable.artist),
    ),
    leftOuterJoin(
      _db.genreTable,
      _db.genreTable.name.equalsExp(_db.trackTable.genre),
    ),
  ]);

  List<Audio> joinedRowsToAudios(List<TypedResult> rows) => rows.map((row) {
    final track = row.readTable(_db.trackTable);
    final albumRow = row.readTableOrNull(_db.albumTable);
    final artistRow = row.readTableOrNull(_db.artistTable);
    final genreRow = row.readTableOrNull(_db.genreTable);
    return trackToAudio(track, albumRow, artistRow, genreRow);
  }).toList();

  Future<String?> findTrackIdByPath(String? path) async {
    if (path == null) return null;
    final row = await (_db.select(
      _db.trackTable,
    )..where((t) => t.path.equals(path))).getSingleOrNull();
    return row?.path;
  }

  Future<String?> findPathOfFirstTrackInAlbum(int albumId) async {
    final row =
        await (_db.select(_db.trackTable)
              ..where((t) => t.album.equals(albumId))
              ..limit(1))
            .getSingleOrNull();
    return row?.path;
  }

  Future<List<int>?> findAllAlbumIDs() async {
    final rows = await _db.select(_db.albumTable).get();
    rows.sort((a, b) => compareCaseInsensitive(a.name, b.name));
    return rows.map((r) => r.id).toList();
  }

  Future<List<int>> findAlbumIDsOfArtist(String artist) async {
    final rows = await (_db.select(
      _db.albumTable,
    )..where((t) => t.artist.equals(artist))).get();
    return rows.map((r) => r.id).toList();
  }

  Future<String?> findAlbumName(int albumId) async {
    final row = await (_db.select(
      _db.albumTable,
    )..where((t) => t.id.equals(albumId))).getSingleOrNull();
    return row?.name;
  }

  Future<String?> findArtistOfAlbum(int albumId) async {
    final row = await (_db.select(
      _db.albumTable,
    )..where((t) => t.id.equals(albumId))).getSingleOrNull();
    return row?.artist;
  }

  Future<List<int>> findAlbumIDsOfGenre(String genre) async {
    final query = _db.selectOnly(_db.trackTable, distinct: true)
      ..addColumns([_db.trackTable.album])
      ..where(
        _db.trackTable.genre.equals(genre) & _db.trackTable.album.isNotNull(),
      );
    final rows = await query.get();
    return rows
        .map((r) => r.read(_db.trackTable.album))
        .whereType<int>()
        .toList();
  }

  Future<void> persistAudios(List<Audio> audioList) => _db.transaction(
    () async {
      // ── 1. Artists: batch-insert new, then bulk-load IDs ──
      final artistNameToId = <String, String>{};

      // Load existing artists
      final existingArtists = await _db.select(_db.artistTable).get();
      for (final a in existingArtists) {
        artistNameToId[a.name] = a.name;
      }

      // Collect & batch-insert new artists
      final newArtistNames = <String>[];
      final uniqueArtists = <String>{};
      for (final a in audioList) {
        if (a.artist?.isNotEmpty == true) uniqueArtists.add(a.artist!);
        if (a.albumArtist?.isNotEmpty == true) {
          uniqueArtists.add(a.albumArtist!);
        }
      }
      for (final name in uniqueArtists) {
        if (!artistNameToId.containsKey(name)) {
          newArtistNames.add(name);
        }
      }
      if (newArtistNames.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(_db.artistTable, [
            for (final name in newArtistNames)
              ArtistTableCompanion.insert(name: name),
          ]);
        });
        // Re-load to get generated IDs
        final allArtists = await _db.select(_db.artistTable).get();
        artistNameToId.clear();
        for (final a in allArtists) {
          artistNameToId[a.name] = a.name;
        }
      }

      // ── 2. Genres: batch-insert new, then bulk-load IDs ──
      final genreNameToId = <String, String>{};

      final existingGenres = await _db.select(_db.genreTable).get();
      for (final g in existingGenres) {
        genreNameToId[g.name] = g.name;
      }

      final newGenreNames = <String>[];
      final uniqueGenres = <String>{};
      for (final a in audioList) {
        if (a.genre?.trim().isNotEmpty == true) {
          uniqueGenres.add(a.genre!.trim());
        }
      }
      for (final name in uniqueGenres) {
        if (!genreNameToId.containsKey(name)) {
          newGenreNames.add(name);
        }
      }
      if (newGenreNames.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(_db.genreTable, [
            for (final name in newGenreNames)
              GenreTableCompanion.insert(name: name),
          ]);
        });
        final allGenres = await _db.select(_db.genreTable).get();
        genreNameToId.clear();
        for (final g in allGenres) {
          genreNameToId[g.name] = g.name;
        }
      }

      // ── 3. Albums: batch-insert new, then bulk-load IDs ──
      final albumKeyToId = <String, int>{};

      final existingAlbums = await _db.select(_db.albumTable).get();
      for (final a in existingAlbums) {
        albumKeyToId['${a.artist}_${a.name}'] = a.id;
      }

      final newAlbumCompanions = <AlbumTableCompanion>[];
      final seenAlbumKeys = <String>{};
      for (final a in audioList) {
        final albumName = _albumNameFor(a);
        if (albumName == null) continue;
        final artistId = a.artist != null ? artistNameToId[a.artist!] : null;
        final key = '${artistId ?? ''}_$albumName';
        if (albumKeyToId.containsKey(key) || !seenAlbumKeys.add(key)) continue;
        newAlbumCompanions.add(
          AlbumTableCompanion.insert(name: albumName, artist: artistId ?? ''),
        );
      }
      if (newAlbumCompanions.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(_db.albumTable, newAlbumCompanions);
        });
        final allAlbums = await _db.select(_db.albumTable).get();
        albumKeyToId.clear();
        for (final a in allAlbums) {
          albumKeyToId['${a.artist}_${a.name}'] = a.id;
        }
      }

      // ── 4. Tracks: batch-insert new ──
      final pathQuery = _db.selectOnly(_db.trackTable)
        ..addColumns([_db.trackTable.path]);
      final pathRows = await pathQuery.get();
      final existingPaths = pathRows
          .map((r) => r.read(_db.trackTable.path)!)
          .toSet();

      final trackCompanions = <TrackTableCompanion>[];
      final artCandidates = <(int, Audio)>[];

      for (final audio in audioList) {
        if (audio.path == null || existingPaths.contains(audio.path)) continue;

        final artistId = audio.artist != null
            ? artistNameToId[audio.artist!]
            : null;
        final albumArtistId = audio.albumArtist != null
            ? artistNameToId[audio.albumArtist!]
            : null;
        final albumName = _albumNameFor(audio);
        final albumKey = '${artistId ?? ''}_${albumName ?? ''}';
        final albumId = albumName != null ? albumKeyToId[albumKey] : null;
        final genreId = audio.genre?.trim().isNotEmpty == true
            ? genreNameToId[audio.genre!.trim()]
            : null;

        trackCompanions.add(
          TrackTableCompanion.insert(
            name: audio.title ?? audio.path!,
            path: audio.path!,
            album: Value(albumId),
            artist: Value(artistId),
            albumArtist: Value(albumArtistId),
            discNumber: Value(audio.discNumber),
            discTotal: Value(audio.discTotal),
            durationMs: Value(audio.durationMs),
            genre: Value(genreId),
            trackNumber: Value(audio.trackNumber),
            year: Value(audio.year),
            lyrics: Value(audio.lyrics),
          ),
        );

        if (albumId != null &&
            audio.pictureData != null &&
            audio.pictureMimeType != null) {
          artCandidates.add((albumId, audio));
        }
      }

      await _db.batch((batch) {
        batch.insertAll(_db.trackTable, trackCompanions);
      });

      // ── 5. Album art: batch-insert (one per album) ──
      final seenAlbumIds = <int>{};
      final artCompanions = <AlbumArtTableCompanion>[];
      for (final (albumId, audio) in artCandidates) {
        if (seenAlbumIds.add(albumId)) {
          artCompanions.add(
            AlbumArtTableCompanion.insert(
              album: albumId,
              pictureData: audio.pictureData!,
              pictureMimeType: audio.pictureMimeType!,
            ),
          );
        }
      }
      if (artCompanions.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(
            _db.albumArtTable,
            artCompanions,
            mode: InsertMode.insertOrIgnore,
          );
        });
      }
    },
  );

  Future<List<Audio>> findLikedAudios() async {
    final rows = await trackJoin(_db.select(_db.likedTrackTable)).get();
    return joinedRowsToAudios(rows);
  }

  Future<void> addLikedAudiosToDb(List<Audio> audios) async {
    await Future.wait(
      audios.map((audio) async {
        final trackId = await findTrackIdByPath(audio.path);
        if (trackId != null) {
          await _db
              .into(_db.likedTrackTable)
              .insert(
                LikedTrackTableCompanion.insert(trackId: trackId),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }),
    );
  }

  Future<void> removeLikedAudio(Audio audio) async {
    final trackId = await findTrackIdByPath(audio.path);
    if (trackId != null) {
      await (_db.delete(
        _db.likedTrackTable,
      )..where((t) => t.trackId.equals(trackId))).go();
    }
  }

  Future<void> removeLikedAudios(List<Audio> audios) async {
    for (final audio in audios) {
      await removeLikedAudio(audio);
    }
  }

  Future<List<PlaylistTableData>> loadAllPlaylists() async {
    return _db.select(_db.playlistTable).get();
  }

  Future<List<String>> findAllPlaylistIDs() async {
    final rows = await _db.select(_db.playlistTable).get();
    return rows.map((r) => r.name).toList();
  }

  Future<List<Audio>> loadPlaylistTracks(int playlistId) async {
    final trackRows = await (_db.select(_db.playlistTrackTable).join([
      innerJoin(
        _db.trackTable,
        _db.trackTable.path.equalsExp(_db.playlistTrackTable.track),
      ),
      leftOuterJoin(
        _db.albumTable,
        _db.albumTable.id.equalsExp(_db.trackTable.album),
      ),
      leftOuterJoin(
        _db.artistTable,
        _db.artistTable.name.equalsExp(_db.trackTable.artist),
      ),
      leftOuterJoin(
        _db.genreTable,
        _db.genreTable.name.equalsExp(_db.trackTable.genre),
      ),
    ])..where(_db.playlistTrackTable.playlist.equals(playlistId))).get();

    return joinedRowsToAudios(trackRows);
  }

  Future<PlaylistTableData?> findPlaylistByName(String name) {
    return (_db.select(
      _db.playlistTable,
    )..where((t) => t.name.equals(name))).getSingleOrNull();
  }

  Future<List<Audio>?> findPlaylistById(String id) async {
    final plRow = await findPlaylistByName(id);
    if (plRow == null) return null;
    return loadPlaylistTracks(plRow.id);
  }

  Future<bool> isPlaylistSaved(String id) =>
      (_db.select(_db.playlistTable)..where((t) => t.name.equals(id)))
          .getSingleOrNull()
          .then((value) => value != null);

  Future<void> createPlaylistInDb({
    required String name,
    required List<Audio> audios,
    bool external = false,
  }) async {
    await _db.transaction(() async {
      final plId = await _db
          .into(_db.playlistTable)
          .insert(
            PlaylistTableCompanion.insert(
              name: name,
              fromExternalSource: Value(external),
            ),
          );

      for (final audio in audios) {
        final trackId = await findTrackIdByPath(audio.path);
        if (trackId != null) {
          await _db
              .into(_db.playlistTrackTable)
              .insert(
                PlaylistTrackTableCompanion.insert(
                  playlist: plId,
                  track: trackId,
                ),
              );
        }
      }
    });
  }

  Future<void> persistPlaylistInDb(String name, List<Audio> audios) async {
    final plRow = await findPlaylistByName(name);
    if (plRow == null) return;

    await (_db.delete(
      _db.playlistTrackTable,
    )..where((t) => t.playlist.equals(plRow.id))).go();
    for (final audio in audios) {
      var trackId = await findTrackIdByPath(audio.path);
      if (trackId == null) {
        trackId = await findTrackIdByPath(audio.path);
      }
      if (trackId != null) {
        await _db
            .into(_db.playlistTrackTable)
            .insert(
              PlaylistTrackTableCompanion.insert(
                playlist: plRow.id,
                track: trackId,
              ),
            );
      }
    }
  }

  Future<void> deletePlaylist(String name) async {
    final plRow = await findPlaylistByName(name);
    if (plRow != null) {
      await (_db.delete(
        _db.playlistTrackTable,
      )..where((t) => t.playlist.equals(plRow.id))).go();
      await (_db.delete(
        _db.playlistTable,
      )..where((t) => t.id.equals(plRow.id))).go();
    }
  }

  Future<void> updatePlaylistNameInDb(String oldName, String newName) async {
    final plRow = await findPlaylistByName(oldName);
    if (plRow != null) {
      await (_db.update(_db.playlistTable)..where((t) => t.id.equals(plRow.id)))
          .write(PlaylistTableCompanion(name: Value(newName)));
    }
  }

  Future<List<int>> findPinnedAlbumIDs() async {
    final rows = await (_db.select(
      _db.albumTable,
    )..where((t) => t.pinned.equals(true))).get();
    return rows.map((r) => r.id).toList();
  }

  Future<void> updateAlbumPinned(int id, bool pinned) async {
    await (_db.update(_db.albumTable)..where((t) => t.id.equals(id))).write(
      AlbumTableCompanion(pinned: Value(pinned)),
    );
  }

  Future<void> wipeAllLocalAudioTables() async {
    await _db.delete(_db.artistTable).go();
    await _db.delete(_db.albumTable).go();
    await _db.delete(_db.albumArtTable).go();
    await _db.delete(_db.genreTable).go();
    await _db.delete(_db.trackTable).go();
    await _db.delete(_db.likedTrackTable).go();
    await _db.delete(_db.playlistTrackTable).go();
    await _db.delete(_db.playlistTable).go();
  }

  Future<int> getTrackCount() async {
    return _db.trackTable.count().getSingle();
  }

  Future<List<Audio>> findAllTracks() async {
    final query = _db.select(_db.trackTable).join([
      leftOuterJoin(
        _db.albumTable,
        _db.albumTable.id.equalsExp(_db.trackTable.album),
      ),
      leftOuterJoin(
        _db.artistTable,
        _db.artistTable.name.equalsExp(_db.trackTable.artist),
      ),
      leftOuterJoin(
        _db.genreTable,
        _db.genreTable.name.equalsExp(_db.trackTable.genre),
      ),
    ]);

    final rows = await query.get();
    final audios = rows.map((row) {
      final track = row.readTable(_db.trackTable);
      final albumRow = row.readTableOrNull(_db.albumTable);
      final artistRow = row.readTableOrNull(_db.artistTable);
      final genreRow = row.readTableOrNull(_db.genreTable);
      return trackToAudio(track, albumRow, artistRow, genreRow);
    }).toList();
    audios.sort((a, b) => compareCaseInsensitive(a.title ?? '', b.title ?? ''));
    return audios;
  }

  Future<List<String>> loadAllArtists() async {
    final artists = await (_db.select(
      _db.artistTable,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
    return artists.map((a) => a.name).toList();
  }

  Future<List<String>> loadAllGenres() async {
    final genres = await (_db.select(
      _db.genreTable,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
    return genres.map((g) => g.name).toList();
  }

  Future<List<Audio>> loadAlbum(int albumId) async {
    final query = _db.select(_db.trackTable).join([
      leftOuterJoin(
        _db.albumTable,
        _db.albumTable.id.equalsExp(_db.trackTable.album),
      ),
      leftOuterJoin(
        _db.artistTable,
        _db.artistTable.name.equalsExp(_db.trackTable.artist),
      ),
      leftOuterJoin(
        _db.genreTable,
        _db.genreTable.name.equalsExp(_db.trackTable.genre),
      ),
    ]);

    query.where(_db.albumTable.id.equals(albumId));
    query.orderBy([
      OrderingTerm.asc(_db.trackTable.discNumber),
      OrderingTerm.asc(_db.trackTable.trackNumber),
    ]);

    final rows = await query.get();
    return rows.map((row) {
      final track = row.readTable(_db.trackTable);
      final albumRow = row.readTableOrNull(_db.albumTable);
      final artistRow = row.readTableOrNull(_db.artistTable);
      final genreRow = row.readTableOrNull(_db.genreTable);
      return trackToAudio(track, albumRow, artistRow, genreRow);
    }).toList();
  }

  Future<List<Audio>> loadTitlesOfArtist(
    String artist, [
    AudioFilter audioFilter = AudioFilter.album,
  ]) async {
    final query = _db.select(_db.trackTable).join([
      leftOuterJoin(
        _db.albumTable,
        _db.albumTable.id.equalsExp(_db.trackTable.album),
      ),
      innerJoin(
        _db.artistTable,
        _db.artistTable.name.equalsExp(_db.trackTable.artist),
      ),
      leftOuterJoin(
        _db.genreTable,
        _db.genreTable.name.equalsExp(_db.trackTable.genre),
      ),
    ]);
    query.where(_db.artistTable.name.equals(artist));

    switch (audioFilter) {
      case AudioFilter.album:
        query.orderBy([
          OrderingTerm.asc(_db.albumTable.name),
          OrderingTerm.asc(_db.trackTable.discNumber),
          OrderingTerm.asc(_db.trackTable.trackNumber),
        ]);
      case AudioFilter.title:
        query.orderBy([OrderingTerm.asc(_db.trackTable.name)]);
      case AudioFilter.year:
        query.orderBy([OrderingTerm.asc(_db.trackTable.year)]);
      case AudioFilter.trackNumber:
        query.orderBy([
          OrderingTerm.asc(_db.trackTable.discNumber),
          OrderingTerm.asc(_db.trackTable.trackNumber),
        ]);
      default:
        query.orderBy([
          OrderingTerm.asc(_db.albumTable.name),
          OrderingTerm.asc(_db.trackTable.discNumber),
          OrderingTerm.asc(_db.trackTable.trackNumber),
        ]);
    }

    final rows = await query.get();
    return rows.map((row) {
      final track = row.readTable(_db.trackTable);
      final albumRow = row.readTableOrNull(_db.albumTable);
      final artistRow = row.readTableOrNull(_db.artistTable);
      final genreRow = row.readTableOrNull(_db.genreTable);
      return trackToAudio(track, albumRow, artistRow, genreRow);
    }).toList();
  }

  Future<void> updateLyricsForTitleAndArtistAndAlbum({
    required String title,
    required String artist,
    required String? album,
    required String lyrics,
  }) async {
    printInfoInDebugMode(
      'Updating lyrics in DB for "$title" by "$artist"${album != null ? ' from album "$album"' : ''}',
      tag: '$LocalAudioDao',
    );
    final query = _db.select(_db.trackTable).join([
      leftOuterJoin(
        _db.albumTable,
        _db.albumTable.id.equalsExp(_db.trackTable.album),
      ),
      innerJoin(
        _db.artistTable,
        _db.artistTable.name.equalsExp(_db.trackTable.artist),
      ),
    ]);

    query.where(_db.trackTable.name.equals(title));
    query.where(_db.artistTable.name.equals(artist));
    if (album != null) {
      query.where(_db.albumTable.name.equals(album));
    } else {
      query.where(_db.albumTable.name.isNull());
    }

    final rows = await query.get();
    for (final row in rows) {
      final track = row.readTable(_db.trackTable);
      await (_db.update(_db.trackTable)
            ..where((t) => t.path.equals(track.path)))
          .write(TrackTableCompanion(lyrics: Value(lyrics)));
    }
  }

  Future<int?> updateSingleTrackInDb(
    Audio audio, {
    String? artist,
    String? album,
    String? genre,
    String? title,
    String? discNumber,
    String? trackNumber,
    String? year,
    List<Picture>? pictures,
    String? lyrics,
  }) async {
    if (audio.path == null) return null;

    return _db.transaction(() async {
      final trackRow = await (_db.select(
        _db.trackTable,
      )..where((t) => t.path.equals(audio.path!))).getSingleOrNull();
      if (trackRow == null) return null;

      final resolvedArtist = artist ?? trackRow.artist;

      if (resolvedArtist != null && resolvedArtist.isNotEmpty) {
        await _db
            .into(_db.artistTable)
            .insert(
              ArtistTableCompanion.insert(name: resolvedArtist),
              mode: InsertMode.insertOrIgnore,
            );
      } else {
        await _db
            .into(_db.artistTable)
            .insert(
              ArtistTableCompanion.insert(name: ''),
              mode: InsertMode.insertOrIgnore,
            );
      }

      String? targetAlbumName;
      if (album != null) {
        targetAlbumName = album;
      } else if (trackRow.album != null) {
        final existingAlbumRow = await (_db.select(
          _db.albumTable,
        )..where((a) => a.id.equals(trackRow.album!))).getSingleOrNull();
        targetAlbumName = existingAlbumRow?.name;
      }

      final targetArtistForAlbum = resolvedArtist ?? '';

      int? targetAlbumId;
      if (targetAlbumName != null && targetAlbumName.isNotEmpty) {
        final existingAlbum =
            await (_db.select(_db.albumTable)..where(
                  (a) =>
                      a.name.equals(targetAlbumName!) &
                      a.artist.equals(targetArtistForAlbum),
                ))
                .getSingleOrNull();

        if (existingAlbum != null) {
          targetAlbumId = existingAlbum.id;
        } else {
          targetAlbumId = await _db
              .into(_db.albumTable)
              .insert(
                AlbumTableCompanion.insert(
                  name: targetAlbumName,
                  artist: targetArtistForAlbum,
                ),
              );
        }
      }

      if (genre != null) {
        final trimmedGenre = genre.trim();
        if (trimmedGenre.isNotEmpty) {
          await _db
              .into(_db.genreTable)
              .insert(
                GenreTableCompanion.insert(name: trimmedGenre),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }

      final trackCompanion = TrackTableCompanion(
        name: title != null ? Value(title) : const Value.absent(),
        artist: artist != null ? Value(artist) : const Value.absent(),
        albumArtist: artist != null ? Value(artist) : const Value.absent(),
        genre: genre != null ? Value(genre.trim()) : const Value.absent(),
        discNumber: discNumber != null
            ? Value(discNumber.isEmpty ? null : int.tryParse(discNumber))
            : const Value.absent(),
        trackNumber: trackNumber != null
            ? Value(trackNumber.isEmpty ? null : int.tryParse(trackNumber))
            : const Value.absent(),
        year: year != null
            ? Value(year.isEmpty ? null : int.tryParse(year))
            : const Value.absent(),
        album: (album != null || (artist != null && trackRow.album != null))
            ? Value(targetAlbumId)
            : const Value.absent(),
        lyrics: lyrics != null ? Value(lyrics) : const Value.absent(),
      );

      await (_db.update(
        _db.trackTable,
      )..where((t) => t.path.equals(audio.path!))).write(trackCompanion);

      if (pictures != null && pictures.isNotEmpty && targetAlbumId != null) {
        final albumIdVal = targetAlbumId;
        Picture? pic;
        for (final p in pictures) {
          if (p.bytes.isNotEmpty) {
            pic = p;
            break;
          }
        }
        if (pic != null) {
          final existingArt = await (_db.select(
            _db.albumArtTable,
          )..where((a) => a.album.equals(albumIdVal))).getSingleOrNull();

          final artCompanion = AlbumArtTableCompanion(
            album: Value(albumIdVal),
            pictureData: Value(pic.bytes),
            pictureMimeType: Value(pic.mimetype),
          );

          if (existingArt != null) {
            await (_db.update(
              _db.albumArtTable,
            )..where((a) => a.album.equals(albumIdVal))).write(artCompanion);
          } else {
            await _db.into(_db.albumArtTable).insert(artCompanion);
          }
        }
      }

      return targetAlbumId;
    });
  }

  Future<int?> findAlbumIdForArtistAndAlbum({
    required String artist,
    required String album,
  }) async {
    final result =
        await (_db.select(_db.albumTable)
              ..where((a) => a.artist.equals(artist) & a.name.equals(album)))
            .getSingleOrNull();
    return result?.id;
  }

  Future<List<String>?> findAllArtists() async {
    final rows = await _db.select(_db.artistTable).get();
    final names = rows.map((r) => r.name).toList();
    names.sort(compareCaseInsensitive);
    return names;
  }

  Future<List<String>?> findAllGenres() async {
    final rows = await _db.select(_db.genreTable).get();
    final names = rows.map((r) => r.name).toList();
    names.sort(compareCaseInsensitive);
    return names;
  }

  Future<LocalSearchResult?> search(String query) async {
    final likeQuery = '%${query.toLowerCase()}%';

    final trackRows = await (_db.select(_db.trackTable).join([
      leftOuterJoin(
        _db.albumTable,
        _db.albumTable.id.equalsExp(_db.trackTable.album),
      ),
      leftOuterJoin(
        _db.artistTable,
        _db.artistTable.name.equalsExp(_db.trackTable.artist),
      ),
      leftOuterJoin(
        _db.genreTable,
        _db.genreTable.name.equalsExp(_db.trackTable.genre),
      ),
    ])..where(_db.trackTable.name.lower().like(likeQuery))).get();
    final titles = joinedRowsToAudios(trackRows);

    final artistRows = await (_db.select(
      _db.artistTable,
    )..where((t) => t.name.lower().like(likeQuery))).get();
    final artists = artistRows.map((r) => r.name).toList();

    final albumRows = await (_db.select(
      _db.albumTable,
    )..where((t) => t.name.lower().like(likeQuery))).get();
    final albums = albumRows.map((r) => r.id).toList();

    final genreRows = await (_db.select(
      _db.genreTable,
    )..where((t) => t.name.lower().like(likeQuery))).get();
    final genres = genreRows.map((r) => r.name).toList();

    final playlistRows = await (_db.select(
      _db.playlistTable,
    )..where((t) => t.name.lower().like(likeQuery))).get();
    final playlists = playlistRows.map((r) => r.name).toList();

    return LocalSearchResult(
      titles: titles,
      artists: artists,
      albums: albums,
      genres: genres,
      playlists: playlists,
    );
  }

  Future<bool> isAlbumPinned(int id) async {
    final result = await (_db.select(
      _db.albumTable,
    )..where((a) => a.id.equals(id) & a.pinned.equals(true))).getSingleOrNull();
    return result != null;
  }

  Future<bool> isAudioLiked(Audio audio) async {
    if (audio.path == null) false;
    final result = await (_db.select(
      _db.likedTrackTable,
    )..where((t) => t.trackId.equals(audio.path!))).getSingleOrNull();
    return result != null;
  }

  Future<bool> areAudiosLiked(List<Audio> audios) async {
    final paths = audios.map((a) => a.path).whereType<String>().toSet();
    if (paths.isEmpty) return false;

    final query = _db.select(_db.likedTrackTable)
      ..where((t) => t.trackId.isIn(paths));
    final results = await query.get();
    return results.length == paths.length;
  }

  Future<void> moveAudioInPlaylist(
    String id,
    int oldIndex,
    int newIndex,
  ) async {
    if (id == PageIDs.likedAudios) {
      final reordered = _reorderedAudios(
        await findLikedAudios(),
        oldIndex,
        newIndex,
      );
      if (reordered == null) return;

      await _db.transaction(() async {
        await _db.delete(_db.likedTrackTable).go();
        for (final audio in reordered) {
          final trackId = await findTrackIdByPath(audio.path);
          if (trackId != null) {
            await _db
                .into(_db.likedTrackTable)
                .insert(
                  LikedTrackTableCompanion.insert(trackId: trackId),
                  mode: InsertMode.insertOrIgnore,
                );
          }
        }
      });
    } else {
      final plRow = await findPlaylistByName(id);
      if (plRow == null) return;

      final reordered = _reorderedAudios(
        await loadPlaylistTracks(plRow.id),
        oldIndex,
        newIndex,
      );
      if (reordered == null) return;

      await persistPlaylistInDb(id, reordered);
    }
  }

  List<Audio>? _reorderedAudios(List<Audio> list, int oldIndex, int newIndex) {
    if (list.isEmpty || oldIndex < 0 || oldIndex >= list.length) return null;
    if (newIndex > list.length) return null;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final audio = list.removeAt(oldIndex);
    list.insert(newIndex, audio);
    return list;
  }
}
