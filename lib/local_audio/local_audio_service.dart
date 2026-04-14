import 'dart:async';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:synchronized/synchronized.dart';

import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../common/logging.dart';
import '../common/persistence/database.dart';
import '../common/view/audio_filter.dart';
import '../app/page_ids.dart';
import '../extensions/media_file_x.dart';
import '../settings/settings_service.dart';
import '../settings/shared_preferences_keys.dart';
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
        _db.albumArtTable,
        _db.albumArtTable.album.equalsExp(_db.albumTable.id),
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
      final albumArt = row.readTableOrNull(_db.albumArtTable);
      final genreRow = row.readTableOrNull(_db.genreTable);
      return _trackToAudio(track, albumRow, artistRow, albumArt, genreRow);
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
        _db.albumArtTable,
        _db.albumArtTable.album.equalsExp(_db.albumTable.id),
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
      final albumArt = row.readTableOrNull(_db.albumArtTable);
      final genreRow = row.readTableOrNull(_db.genreTable);
      return _trackToAudio(track, albumRow, artistRow, albumArt, genreRow);
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
    List<Audio> extraAudios = const [],
  }) async {
    List<String> failedImports = [];

    await _lock.synchronized(() async {
      if (!forceInit && _initialized) {
        printMessageInDebugMode(
          'Already initialized, skipping',
          tag: '$LocalAudioService',
        );
        return;
      }

      if (!forceInit) {
        // Try loading from database first
        final trackCount = await _db.trackTable.count().getSingle();
        if (trackCount > 0) {
          await _loadCollectionsFromDb();
          await initLocalAudioLibrary();
          _initialized = true;
          return;
        }
      }

      if (newDirectory != null &&
          newDirectory != _settingsService.getString(SPKeys.directory)) {
        await _settingsService.setValue(SPKeys.directory, newDirectory);
      }
      final dir = newDirectory ?? _settingsService.getString(SPKeys.directory);

      final result = await compute(_readAudiosFromDirectory, dir);
      failedImports = result.failedImports;

      final allAudios = [...result.audios];
      if (extraAudios.isNotEmpty) {
        allAudios.addAll(extraAudios.where((e) => e.isLocal));
      }

      if (forceInit) {
        _albumCache.clear();
        _titlesOfArtistCache.clear();
        _albumIDsOfGenreCache.clear();
        await _db.delete(_db.trackTable).go();
        await _db.delete(_db.albumArtTable).go();
        await _db.delete(_db.albumTable).go();
        await _db.delete(_db.artistTable).go();
        await _db.delete(_db.genreTable).go();
      }

      await _persistAudios(allAudios);
      await _loadCollectionsFromDb();
      await initLocalAudioLibrary();
      _initialized = true;
    });
    return (audios: _audios ?? [], failedImports: failedImports);
  }

  Future<void> _persistAudios(List<Audio> audioList) async {
    // Multi-pass: first collect unique artists, albums & genres, insert, then tracks.
    final artistNameToId = <String, int>{};
    final albumKeyToId = <String, int>{};
    final genreNameToId = <String, int>{};

    // Collect unique artists
    final uniqueArtists = <String>{};
    for (final a in audioList) {
      if (a.artist?.isNotEmpty == true) uniqueArtists.add(a.artist!);
      if (a.albumArtist?.isNotEmpty == true) uniqueArtists.add(a.albumArtist!);
    }

    for (final name in uniqueArtists) {
      final existing = await (_db.select(
        _db.artistTable,
      )..where((t) => t.name.equals(name))).getSingleOrNull();
      if (existing != null) {
        artistNameToId[name] = existing.id;
      } else {
        final id = await _db
            .into(_db.artistTable)
            .insert(ArtistTableCompanion.insert(name: name));
        artistNameToId[name] = id;
      }
    }

    // Collect unique genres
    final uniqueGenres = <String>{};
    for (final a in audioList) {
      if (a.genre?.trim().isNotEmpty == true) uniqueGenres.add(a.genre!.trim());
    }

    for (final name in uniqueGenres) {
      final existing = await (_db.select(
        _db.genreTable,
      )..where((t) => t.name.equals(name))).getSingleOrNull();
      if (existing != null) {
        genreNameToId[name] = existing.id;
      } else {
        final id = await _db
            .into(_db.genreTable)
            .insert(GenreTableCompanion.insert(name: name));
        genreNameToId[name] = id;
      }
    }

    // Collect unique albums
    final uniqueAlbums = <String>{};
    for (final a in audioList) {
      if (a.album?.isNotEmpty == true) {
        uniqueAlbums.add(a.album!);
      }
    }

    for (final albumName in uniqueAlbums) {
      // Find first audio with this album to get artist reference
      final sampleAudio = audioList.firstWhere((a) => a.album == albumName);
      final artistId = sampleAudio.artist != null
          ? artistNameToId[sampleAudio.artist!]
          : null;
      final key = '${artistId ?? ''}_$albumName';

      final existing =
          await (_db.select(_db.albumTable)..where((t) {
                if (artistId != null) {
                  return t.name.equals(albumName) & t.artist.equals(artistId);
                }
                return t.name.equals(albumName);
              }))
              .getSingleOrNull();

      if (existing != null) {
        albumKeyToId[key] = existing.id;
      } else {
        final id = await _db
            .into(_db.albumTable)
            .insert(
              AlbumTableCompanion.insert(
                name: albumName,
                artist: artistId ?? 0,
              ),
            );
        albumKeyToId[key] = id;
      }
    }

    // Insert tracks
    for (final audio in audioList) {
      if (audio.path == null) continue;

      final existing = await (_db.select(
        _db.trackTable,
      )..where((t) => t.path.equals(audio.path!))).getSingleOrNull();
      if (existing != null) continue;

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

      await _db
          .into(_db.trackTable)
          .insert(
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

      // Insert album art if this track has picture data and no art exists yet
      if (albumId != null &&
          audio.pictureData != null &&
          audio.pictureMimeType != null) {
        await _db
            .into(_db.albumArtTable)
            .insert(
              AlbumArtTableCompanion.insert(
                album: albumId,
                pictureData: audio.pictureData!,
                pictureMimeType: audio.pictureMimeType!,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    }
  }

  Future<void> _loadCollectionsFromDb() async {
    // Load all tracks with joined artist/album names, album art and genre, ordered by title
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
        _db.albumArtTable,
        _db.albumArtTable.album.equalsExp(_db.albumTable.id),
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
      final albumArt = row.readTableOrNull(_db.albumArtTable);
      final genreRow = row.readTableOrNull(_db.genreTable);
      return _trackToAudio(track, albumRow, artistRow, albumArt, genreRow);
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
    final albumArt = row.readTableOrNull(_db.albumArtTable);
    final genreRow = row.readTableOrNull(_db.genreTable);
    return _trackToAudio(track, albumRow, artistRow, albumArt, genreRow);
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
      _db.albumArtTable,
      _db.albumArtTable.album.equalsExp(_db.albumTable.id),
    ),
    leftOuterJoin(
      _db.genreTable,
      _db.genreTable.id.equalsExp(_db.trackTable.genre),
    ),
  ]);

  // ── Local Audio Library ──

  Future<void> initLocalAudioLibrary() async {
    await _loadLikedAudios();
    await _loadPlaylists();
    await _loadExternalPlaylistIDs();
    await _loadPinnedAlbums();
    _notify();
  }

  Future<void> wipeLocalAudioLibrary() async {
    await _db.delete(_db.likedTrackTable).go();
    await _db.delete(_db.albumTable).go();
    await _db.delete(_db.playlistTrackTable).go();
    await _db.delete(_db.playlistTable).go();
    await _db.delete(_db.artistTable).go();
    await _db.delete(_db.albumArtTable).go();
    await _db.delete(_db.genreTable).go();
    await initLocalAudioLibrary();
  }

  // ── Liked Audios ──

  List<Audio> _likedAudios = [];
  List<Audio> get likedAudios => _likedAudios;
  int get likedAudiosLength => _likedAudios.length;

  Future<void> _loadLikedAudios() async {
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

  Future<void> _loadPlaylists() async {
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
          _db.albumArtTable,
          _db.albumArtTable.album.equalsExp(_db.albumTable.id),
        ),
        leftOuterJoin(
          _db.genreTable,
          _db.genreTable.id.equalsExp(_db.trackTable.genre),
        ),
      ])..where(_db.playlistTrackTable.playlist.equals(pl.id))).get();

      _playlists[pl.name] = _joinedRowsToAudios(trackRows);
    }
  }

  Future<void> addPlaylist(String id, List<Audio> audios) async {
    if (_playlists.containsKey(id)) return;
    final localAudios = audios.where((e) => e.isLocal).toList();
    _playlists[id] = localAudios;

    final plId = await _db
        .into(_db.playlistTable)
        .insert(PlaylistTableCompanion.insert(name: id));
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
    _notify();
  }

  Future<void> addExternalPlaylists({
    required List<({String id, List<Audio> audios})> playlists,
  }) async {
    if (playlists.isEmpty) return;
    for (var playlist in playlists) {
      if (!_playlists.containsKey(playlist.id) &&
          playlist.audios.any((e) => e.isLocal)) {
        final localAudios = playlist.audios.where((e) => e.isLocal).toList();
        _playlists[playlist.id] = localAudios;

        final plId = await _db
            .into(_db.playlistTable)
            .insert(
              PlaylistTableCompanion.insert(
                name: playlist.id,
                fromExternalSource: const Value(true),
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
      }
    }
    _notify();
  }

  Future<void> updatePlaylist({
    required String id,
    required List<Audio> audios,
    bool external = false,
  }) async {
    if (!_playlists.containsKey(id)) return;
    final filteredAudios = audios
        .where((e) => e.isLocal || e.isPodcast)
        .toList();
    _playlists[id] = filteredAudios;

    final plRow = await (_db.select(
      _db.playlistTable,
    )..where((t) => t.name.equals(id))).getSingleOrNull();
    if (plRow == null) return;

    if (external) {
      await (_db.update(_db.playlistTable)..where((t) => t.id.equals(plRow.id)))
          .write(const PlaylistTableCompanion(fromExternalSource: Value(true)));
    }

    await (_db.delete(
      _db.playlistTrackTable,
    )..where((t) => t.playlist.equals(plRow.id))).go();
    for (final audio in filteredAudios) {
      final trackId = await _findTrackIdByPath(audio.path);
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
    _notify();
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
      final trackId = await _findTrackIdByPath(audio.path);
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

  void addAudiosToPlaylist({required String id, required List<Audio> audios}) {
    final playlist = _playlists[id];
    if (playlist == null) return;

    for (var audio in audios) {
      if (audio.isLocal && !playlist.contains(audio)) {
        playlist.add(audio);
      }
    }
    _persistPlaylist(id, playlist).then((_) => _notify());
  }

  void removeAudiosFromPlaylist({
    required String id,
    required List<Audio> audios,
  }) {
    final playlist = _playlists[id];
    if (playlist == null) return;

    for (var audio in audios) {
      if (playlist.contains(audio)) {
        playlist.remove(audio);
      }
    }
    _persistPlaylist(id, playlist).then((_) => _notify());
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

  Future<void> _loadExternalPlaylistIDs() async {
    final rows = await (_db.select(
      _db.playlistTable,
    )..where((t) => t.fromExternalSource.equals(true))).get();
    _externalPlaylistIDs = rows.map((r) => r.name).toList();
  }

  List<Audio> get externalPlaylistAudios {
    if (_externalPlaylistIDs.isEmpty) return [];
    return [for (var e in _externalPlaylistIDs) ...getPlaylistById(e) ?? []];
  }

  List<Audio> get playlistsAudios {
    if (_playlists.isEmpty) return [];
    return [for (var e in _playlists.entries) ...e.value];
  }

  // ── Pinned Albums ──

  List<int> _pinnedAlbums = [];
  List<int> get pinnedAlbums => _pinnedAlbums;

  Future<void> _loadPinnedAlbums() async {
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
    AlbumArtTableData? albumArt,
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
      pictureData: albumArt?.pictureData,
      pictureMimeType: albumArt?.pictureMimeType,
      trackNumber: track.trackNumber,
      year: track.year,
      lyrics: track.lyrics,
    );
  }

  void changeMetadata(
    Audio audio, {
    Function? onChange,
    String? title,
    String? artist,
    String? album,
    String? genre,
    String? discTotal,
    String? discNumber,
    String? trackNumber,
    String? durationMs,
    String? year,
    List<Picture>? pictures,
  }) {
    if (audio.path != null) {
      final file = File(audio.path!);
      if (file.existsSync()) {
        updateMetadata(file, (metadata) {
          try {
            if (title != null) {
              metadata.setTitle(title);
            }
            if (artist != null) {
              metadata.setArtist(artist);
            }
            if (album != null) {
              metadata.setAlbum(album);
            }
            if (genre != null) {
              metadata.setGenres([genre]);
            }
            if (trackNumber != null && int.tryParse(trackNumber) != null) {
              metadata.setTrackNumber(int.tryParse(trackNumber));
            }
            if (year != null && int.tryParse(year) != null) {
              metadata.setYear(DateTime(int.parse(year)));
            }
            if (pictures?.isNotEmpty ?? false) {
              metadata.setPictures(pictures!);
            }

            // Not supported yet
            // if (discNumber != null) {
            //   metadata.setDiscNumber(discNumber);
            // }
            // if (discTotal != null) {
            //   metadata.setDiscTotal(discTotal);
            // }
            // if (durationMs != null) {
            //   metadata.setDuration(durationMs);
            // }
            // if (albumArtist != null) {
            //   metadata.setAlbumArtist(albumArtist);
            // }

            onChange?.call();
          } on Exception catch (e) {
            printMessageInDebugMode(e);
          }
        });
      }
    }
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
