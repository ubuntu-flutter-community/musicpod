import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:synchronized/synchronized.dart';

import '../app/page_ids.dart';
import '../common/data/audio.dart';
import '../common/logging.dart';
import '../common/view/audio_filter.dart';
import '../extensions/media_file_x.dart';
import '../settings/settings_service.dart';
import '../settings/shared_preferences_keys.dart';
import 'data/change_metadata_capsule.dart';
import 'local_cover_service.dart';
import 'local_search_result.dart';
import 'persistence/local_audio_dao.dart';
import 'playlist_action.dart';

@lazySingleton
class LocalAudioService {
  final SettingsService _settingsService;
  final LocalAudioDao _dao;

  LocalAudioService({
    required LocalCoverService localCoverService,
    required SettingsService settingsService,
    required LocalAudioDao localAudioDao,
  }) : _settingsService = settingsService,
       _dao = localAudioDao;

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
    for (var a in theAudios.sorted(
      (a, b) => a.album == null || b.album == null
          ? 0
          : compareNatural(a.album!.toLowerCase(), b.album!.toLowerCase()),
    )) {
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

    final list = await _dao.loadAlbum(albumId);

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

    final list = await _dao.loadTitlesOfArtist(artist, audioFilter);

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
    bool forceDbOnly = false,
    Function(double progress)? updateProgress,
  }) async {
    List<String> failedImports = [];
    updateProgress?.call(0.25);
    await Future<void>.delayed(Duration.zero);

    await _lock.synchronized(() async {
      if (!forceInit && _initialized) {
        printInfoInDebugMode(
          'Already initialized, skipping',
          tag: '$LocalAudioService',
        );
        updateProgress?.call(1);
        return;
      }

      if (newDirectory != null &&
          newDirectory != _settingsService.getString(SPKeys.directory)) {
        await _settingsService.setValue(SPKeys.directory, newDirectory);
      }

      if (((await _dao.getTrackCount()) > 0) && !forceInit || forceDbOnly) {
        await _loadAndBuildLocalAudioLibrary();
        _initialized = true;
        updateProgress?.call(1);
        return;
      } else {
        await _wipeLocalAudioCachesAndTables();
      }

      final dir = newDirectory ?? _settingsService.getString(SPKeys.directory);
      if (dir != null) {
        final result = await compute(_readAudiosFromDirectory, dir);
        updateProgress?.call(0.5);
        await Future<void>.delayed(Duration.zero);
        failedImports = result.failedImports;

        await _dao.persistAudios(result.audios);
      }
      updateProgress?.call(0.75);
      await Future<void>.delayed(Duration.zero);

      await _loadAndBuildLocalAudioLibrary();
      updateProgress?.call(1);
      await Future<void>.delayed(Duration.zero);

      _initialized = true;
    });

    return (audios: _audios ?? [], failedImports: failedImports);
  }

  Future<bool> areTracksSynced({String? newDir}) async {
    final dir = newDir ?? _settingsService.getString(SPKeys.directory);
    if (dir == null || dir.isEmpty) return true;
    final trackCount = await _dao.getTrackCount();
    final results = await findMediaFiles(dir);
    return trackCount == results.files.length;
  }

  // ── Local Audio Library ──

  Future<void> _loadAndBuildLocalAudioLibrary() async {
    await _loadCollectionsAndBuildCaches();
    await _loadPlaylistsAndPinsAndBuildCaches();
  }

  Future<void> _loadCollectionsAndBuildCaches() async {
    _audios = await _dao.loadAllTracks();
    _allArtists = await _dao.loadAllArtists();
    _allGenres = await _dao.loadAllGenres();

    // Build album IDs
    findAllAlbumIDs();
  }

  Future<void> _loadPlaylistsAndPinsAndBuildCaches() async {
    await loadLikedAudios();
    await loadPlaylists();
    await loadPinnedAlbums();
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
    _likedAudios.clear();
    _pinnedAlbums.clear();
    // then clear all related database tables:
    await _dao.wipeAllLocalAudioTables();
  }

  // ── Liked Audios ──

  List<Audio> _likedAudios = [];
  List<Audio> get likedAudios => _likedAudios;
  int get likedAudiosLength => _likedAudios.length;

  Future<void> loadLikedAudios() async {
    _likedAudios = await _dao.loadLikedAudios();
  }

  Future<void> createOrChangeLikedAudios(PlaylistChange change) async {
    if (change.audios != null &&
        change.audios!.isNotEmpty &&
        (change.action == PlaylistAction.addTo ||
            change.action == PlaylistAction.replaceWith ||
            change.action == PlaylistAction.create)) {
      await _dao.persistAudios(change.audios!);
    }
    if (change.action == PlaylistAction.addTo && change.audios != null) {
      await addLikedAudios(change.audios!);
    } else if (change.action == PlaylistAction.replaceWith &&
        change.audios != null) {
      await removeLikedAudios(_likedAudios.toList());
      await addLikedAudios(change.audios!);
    } else if (change.action == PlaylistAction.removeFrom &&
        change.audios != null) {
      await removeLikedAudios(change.audios!);
    }
  }

  Future<void> addLikedAudios(List<Audio> audios) async {
    for (var audio in audios) {
      _likedAudios.add(audio);
    }
    await _dao.addLikedAudiosToDb(audios);
  }

  bool isLiked(Audio audio) => _likedAudios.contains(audio);

  bool isLikedAudios(List<Audio> audios) {
    if (audios.isEmpty) return false;
    for (var audio in audios) {
      if (!_likedAudios.contains(audio)) return false;
    }
    return true;
  }

  Future<void> removeLikedAudio(Audio audio) async {
    _likedAudios.remove(audio);
    await _dao.removeLikedAudio(audio);
  }

  Future<void> removeLikedAudios(List<Audio> audios) async {
    for (var audio in audios) {
      _likedAudios.remove(audio);
    }
    await _dao.removeLikedAudios(audios);
  }

  Future<void> _persistLikedAudios() async {
    await _dao.persistLikedAudios(_likedAudios);
  }

  // ── Playlists ──

  Map<String, List<Audio>> _playlists = {};
  List<String> get playlistIDs => _playlists.keys.toList();
  List<Audio>? getPlaylistById(String id) =>
      id == PageIDs.likedAudios ? _likedAudios : _playlists[id];
  bool isPlaylistSaved(String? id) =>
      id == null ? false : _playlists.containsKey(id);

  Future<void> createOrChangePlaylist(PlaylistChange change) async {
    if (change.audios != null &&
        change.audios!.isNotEmpty &&
        (change.action == PlaylistAction.addTo ||
            change.action == PlaylistAction.replaceWith ||
            change.action == PlaylistAction.create)) {
      await _dao.persistAudios(change.audios!);
    }
    if (!_playlists.containsKey(change.id)) {
      if (change.action == PlaylistAction.create) {
        await _createPlaylist(
          id: change.id,
          audios: change.audios ?? [],
          external: change.external,
        );
      }
    } else {
      if (change.action == PlaylistAction.addTo && change.audios != null) {
        await _addAudiosToPlaylist(id: change.id, newAudios: change.audios!);
      } else if (change.action == PlaylistAction.replaceWith &&
          change.audios != null) {
        await _replacePlaylist(change.id, change.audios!);
      } else if (change.action == PlaylistAction.removeFrom &&
          change.audios != null) {
        await _removeAudiosFromPlaylist(id: change.id, audios: change.audios!);
      } else if (change.action == PlaylistAction.moveWithin) {
        if (change.oldIndex != null && change.newIndex != null) {
          _moveAudioInPlaylist(
            oldIndex: change.oldIndex!,
            newIndex: change.newIndex!,
            id: change.id,
          );
        }
      } else if (change.action == PlaylistAction.updateName &&
          change.newName != null) {
        await _updatePlaylistName(change.id, change.newName!);
      } else if (change.action == PlaylistAction.delete) {
        await removePlaylist(change.id);
      }
    }

    // Reload the playlist from the database so the in-memory audios carry
    // their freshly persisted `albumDbId`, which is required to render local
    // covers without an app restart.
    if (change.action == PlaylistAction.addTo ||
        change.action == PlaylistAction.replaceWith ||
        change.action == PlaylistAction.create) {
      await _reloadPlaylist(change.id);
    }
  }

  Future<void> loadPlaylists() async {
    _playlists = {};
    final playlistRows = await _dao.loadAllPlaylists();
    for (final pl in playlistRows) {
      _playlists[pl.name] = await _dao.loadPlaylistTracks(pl.id);
    }
  }

  Future<void> _reloadPlaylist(String name) async {
    final plRow = await _dao.findPlaylistByName(name);
    if (plRow == null) return;
    _playlists[name] = await _dao.loadPlaylistTracks(plRow.id);
  }

  Future<void> _createPlaylist({
    required String id,
    required List<Audio> audios,
    bool external = false,
  }) async {
    if (_playlists.containsKey(id)) return;
    final localAudios = audios.where((e) => e.isLocal).toList();
    _playlists[id] = localAudios;

    await _dao.createPlaylistInDb(
      name: id,
      audios: localAudios,
      external: external,
    );

    findAllAlbumIDs(clean: true);
  }

  Future<void> removePlaylist(String id) async {
    if (!_playlists.containsKey(id)) return;
    _playlists.remove(id);
    await _dao.deletePlaylist(id);
  }

  Future<void> _updatePlaylistName(String oldName, String newName) async {
    if (newName == oldName) return;
    final oldList = _playlists[oldName];
    if (oldList != null) {
      _playlists.remove(oldName);
      _playlists[newName] = oldList;
      await _dao.updatePlaylistNameInDb(oldName, newName);
    }
  }

  void _moveAudioInPlaylist({
    required int oldIndex,
    required int newIndex,
    required String id,
  }) {
    final list = id == PageIDs.likedAudios
        ? _likedAudios.toList()
        : _playlists[id]?.toList();

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
      _persistLikedAudios();
    } else {
      _playlists[id] = list;
      _persistPlaylist(id, list);
    }
  }

  Future<void> _persistPlaylist(String name, List<Audio> audios) async {
    await _dao.persistPlaylistInDb(name, audios);
  }

  Future<void> _replacePlaylist(String id, List<Audio> newAudios) async {
    _playlists[id] = newAudios.where((e) => e.isLocal).toList();
    await _persistPlaylist(id, _playlists[id]!);
  }

  Future<void> _addAudiosToPlaylist({
    required String id,
    required List<Audio> newAudios,
  }) async {
    final playlist = _playlists[id];
    if (playlist == null) return;
    if (playlist.toSet().containsAll(newAudios)) {
      return;
    }

    try {
      for (var audio in newAudios) {
        if (!playlist.contains(audio) && audio.isLocal) {
          playlist.add(audio);
        }
      }
      await _persistPlaylist(id, playlist);
    } on Exception catch (e, s) {
      printInfoInDebugMode(e, trace: s, tag: '$LocalAudioService');
    }
  }

  Future<void> _removeAudiosFromPlaylist({
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
    } on Exception catch (e, s) {
      printInfoInDebugMode(e, trace: s, tag: '$LocalAudioService');
    }
  }

  // ── Pinned Albums ──

  List<int> _pinnedAlbums = [];
  List<int> get pinnedAlbums => _pinnedAlbums;

  Future<void> loadPinnedAlbums() async {
    _pinnedAlbums = await _dao.loadPinnedAlbums();
  }

  bool isPinnedAlbum(int id) => _pinnedAlbums.contains(id);

  Future<void> pinAlbum(int id) async {
    if (_pinnedAlbums.contains(id)) return;
    _pinnedAlbums.add(id);
    await _dao.updateAlbumPinned(id, true);
  }

  Future<void> unpinAlbum(int id) async {
    if (!_pinnedAlbums.contains(id)) return;
    _pinnedAlbums.remove(id);
    await _dao.updateAlbumPinned(id, false);
  }

  Future<Audio?> changeMetadata(
    Audio audio,
    ChangeMetadataCapsule capsule,
  ) async {
    Audio? updatedAudio;

    if (audio.path == null) {
      throw Exception('Cannot change metadata of audio without file path');
    }

    try {
      await compute(
        (capsule) => _updateMetadata(audio, capsule),
        ChangeMetadataCapsule(
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

      final newAlbumDbId = await _dao.updateSingleTrackInDb(
        audio,
        artist: capsule.artist,
        album: capsule.album,
        genre: capsule.genre,
        title: capsule.title,
        discNumber: capsule.discNumber,
        trackNumber: capsule.trackNumber,
        year: capsule.year,
        pictures: capsule.pictures,
      );

      final old = audios?.firstWhereOrNull((a) => a.path == audio.path);

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
        }
      }
    } on Exception catch (e, s) {
      printErrorInDebugMode(e, trace: s, tag: '$LocalAudioService');
    }

    return updatedAudio;
  }
}

