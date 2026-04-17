import 'dart:async';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:synchronized/synchronized.dart';

import '../app/page_ids.dart';
import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../common/logging.dart';
import '../common/persistence/database.dart';
import '../common/view/audio_filter.dart';
import '../extensions/media_file_x.dart';
import '../settings/settings_service.dart';
import '../settings/shared_preferences_keys.dart';
import 'data/change_metadata_capsule.dart';
import 'local_cover_service.dart';
import 'local_search_result.dart';

@lazySingleton
class LocalAudioService {
  final SettingsService _settingsService;
  final Database _db;

  LocalAudioService({
    required LocalCoverService localCoverService,
    required SettingsService settingsService,
    required Database database,
  }) : _settingsService = settingsService,
       _db = database;

  bool _initialized = false;

  final _propertiesChangedController = StreamController<bool>.broadcast();
  Stream<bool> get propertiesChanged => _propertiesChangedController.stream;

  void _notify() {
    if (_propertiesChangedController.hasListener) {
      _propertiesChangedController.add(true);
    }
  }

  List<Audio>? _audios;
  List<Audio>? get audios => _audios;

  List<String>? _allArtists;
  List<String>? get allArtists => _allArtists;

  List<String>? _allGenres;
  List<String>? get allGenres => _allGenres;

  List<int>? _allAlbumIDs;
  List<int>? get allAlbumIDs => _allAlbumIDs;

  List<int>? findAllAlbumIDs({String? artist, bool clean = true}) {
    if (_audios == null) return null;

    final theAudios = artist == null || artist.isEmpty
        ? _audios!
        : _audios!.where((e) => e.artist == artist);
    final albumsResult = <int>[];
    for (var a in theAudios) {
      final id = a.albumDbId;
      if (id != null && albumsResult.none((e) => e == id)) {
        albumsResult.add(id);
      }
    }

    if (clean) {
      _allAlbumIDs = albumsResult;
      return _allAlbumIDs;
    } else {
      return albumsResult;
    }
  }

  int? findAlbumId({required String artist, required String album}) {
    if (_audios == null) return null;
    return _audios!
        .firstWhereOrNull((a) => a.artist == artist && a.album == album)
        ?.albumDbId;
  }

  String? findAlbumName(int albumId) =>
      _audios?.firstWhereOrNull((a) => a.albumDbId == albumId)?.album;

  String? findArtistOfAlbum(int albumId) =>
      _audios?.firstWhereOrNull((a) => a.albumDbId == albumId)?.artist;

  List<Audio>? getCachedAlbum(int albumId) => _albumCache[albumId];

  final Map<int, List<Audio>?> _albumCache = {};
  Future<List<Audio>?> findAlbum(
    int albumId, [
    AudioFilter audioFilter = AudioFilter.trackNumber,
  ]) async {
    final cached = _albumCache[albumId];
    if (cached != null) return cached;

    final query = _db.select(_db.trackTable).join([
      leftOuterJoin(
        _db.albumTable,
        _db.albumTable.id.equalsExp(_db.trackTable.album),
      ),
      leftOuterJoin(
        _db.artistTable,
        _db.artistTable.id.equalsExp(_db.trackTable.artist),
      ),
      leftOuterJoin(
        _db.genreTable,
        _db.genreTable.id.equalsExp(_db.trackTable.genre),
      ),
    ]);

    query.where(_db.albumTable.id.equals(albumId));
    query.orderBy([
      OrderingTerm.asc(_db.trackTable.discNumber),
      OrderingTerm.asc(_db.trackTable.trackNumber),
    ]);

    final rows = await query.get();
    final list = rows.map((row) {
      final track = row.readTable(_db.trackTable);
      final albumRow = row.readTableOrNull(_db.albumTable);
      final artistRow = row.readTableOrNull(_db.artistTable);
      final genreRow = row.readTableOrNull(_db.genreTable);
      return _trackToAudio(track, albumRow, artistRow, genreRow);
    }).toList();

    _albumCache[albumId] = list;
    return list;
  }

  final Map<String, List<Audio>?> _titlesOfArtistCache = {};
  List<Audio>? getCachedTitlesOfArtist(String artist) =>
      _titlesOfArtistCache[artist];

