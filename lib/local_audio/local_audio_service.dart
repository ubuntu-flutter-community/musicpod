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
import '../extensions/media_file_x.dart';
import '../settings/settings_service.dart';
import '../settings/shared_preferences_keys.dart';
import 'local_cover_service.dart';
import 'local_search_result.dart';

@lazySingleton
class LocalAudioService {
  final SettingsService _settingsService;
  final LocalCoverService _localCoverService;
  final Database _db;

  LocalAudioService({
    required LocalCoverService localCoverService,
    required SettingsService settingsService,
    required Database database,
  }) : _settingsService = settingsService,
       _localCoverService = localCoverService,
       _db = database;

  bool _initialized = false;

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
      return trackToAudio(track, albumRow, artistRow, albumArt, genreRow);
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
      return trackToAudio(track, albumRow, artistRow, albumArt, genreRow);
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

  Set<Uint8List>? findLocalCovers({
    required List<Audio> audios,
    int limit = 4,
  }) {
    final images = <Uint8List>{};
    final albumAudios = findUniqueAlbumAudios(audios);

    for (var audio in albumAudios) {
      final uint8list = _localCoverService.get(audio.albumDbId);
      if (uint8list != null && images.length < limit) {
        images.add(uint8list);
      }
    }

    return images;
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
        final existingArt = await (_db.select(
          _db.albumArtTable,
        )..where((t) => t.album.equals(albumId))).getSingleOrNull();
        if (existingArt == null) {
          await _db
              .into(_db.albumArtTable)
              .insert(
                AlbumArtTableCompanion.insert(
                  album: albumId,
                  pictureData: audio.pictureData!,
                  pictureMimeType: audio.pictureMimeType!,
                ),
              );
        }
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
      return trackToAudio(track, albumRow, artistRow, albumArt, genreRow);
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

  Audio trackToAudio(
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