FutureOr<ImportResult> _readAudiosFromDirectory(String? directory) async {
  final List<Audio> newAudios = [];
  final List<String> failedImports = [];

  if (directory != null && Directory(directory).existsSync()) {
    final results = await findMediaFiles(directory);
    failedImports.addAll(results.failedImports);

    for (final e in results.files) {
      try {
        newAudios.add(Audio.local(e, onError: (p) => failedImports.add(p)));
      } on Exception catch (ex, s) {
        failedImports.add(e.path);
        printErrorInDebugMode(ex, trace: s, tag: '$LocalAudioService');
      }
    }
  }

  printInfoInDebugMode(
    'Finished reading audios from directory. Found ${newAudios.length} audios, with ${failedImports.length} failed imports.',
    tag: '$LocalAudioService',
  );

  return (audios: newAudios, failedImports: failedImports);
}

Future<({Iterable<File> files, List<String> failedImports})> findMediaFiles(
  String directory,
) async {
  final failedImports = <String>[];

  final files =
      (await Directory(directory)
              .list(recursive: true, followLinks: false)
              .handleError((e) => failedImports.add(e.toString()))
              .toList())
          .whereType<File>()
          .where((file) => file.isPlayable);

  return (files: files, failedImports: failedImports);
}

typedef ImportResult = ({List<String> failedImports, List<Audio> audios});

void _updateMetadata(Audio audio, ChangeMetadataCapsule capsule) {
  if (audio.path == null) {
    throw Exception('Audio path is null, cannot update metadata');
  }
  updateMetadata(File(audio.path!), (metadata) {
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