  Future<List<Audio>?> findTitlesOfArtist(
    String artist, [
    AudioFilter audioFilter = AudioFilter.album,
  ]) async {
    final cached = _titlesOfArtistCache[artist];
    if (cached != null) return cached;

    final query = _db.select(_db.trackTable).join([
      leftOuterJoin(
        _db.albumTable,
        _db.albumTable.id.equalsExp(_db.trackTable.album),
      ),
      innerJoin(
        _db.artistTable,
        _db.artistTable.id.equalsExp(_db.trackTable.artist),
      ),
      leftOuterJoin(
        _db.genreTable,
        _db.genreTable.id.equalsExp(_db.trackTable.genre),
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
    final list = rows.map((row) {
      final track = row.readTable(_db.trackTable);
      final albumRow = row.readTableOrNull(_db.albumTable);
      final artistRow = row.readTableOrNull(_db.artistTable);
      final genreRow = row.readTableOrNull(_db.genreTable);
      return _trackToAudio(track, albumRow, artistRow, genreRow);
    }).toList();

    _titlesOfArtistCache[artist] = list;
    return list;
  }

  List<int>? getCachedAlbumIDsOfGenre(String genre) =>
      _albumIDsOfGenreCache[genre];

  final Map<String, List<int>?> _albumIDsOfGenreCache = {};
  Future<List<int>?> findAlbumIDsOfGenre(String genre) async {
    if (!_initialized) return null;
    final cached = _albumIDsOfGenreCache[genre];
    if (cached != null) return cached;

    final albumIDsOfGenre = <int>[];
    if (_audios != null) {
      for (var a in _audios!) {
        if (a.genre?.trim().isNotEmpty == true &&
            a.genre == genre &&
            a.albumDbId != null &&
            albumIDsOfGenre.none((e) => e == a.albumDbId)) {
          albumIDsOfGenre.add(a.albumDbId!);
        }
      }
    }

    _albumIDsOfGenreCache[genre] = albumIDsOfGenre;
    return albumIDsOfGenre;
  }

  List<Audio> findUniqueAlbumAudios(List<Audio> audios) {
    final albumAudios = <Audio>[];
    for (var audio in audios) {
      if (albumAudios.none((a) => a.albumDbId == audio.albumDbId)) {
        albumAudios.add(audio);
      }
    }
    return albumAudios;
  }

  LocalSearchResult? search(String? query) {
    if (query == null) return null;
    if (query.isEmpty) {
      return const LocalSearchResult(
        titles: [],
        artists: [],
        albums: [],
        genres: [],
        playlists: [],
      );
    }

    final lowerQuery = query.toLowerCase();

    final titleResults =
        _audios
            ?.where(
              (a) =>
                  a.title?.isNotEmpty == true &&
                  a.title!.toLowerCase().contains(lowerQuery),
            )
            .toList() ??
        <Audio>[];

    // Search albums by matching album names in the loaded audios
    final albumsResult = <int>[];
    if (_audios != null) {
      for (var a in _audios!) {
        if (a.album?.toLowerCase().contains(lowerQuery) == true &&
            a.albumDbId != null &&
            albumsResult.none((e) => e == a.albumDbId)) {
          albumsResult.add(a.albumDbId!);
        }
      }
    }

    final genreFindings = <String>[];
    if (_allGenres != null) {
      for (var g in _allGenres!) {
        if (g.toLowerCase().contains(lowerQuery)) {
          genreFindings.add(g);
        }
      }
    }

    return LocalSearchResult(
      titles: titleResults,
      albums: albumsResult,
      genres: genreFindings,
      artists: _allArtists
          ?.where((a) => a.toLowerCase().contains(lowerQuery))
          .toList(),
      playlists: [],
    );
  }

  final Lock _lock = Lock();
  Future<({List<Audio> audios, List<String> failedImports})> init({
    String? newDirectory,
    bool forceInit = false,
    Function(double progress)? updateProgress,
  }) async {
    List<String> failedImports = [];
    updateProgress?.call(0.25);
    await Future<void>.delayed(Duration.zero);

    await _lock.synchronized(() async {
      if (!forceInit && _initialized) {
        printMessageInDebugMode(
          'Already initialized, skipping',
          tag: '$LocalAudioService',
        );
        updateProgress?.call(1);
        return;
      }

      if (!forceInit) {
        // Try loading from database first
        final trackCount = await _db.trackTable.count().getSingle();
        if (trackCount > 0) {
          await _loadAndBuildLocalAudioLibrary();
          _initialized = true;
          updateProgress?.call(1);
          return;
        }
      } else {
        await _wipeLocalAudioCachesAndTables();
      }

      if (newDirectory != null &&
          newDirectory != _settingsService.getString(SPKeys.directory)) {
        await _settingsService.setValue(SPKeys.directory, newDirectory);
      }
      final dir = newDirectory ?? _settingsService.getString(SPKeys.directory);

      final result = await compute(_readAudiosFromDirectory, dir);
      updateProgress?.call(0.5);
      await Future<void>.delayed(Duration.zero);
      failedImports = result.failedImports;

      await _persistAudios(result.audios);
      updateProgress?.call(0.75);
      await Future<void>.delayed(Duration.zero);

      await _loadAndBuildLocalAudioLibrary();
      updateProgress?.call(1);
      await Future<void>.delayed(Duration.zero);

      _initialized = true;
    });

    return (audios: _audios ?? [], failedImports: failedImports);
  }

  Future<void> _persistAudios(List<Audio> audioList) => _db.transaction(
    () async {
      // ── 1. Artists: batch-insert new, then bulk-load IDs ──
      final artistNameToId = <String, int>{};

      // Load existing artists
      final existingArtists = await _db.select(_db.artistTable).get();
      for (final a in existingArtists) {
        artistNameToId[a.name] = a.id;
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
          artistNameToId[a.name] = a.id;
        }
      }

      // ── 2. Genres: batch-insert new, then bulk-load IDs ──
      final genreNameToId = <String, int>{};

      final existingGenres = await _db.select(_db.genreTable).get();
      for (final g in existingGenres) {
        genreNameToId[g.name] = g.id;
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
          genreNameToId[g.name] = g.id;
        }
      }

      // ── 3. Albums: batch-insert new, then bulk-load IDs ──
      final albumKeyToId = <String, int>{};

      final existingAlbums = await _db.select(_db.albumTable).get();
      for (final a in existingAlbums) {
        albumKeyToId['${a.artist}_${a.name}'] = a.id;
      }

      final newAlbumCompanions = <AlbumTableCompanion>[];
      final uniqueAlbums = <String>{};
      for (final a in audioList) {
        if (a.album?.isNotEmpty == true) {
          uniqueAlbums.add(a.album!);
        }
      }
      for (final albumName in uniqueAlbums) {
        final sampleAudio = audioList.firstWhere((a) => a.album == albumName);
        final artistId = sampleAudio.artist != null
            ? artistNameToId[sampleAudio.artist!]
            : null;
        final key = '${artistId ?? ''}_$albumName';
        if (!albumKeyToId.containsKey(key)) {
          newAlbumCompanions.add(
            AlbumTableCompanion.insert(name: albumName, artist: artistId ?? 0),
          );
        }
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
        final albumKey = '${artistId ?? ''}_${audio.album ?? ''}';
        final albumId = audio.album != null ? albumKeyToId[albumKey] : null;
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

  // ── Helpers ──

  Future<int?> _findTrackIdByPath(String? path) async {
    if (path == null) return null;
    final row = await (_db.select(
      _db.trackTable,
    )..where((t) => t.path.equals(path))).getSingleOrNull();
    return row?.id;
  }

  List<Audio> _joinedRowsToAudios(List<TypedResult> rows) => rows.map((row) {
    final track = row.readTable(_db.trackTable);
    final albumRow = row.readTableOrNull(_db.albumTable);
    final artistRow = row.readTableOrNull(_db.artistTable);
    final genreRow = row.readTableOrNull(_db.genreTable);
    return _trackToAudio(track, albumRow, artistRow, genreRow);
  }).toList();

  JoinedSelectStatement _trackJoin(SimpleSelectStatement base) => base.join([
    innerJoin(
      _db.trackTable,
      _db.trackTable.id.equalsExp(_db.likedTrackTable.trackId),
    ),
    leftOuterJoin(
      _db.albumTable,
      _db.albumTable.id.equalsExp(_db.trackTable.album),
    ),
    leftOuterJoin(
      _db.artistTable,
      _db.artistTable.id.equalsExp(_db.trackTable.artist),
    ),
    leftOuterJoin(
      _db.genreTable,
      _db.genreTable.id.equalsExp(_db.trackTable.genre),
    ),
  ]);

  // ── Local Audio Library ──

  Future<void> _loadAndBuildLocalAudioLibrary() async {
    await _loadCollectionsFromDbAndBuildCaches();
    await _loadPlaylistsAndPinsFromDbAndBuildCaches();
    _notify();
  }

  Future<void> _loadCollectionsFromDbAndBuildCaches() async {
    // Load all tracks with joined artist/album names and genre, ordered by title
    final query = _db.select(_db.trackTable).join([
      leftOuterJoin(
        _db.albumTable,
        _db.albumTable.id.equalsExp(_db.trackTable.album),
      ),
      leftOuterJoin(
        _db.artistTable,
        _db.artistTable.id.equalsExp(_db.trackTable.artist),
      ),
      leftOuterJoin(
        _db.genreTable,
        _db.genreTable.id.equalsExp(_db.trackTable.genre),
      ),
    ]);
    query.orderBy([OrderingTerm.asc(_db.trackTable.name)]);

    final rows = await query.get();
    _audios = rows.map((row) {
      final track = row.readTable(_db.trackTable);
      final albumRow = row.readTableOrNull(_db.albumTable);
      final artistRow = row.readTableOrNull(_db.artistTable);
      final genreRow = row.readTableOrNull(_db.genreTable);
      return _trackToAudio(track, albumRow, artistRow, genreRow);
    }).toList();

    // Load all artists sorted
    final artists = await (_db.select(
      _db.artistTable,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
    _allArtists = artists.map((a) => a.name).toList();

    // Load all genres sorted
    final genres = await (_db.select(
      _db.genreTable,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
    _allGenres = genres.map((g) => g.name).toList();

    // Build album IDs
    findAllAlbumIDs();
  }

  Future<void> _loadPlaylistsAndPinsFromDbAndBuildCaches() async {
    await _buildLikedAudiosFromDb();
    await _buildPlaylistsFromDb();
    await _buildExternalPlaylistIDsFromDb();
    await _buildPinnedAlbumsFromDb();
  }

  Future<void> _wipeLocalAudioCachesAndTables() async {
    // clear all local caches, lists and maps:
    _audios?.clear();
    _allArtists?.clear();
    _allGenres?.clear();
    _allAlbumIDs?.clear();
    _albumCache.clear();
    _titlesOfArtistCache.clear();
    _likedAudios.clear();
    _playlists.clear();
    _externalPlaylistIDs.clear();
    _likedAudios.clear();
    _pinnedAlbums.clear();
    // then clear all related database tables:
    await _db.delete(_db.artistTable).go();
    await _db.delete(_db.albumTable).go();
    await _db.delete(_db.albumArtTable).go();
    await _db.delete(_db.genreTable).go();
    await _db.delete(_db.trackTable).go();
    await _db.delete(_db.likedTrackTable).go();
    await _db.delete(_db.playlistTrackTable).go();
    await _db.delete(_db.playlistTable).go();
  }

  // ── Liked Audios ──

  List<Audio> _likedAudios = [];
  List<Audio> get likedAudios => _likedAudios;
  int get likedAudiosLength => _likedAudios.length;

  Future<void> _buildLikedAudiosFromDb() async {
    final rows = await _trackJoin(_db.select(_db.likedTrackTable)).get();
    _likedAudios = _joinedRowsToAudios(rows);
  }

  void addLikedAudio(Audio audio) {
    if (_likedAudios.contains(audio)) return;
    _likedAudios.add(audio);
    _findTrackIdByPath(audio.path).then((trackId) {
      if (trackId != null) {
        _db
            .into(_db.likedTrackTable)
            .insert(
              LikedTrackTableCompanion.insert(trackId: trackId),
              mode: InsertMode.insertOrIgnore,
            )
            .then((_) => _notify());
      }
    });
  }

  void addLikedAudios(List<Audio> audios) {
    for (var audio in audios) {
      _likedAudios.add(audio);
    }
    Future.wait(
      audios.map((audio) async {
        final trackId = await _findTrackIdByPath(audio.path);
        if (trackId != null) {
          await _db
              .into(_db.likedTrackTable)
              .insert(
                LikedTrackTableCompanion.insert(trackId: trackId),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }),
    ).then((_) => _notify());
  }

  bool isLiked(Audio audio) => _likedAudios.contains(audio);

  bool isLikedAudios(List<Audio> audios) {
    if (audios.isEmpty) return false;
    for (var audio in audios) {
      if (!_likedAudios.contains(audio)) return false;
    }
    return true;
  }

  void removeLikedAudio(Audio audio, [bool notify = true]) {
    _likedAudios.remove(audio);
    if (notify) {
      _findTrackIdByPath(audio.path).then((trackId) {
        if (trackId != null) {
          (_db.delete(_db.likedTrackTable)
                ..where((t) => t.trackId.equals(trackId)))
              .go()
              .then((_) => _notify());
        }
      });
    }
  }

  void removeLikedAudios(List<Audio> audios) {
    for (var audio in audios) {
      removeLikedAudio(audio, false);
    }
    Future.wait(
      audios.map((audio) async {
        final trackId = await _findTrackIdByPath(audio.path);
        if (trackId != null) {
          await (_db.delete(
            _db.likedTrackTable,
          )..where((t) => t.trackId.equals(trackId))).go();
        }
      }),
    ).then((_) => _notify());
  }

  Future<void> _persistLikedAudios() async {
    await _db.delete(_db.likedTrackTable).go();
    for (final audio in _likedAudios) {
      final trackId = await _findTrackIdByPath(audio.path);
      if (trackId != null) {
        await _db
            .into(_db.likedTrackTable)
            .insert(
              LikedTrackTableCompanion.insert(trackId: trackId),
              mode: InsertMode.insertOrIgnore,
            );
      }
    }
  }

  // ── Playlists ──

  Map<String, List<Audio>> _playlists = {};
  List<String> get playlistIDs => _playlists.keys.toList();
  List<Audio>? getPlaylistById(String id) =>
      id == PageIDs.likedAudios ? _likedAudios : _playlists[id];
  Map<String, List<Audio>> get playlists => _playlists;
  bool isPlaylistSaved(String? id) =>
      id == null ? false : _playlists.containsKey(id);

  Future<void> _buildPlaylistsFromDb() async {
    _playlists = {};
    final playlistRows = await _db.select(_db.playlistTable).get();
    for (final pl in playlistRows) {
      final trackRows = await (_db.select(_db.playlistTrackTable).join([
        innerJoin(
          _db.trackTable,
          _db.trackTable.id.equalsExp(_db.playlistTrackTable.track),
        ),
        leftOuterJoin(
          _db.albumTable,
          _db.albumTable.id.equalsExp(_db.trackTable.album),
        ),
        leftOuterJoin(
          _db.artistTable,
          _db.artistTable.id.equalsExp(_db.trackTable.artist),
        ),
        leftOuterJoin(
          _db.genreTable,
          _db.genreTable.id.equalsExp(_db.trackTable.genre),
        ),
      ])..where(_db.playlistTrackTable.playlist.equals(pl.id))).get();

      _playlists[pl.name] = _joinedRowsToAudios(trackRows);
    }
  }

  Future<void> addPlaylist({
    required String id,
    required List<Audio> audios,
    bool external = false,
  }) async {
    if (_playlists.containsKey(id)) return;
    final localAudios = audios.where((e) => e.isLocal).toList();
    _playlists[id] = localAudios;

    await _persistAudios(localAudios);

    await _db.transaction(() async {
      final plId = await _db
          .into(_db.playlistTable)
          .insert(
            PlaylistTableCompanion.insert(
              name: id,
              fromExternalSource: Value(external),
            ),
          );

      for (final audio in localAudios) {
        final trackId = await _findTrackIdByPath(audio.path);
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

    findAllAlbumIDs(clean: true);
    _notify();
  }

  Future<void> importExternalPlaylists({
    required List<({String id, List<Audio> audios})> playlists,
  }) async {
    for (var playlist in playlists) {
      await addPlaylist(
        id: playlist.id,
        audios: playlist.audios,
        external: true,
      );
    }
  }

  Future<void> removePlaylist(String id) async {
    if (!_playlists.containsKey(id)) return;
    _playlists.remove(id);

    final plRow = await (_db.select(
      _db.playlistTable,
    )..where((t) => t.name.equals(id))).getSingleOrNull();
    if (plRow != null) {
      await (_db.delete(
        _db.playlistTrackTable,
      )..where((t) => t.playlist.equals(plRow.id))).go();
      await (_db.delete(
        _db.playlistTable,
      )..where((t) => t.id.equals(plRow.id))).go();
    }
    _notify();
  }

  Future<void> updatePlaylistName(String oldName, String newName) async {
    if (newName == oldName) return;
    final oldList = _playlists[oldName];
    if (oldList != null) {
      _playlists.remove(oldName);
      _playlists[newName] = oldList;

      final plRow = await (_db.select(
        _db.playlistTable,
      )..where((t) => t.name.equals(oldName))).getSingleOrNull();
      if (plRow != null) {
        await (_db.update(_db.playlistTable)
              ..where((t) => t.id.equals(plRow.id)))
            .write(PlaylistTableCompanion(name: Value(newName)));
      }
      _notify();
    }
  }

  void moveAudioInPlaylist({
    required int oldIndex,
    required int newIndex,
    required String id,
  }) {
    final list = id == PageIDs.likedAudios
        ? _likedAudios.toList()
        : playlists[id]?.toList();

    if (list == null || list.isEmpty == true || !(newIndex <= list.length)) {
      return;
    }

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final audio = list.removeAt(oldIndex);
    list.insert(newIndex, audio);

    if (id == PageIDs.likedAudios) {
      _likedAudios.clear();
      _likedAudios.addAll(list);
      _persistLikedAudios().then((_) => _notify());
    } else {
      _playlists[id] = list;
      _persistPlaylist(id, list).then((_) => _notify());
    }
  }

  Future<void> _persistPlaylist(String name, List<Audio> audios) async {
    final plRow = await (_db.select(
      _db.playlistTable,
    )..where((t) => t.name.equals(name))).getSingleOrNull();
    if (plRow == null) return;

    await (_db.delete(
      _db.playlistTrackTable,
    )..where((t) => t.playlist.equals(plRow.id))).go();
    for (final audio in audios) {
      var trackId = await _findTrackIdByPath(audio.path);
      if (trackId == null) {
        trackId = await _findTrackIdByPath(audio.path);
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

  Future<void> importAudiosAndAddToPlaylist({
    required String id,
    required List<Audio> newAudios,
  }) async {
    await _persistAudios(newAudios);
    _notify();
    await addAudiosToPlaylist(id: id, newAudios: newAudios);
  }

  Future<void> addAudiosToPlaylist({
    required String id,
    required List<Audio> newAudios,
  }) async {
    final playlist = _playlists[id];
    if (playlist == null) return;
    if (playlist.toSet().containsAll(newAudios)) {
      return;
    }

    try {
      for (var audio in List<Audio>.from(newAudios.where((e) => e.isLocal))) {
        if (!playlist.contains(audio)) {
          playlist.add(audio);
        }
      }
      await _persistPlaylist(id, playlist);
      _notify();
    } on Exception catch (e, s) {
      printMessageInDebugMode(e, trace: s, tag: '$LocalAudioService');
    }
  }

  Future<void> removeAudiosFromPlaylist({
    required String id,
    required List<Audio> audios,
  }) async {
    final playlist = _playlists[id];
    if (playlist == null) return;
    if (playlist.toSet().intersection(audios.toSet()).isEmpty) {
      return;
    }

    try {
      for (var audio in audios) {
        if (playlist.contains(audio)) {
          playlist.remove(audio);
        }
      }
      await _persistPlaylist(id, playlist);

      _notify();
    } on Exception catch (e, s) {
      printMessageInDebugMode(e, trace: s, tag: '$LocalAudioService');
    }
  }

  void clearPlaylist(String id) {
    final playlist = _playlists[id];
    if (playlist != null) {
      playlist.clear();
      _persistPlaylist(id, []).then((_) => _notify());
    }
  }

  List<String> _externalPlaylistIDs = [];
  List<String> get externalPlaylistIDs => _externalPlaylistIDs;

  Future<void> _buildExternalPlaylistIDsFromDb() async {
    final rows = await (_db.select(
      _db.playlistTable,
    )..where((t) => t.fromExternalSource.equals(true))).get();
    _externalPlaylistIDs = rows.map((r) => r.name).toList();
  }

  // ── Pinned Albums ──

  List<int> _pinnedAlbums = [];
  List<int> get pinnedAlbums => _pinnedAlbums;

  Future<void> _buildPinnedAlbumsFromDb() async {
    final rows = await (_db.select(
      _db.albumTable,
    )..where((t) => t.pinned.equals(true))).get();
    _pinnedAlbums = rows.map((r) => r.id).toList();
  }

  bool isPinnedAlbum(int id) => _pinnedAlbums.contains(id);

  void pinAlbum(int id, {required Function() onFail}) {
    if (_pinnedAlbums.contains(id)) return;
    _pinnedAlbums.add(id);
    (_db.update(_db.albumTable)..where((t) => t.id.equals(id)))
        .write(const AlbumTableCompanion(pinned: Value(true)))
        .then((_) => _notify());
  }

  void unpinAlbum(int id, {required Function() onFail}) {
    if (!_pinnedAlbums.contains(id)) return;
    _pinnedAlbums.remove(id);
    (_db.update(_db.albumTable)..where((t) => t.id.equals(id)))
        .write(const AlbumTableCompanion(pinned: Value(false)))
        .then((_) => _notify());
  }

  Audio _trackToAudio(
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

  Future<Audio?> changeMetadata(ChangeMetadataCapsule capsule) async {
    Audio? updatedAudio;

    if (capsule.audio.path == null) {
      throw Exception('Cannot change metadata of audio without file path');
    }

    try {
      await compute(
        _updateMetadata,
        ChangeMetadataCapsule(
          audio: capsule.audio,
          title: capsule.title,
          artist: capsule.artist,
          album: capsule.album,
          genre: capsule.genre,
          discTotal: capsule.discTotal,
          discNumber: capsule.discNumber,
          trackNumber: capsule.trackNumber,
          durationMs: capsule.durationMs,
          year: capsule.year,
          pictures: capsule.pictures,
        ),
      );

      final newAlbumDbId = await _updateSingleTrackInDb(
        capsule.audio,
        artist: capsule.artist,
        album: capsule.album,
        genre: capsule.genre,
        title: capsule.title,
        discNumber: capsule.discNumber,
        trackNumber: capsule.trackNumber,
        year: capsule.year,
        pictures: capsule.pictures,
      );

      final old = audios?.firstWhereOrNull((a) => a.path == capsule.audio.path);

      if (old != null) {
        final updated = old.copyWith(
          title: capsule.title ?? old.title,
          artist: capsule.artist ?? old.artist,
          album: capsule.album ?? old.album,
          albumDbId: newAlbumDbId ?? old.albumDbId,
          genre: capsule.genre ?? old.genre,
          discNumber: capsule.discNumber != null
              ? int.tryParse(capsule.discNumber!) ?? old.discNumber
              : old.discNumber,
          trackNumber: capsule.trackNumber != null
              ? int.tryParse(capsule.trackNumber!) ?? old.trackNumber
              : old.trackNumber,
          year: capsule.year != null
              ? int.tryParse(capsule.year!) ?? old.year
              : old.year,
          pictureData: capsule.pictures != null && capsule.pictures!.isNotEmpty
              ? capsule.pictures!
                        .firstWhereOrNull((e) => e.bytes.isNotEmpty)
                        ?.bytes ??
                    old.pictureData
              : old.pictureData,
          pictureMimeType:
              capsule.pictures != null && capsule.pictures!.isNotEmpty
              ? capsule.pictures!
                        .firstWhereOrNull((e) => e.bytes.isNotEmpty)
                        ?.mimetype ??
                    old.pictureMimeType
              : old.pictureMimeType,
        );
        final index = _audios?.indexOf(old);
        if (index != null && index >= 0) {
          _audios?[index] = updated;
          updatedAudio = updated;

          if (old.artist != capsule.artist || old.album != capsule.album) {
            _albumCache.remove(old.albumDbId);
            if (updated.albumDbId != null) {
              await findAlbum(updated.albumDbId!);
            }
          }
          if (old.artist != capsule.artist) {
            _titlesOfArtistCache.remove(old.artist);
            if (capsule.artist != null) {
              await findTitlesOfArtist(capsule.artist!);
            }
          }
          if (old.genre != capsule.genre) {
            _albumIDsOfGenreCache.remove(old.genre);
            if (capsule.genre != null) {
              await findAlbumIDsOfGenre(capsule.genre!);
            }
          }
          _notify();
        }
      }
    } on Exception catch (e) {
      printMessageInDebugMode(
        'Failed to update metadata for ${capsule.audio.path}: $e',
        tag: '$LocalAudioService',
      );
    }

    return updatedAudio;
  }

  /// Returns the resolved album DB id if album or artist changed, or null.
  Future<int?> _updateSingleTrackInDb(
    Audio audio, {
    String? artist,
    String? album,
    String? genre,
    String? title,
    String? discNumber,
    String? trackNumber,
    String? year,
    List<Picture>? pictures,
  }) async {
    final trackId = await _findTrackIdByPath(audio.path);
    if (trackId != null) {
      // Resolve FKs for changed fields
      Value<int?> artistValue = const Value.absent();
      if (artist != null) {
        final existing = await (_db.select(
          _db.artistTable,
        )..where((t) => t.name.equals(artist))).getSingleOrNull();
        final artistId =
            existing?.id ??
            await _db
                .into(_db.artistTable)
                .insert(ArtistTableCompanion.insert(name: artist));
        artistValue = Value(artistId);
      }

      Value<int?> albumValue = const Value.absent();
      if (album != null) {
        final artistId = artistValue.value;
        final existing =
            await (_db.select(_db.albumTable)..where(
                  (t) => artistId != null
                      ? t.name.equals(album) & t.artist.equals(artistId)
                      : t.name.equals(album),
                ))
                .getSingleOrNull();
        final albumId =
            existing?.id ??
            await _db
                .into(_db.albumTable)
                .insert(
                  AlbumTableCompanion.insert(
                    name: album,
                    artist: artistId ?? 0,
                  ),
                );
        albumValue = Value(albumId);
      }

      Value<int?> genreValue = const Value.absent();
      if (genre != null) {
        final existing = await (_db.select(
          _db.genreTable,
        )..where((t) => t.name.equals(genre))).getSingleOrNull();
        final genreId =
            existing?.id ??
            await _db
                .into(_db.genreTable)
                .insert(GenreTableCompanion.insert(name: genre));
        genreValue = Value(genreId);
      }

      final companion = TrackTableCompanion(
        name: title != null ? Value(title) : const Value.absent(),
        album: albumValue,
        artist: artistValue,
        genre: genreValue,
        discNumber: discNumber != null
            ? Value(int.tryParse(discNumber))
            : const Value.absent(),
        trackNumber: trackNumber != null
            ? Value(int.tryParse(trackNumber))
            : const Value.absent(),
        year: year != null ? Value(int.tryParse(year)) : const Value.absent(),
      );
      await (_db.update(
        _db.trackTable,
      )..where((t) => t.id.equals(trackId))).write(companion);

      // Update album art if pictures were provided
      if (pictures != null && pictures.isNotEmpty) {
        final resolvedAlbumId = albumValue.present
            ? albumValue.value
            : audio.albumDbId;
        if (resolvedAlbumId != null) {
          final pictureData = pictures
              .firstWhereOrNull((e) => e.bytes.isNotEmpty)
              ?.bytes;
          final pictureMimeType = pictures.first.mimetype;
          if (pictureData != null) {
            // Remove existing art for this album, then insert new
            await (_db.delete(
              _db.albumArtTable,
            )..where((t) => t.album.equals(resolvedAlbumId))).go();
            await _db
                .into(_db.albumArtTable)
                .insert(
                  AlbumArtTableCompanion.insert(
                    album: resolvedAlbumId,
                    pictureData: pictureData,
                    pictureMimeType: pictureMimeType,
                  ),
                );
          }
        }
      }
      return albumValue.present ? albumValue.value : null;
    }
    return null;
  }
}

FutureOr<ImportResult> _readAudiosFromDirectory(String? directory) async {
  final List<Audio> newAudios = [];
  final List<String> failedImports = [];

  if (directory != null && Directory(directory).existsSync()) {
    final files =
        (await Directory(directory)
                .list(recursive: true, followLinks: false)
                .handleError((e) => failedImports.add(e.toString()))
                .toList())
            .whereType<File>();

    for (final e in files) {
      if (e.isPlayable) {
        try {
          newAudios.add(Audio.local(e, onError: (p) => failedImports.add(p)));
        } on Exception catch (ex) {
          failedImports.add(e.path);
          printMessageInDebugMode(ex);
        }
      }
    }
  }

  printMessageInDebugMode(
    'Finished reading audios from directory. Found ${newAudios.length} audios, with ${failedImports.length} failed imports.',
    tag: '$LocalAudioService',
  );

  return (audios: newAudios, failedImports: failedImports);
}

typedef ImportResult = ({List<String> failedImports, List<Audio> audios});

void _updateMetadata(ChangeMetadataCapsule capsule) {
  if (capsule.audio.path == null) {
    throw Exception('Audio path is null, cannot update metadata');
  }
  updateMetadata(File(capsule.audio.path!), (metadata) {
    if (capsule.title != null) {
      metadata.setTitle(capsule.title);
    }
    if (capsule.artist != null) {
      metadata.setArtist(capsule.artist);
    }
    if (capsule.album != null) {
      metadata.setAlbum(capsule.album);
    }
    if (capsule.genre != null) {
      metadata.setGenres([capsule.genre!]);
    }
    if (capsule.trackNumber != null &&
        int.tryParse(capsule.trackNumber!) != null) {
      metadata.setTrackNumber(int.tryParse(capsule.trackNumber!));
    }
    if (capsule.year != null && int.tryParse(capsule.year!) != null) {
      metadata.setYear(DateTime(int.parse(capsule.year!)));
    }
    if (capsule.pictures?.isNotEmpty ?? false) {
      metadata.setPictures(capsule.pictures!);
    }
  });
}
