import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../../constants.dart';
import '../../data.dart';
import '../../patch_notes.dart';
import '../../utils.dart';

Future<void> _writeCache(Set<Audio> audios) async {
  await writeAudioMap(
    {
      kLocalAudioCache: audios,
    },
    kLocalAudioCacheFileName,
  );
}

Future<void> _readCache(Set<Audio>? localAudioCache) async {
  localAudioCache =
      (await readAudioMap(kLocalAudioCacheFileName))[kLocalAudioCache];
}

class LibraryService {
  Future<void> writeLocalAudioCache({required Set<Audio> audios}) async {
    await compute(_writeCache, audios);
  }

  Set<Audio>? _localAudioCache;
  Set<Audio>? get localAudioCache => _localAudioCache;
  Future<Set<Audio>?> _readLocalAudioCache() async {
    await compute(_readCache, _localAudioCache);
    return (await readAudioMap(kLocalAudioCacheFileName))[kLocalAudioCache];
  }

  Future<void> setUseLocalCache(bool value) async {
    await writeSetting(kUseLocalAudioCache, value ? 'true' : 'false');
    _useLocalAudioCache = value;
    _useLocalAudioCacheController.add(true);
  }

  bool? _useLocalAudioCache;
  bool? get useLocalAudioCache => _useLocalAudioCache;
  final _useLocalAudioCacheController = StreamController<bool>.broadcast();
  Stream<bool> get useLocalAudioCacheChanged =>
      _useLocalAudioCacheController.stream;

  Future<void> _readUseLocalAudioCache() async {
    String? value = await readSetting(kUseLocalAudioCache);
    if (value != null) {
      _useLocalAudioCache = bool.parse(value);
    }
  }

  //
  // last positions
  //
  Map<String, Duration>? _lastPositions = {};
  Map<String, Duration>? get lastPositions => _lastPositions;
  final _lastPositionsController = StreamController<bool>.broadcast();
  Stream<bool> get lastPositionsChanged => _lastPositionsController.stream;
  void addLastPosition(String url, Duration lastPosition) {
    if (_lastPositions?.containsKey(url) == true) {
      _lastPositions?.update(url, (value) => lastPosition);
    } else {
      _lastPositions?.putIfAbsent(url, () => lastPosition);
    }

    writeSetting(url, lastPosition.toString(), kLastPositionsFileName)
        .then((_) => _lastPositionsController.add(true));
  }

  Duration? getLastPosition(String? url) => _lastPositions?[url];

  //
  // Liked Audios
  //
  Set<Audio> _likedAudios = {};
  Set<Audio> get likedAudios => _likedAudios;
  final _likedAudiosController = StreamController<bool>.broadcast();
  Stream<bool> get likedAudiosChanged => _likedAudiosController.stream;

  void addLikedAudio(Audio audio, [bool notify = true]) {
    _likedAudios.add(audio);
    if (notify) {
      writeAudioMap({'likedAudios': _likedAudios}, kLikedAudios)
          .then((value) => _likedAudiosController.add(true));
    }
  }

  void addLikedAudios(Set<Audio> audios) {
    for (var audio in audios) {
      addLikedAudio(audio, false);
    }
    writeAudioMap({'likedAudios': _likedAudios}, kLikedAudios)
        .then((value) => _likedAudiosController.add(true));
  }

  bool liked(Audio audio) {
    return likedAudios.contains(audio);
  }

  void removeLikedAudio(Audio audio, [bool notify = true]) {
    _likedAudios.remove(audio);
    if (notify) {
      writeAudioMap({'likedAudios': _likedAudios}, kLikedAudios)
          .then((value) => _likedAudiosController.add(true));
    }
  }

  void removeLikedAudios(Set<Audio> audios) {
    for (var audio in audios) {
      removeLikedAudio(audio, false);
    }
    writeAudioMap({'likedAudios': _likedAudios}, kLikedAudios)
        .then((value) => _likedAudiosController.add(true));
  }

  //
  // Starred stations
  //

  Map<String, Set<Audio>> _starredStations = {};
  Map<String, Set<Audio>> get starredStations => _starredStations;
  int get starredStationsLength => _starredStations.length;
  final _starredStationsController = StreamController<bool>.broadcast();
  Stream<bool> get starredStationsChanged => _starredStationsController.stream;

  void addStarredStation(String name, Set<Audio> audios) {
    _starredStations.putIfAbsent(name, () => audios);
    writeAudioMap(_starredStations, kStarredStationsFileName)
        .then((_) => _starredStationsController.add(true));
  }

  void unStarStation(String name) {
    _starredStations.remove(name);
    writeAudioMap(_starredStations, kStarredStationsFileName)
        .then((_) => _starredStationsController.add(true));
  }

  bool isStarredStation(String name) {
    return _starredStations.containsKey(name);
  }

  Set<String> _favTags = {};
  Set<String> get favTags => _favTags;
  bool isFavTag(String value) => _favTags.contains(value);
  final _favTagsController = StreamController<bool>.broadcast();
  Stream<bool> get favTagsChanged => _favTagsController.stream;

  void addFavTag(String name) {
    if (favTags.contains(name)) return;
    _favTags.add(name);
    writeStringSet(set: _favTags, filename: kTagFavsFileName)
        .then((_) => _favTagsController.add(true));
  }

  void removeFavTag(String name) {
    if (!favTags.contains(name)) return;
    _favTags.remove(name);
    writeStringSet(set: _favTags, filename: kTagFavsFileName)
        .then((_) => _favTagsController.add(true));
  }

  String? _lastFav;
  String? get lastFav => _lastFav;
  void setLastFav(String? value) {
    if (value == _lastFav) return;
    _lastFav = value;
    writeSetting(kLastFav, value).then((_) => _lastFavController.add(true));
  }

  final _lastFavController = StreamController<bool>.broadcast();
  Stream<bool> get lastFavChanged => _lastFavController.stream;

  //
  // Playlists
  //

  Map<String, Set<Audio>> _playlists = {};
  Map<String, Set<Audio>> get playlists => _playlists;
  final _playlistsController = StreamController<bool>.broadcast();
  Stream<bool> get playlistsChanged => _playlistsController.stream;

  void addPlaylist(String name, Set<Audio> audios) {
    _playlists.putIfAbsent(name, () => audios);
    writeAudioMap(_playlists, kPlaylistsFileName)
        .then((_) => _playlistsController.add(true));
  }

  void removePlaylist(String name) {
    _playlists.remove(name);
    writeAudioMap(_playlists, kPlaylistsFileName)
        .then((_) => _playlistsController.add(true));
  }

  void updatePlaylistName(String oldName, String newName) {
    if (newName == oldName) return;
    final oldList = _playlists[oldName];
    if (oldList != null) {
      _playlists.remove(oldName);
      _playlists.putIfAbsent(newName, () => oldList);
    }

    writeAudioMap(_playlists, kPlaylistsFileName)
        .then((_) => _playlistsController.add(true));
  }

  void addAudioToPlaylist(String playlist, Audio audio) {
    final p = _playlists[playlist];
    if (p != null) {
      for (var e in p) {
        if (e.path == audio.path) {
          return;
        }
      }
      p.add(audio);
    }
    writeAudioMap(_playlists, kPlaylistsFileName)
        .then((_) => _playlistsController.add(true));
  }

  void removeAudioFromPlaylist(String playlist, Audio audio) {
    final p = _playlists[playlist];
    if (p != null && p.contains(audio)) {
      p.remove(audio);
    }
    writeAudioMap(_playlists, kPlaylistsFileName)
        .then((_) => _playlistsController.add(true));
  }

  // Podcasts

  Map<String, Set<Audio>> _podcasts = {};
  Map<String, Set<Audio>> get podcasts => _podcasts;
  int get podcastsLength => _podcasts.length;
  final _podcastsController = StreamController<bool>.broadcast();
  Stream<bool> get podcastsChanged => _podcastsController.stream;

  void addPodcast(String feedUrl, Set<Audio> audios) {
    _podcasts.putIfAbsent(feedUrl, () => audios);
    writeAudioMap(_podcasts, kPodcastsFileName)
        .then((_) => _podcastsController.add(true));
  }

  void updatePodcast(String feedUrl, Set<Audio> audios) {
    if (feedUrl.isEmpty || audios.isEmpty) return;
    _podcasts.update(feedUrl, (value) => audios);
    writeAudioMap(_podcasts, kPodcastsFileName)
        .then((_) => _podcastsController.add(true))
        .then((_) => podcastUpdates.add(feedUrl))
        .then((_) => _updateController.add(true));
  }

  final Set<String> podcastUpdates = {};
  bool podcastUpdateAvailable(String feedUrl) =>
      podcastUpdates.contains(feedUrl);
  void removePodcastUpdate(String feedUrl) {
    podcastUpdates.remove(feedUrl);
    _updateController.add(true);
  }

  final _updateController = StreamController<bool>.broadcast();
  Stream<bool> get updatesChanged => _updateController.stream;

  void removePodcast(String name) {
    _podcasts.remove(name);
    writeAudioMap(_podcasts, kPodcastsFileName)
        .then((_) => _podcastsController.add(true));
  }

  //
  // Albums
  //

  Map<String, Set<Audio>> _pinnedAlbums = {};
  Map<String, Set<Audio>> get pinnedAlbums => _pinnedAlbums;
  int get pinnedAlbumsLength => _pinnedAlbums.length;
  final _albumsController = StreamController<bool>.broadcast();
  Stream<bool> get albumsChanged => _albumsController.stream;

  List<Audio> getAlbumAt(int index) =>
      _pinnedAlbums.entries.elementAt(index).value.toList();

  bool isPinnedAlbum(String name) => _pinnedAlbums.containsKey(name);

  void addPinnedAlbum(String name, Set<Audio> audios) {
    _pinnedAlbums.putIfAbsent(name, () => audios);
    writeAudioMap(_pinnedAlbums, kPinnedAlbumsFileName)
        .then((_) => _albumsController.add(true));
  }

  void removePinnedAlbum(String name) {
    _pinnedAlbums.remove(name);
    writeAudioMap(_pinnedAlbums, kPinnedAlbumsFileName)
        .then((_) => _albumsController.add(true));
  }

  bool _neverShowFailedImports = false;
  bool get neverShowFailedImports => _neverShowFailedImports;
  final _neverShowFailedImportsController = StreamController<bool>.broadcast();
  Stream<bool> get neverShowFailedImportsChanged =>
      _neverShowFailedImportsController.stream;
  Future<void> setNeverShowFailedImports() async {
    _neverShowFailedImports = !_neverShowFailedImports;
    await writeSetting(
      kNeverShowImportFails,
      _neverShowFailedImports.toString(),
    );
    _neverShowFailedImportsController.add(true);
  }

  Future<void> init() async {
    await _initSettings();
    await _initLibrary();
  }

  bool _libraryInitialized = false;
  Future<void> _initLibrary() async {
    if (_libraryInitialized) return;
    if (_useLocalAudioCache == true) {
      await _readLocalAudioCache();
    }
    _playlists = await readAudioMap(kPlaylistsFileName);
    _pinnedAlbums = await readAudioMap(kPinnedAlbumsFileName);
    _podcasts = await readAudioMap(kPodcastsFileName);
    _starredStations = await readAudioMap(kStarredStationsFileName);
    _lastPositions = (await getSettings(kLastPositionsFileName)).map(
      (key, value) => MapEntry(key, parseDuration(value) ?? Duration.zero),
    );
    _likedAudios =
        (await readAudioMap(kLikedAudios)).entries.firstOrNull?.value ??
            <Audio>{};
    _favTags = (await readStringSet(filename: kTagFavsFileName));
    _libraryInitialized = true;
  }

  bool _settingsInitialized = false;
  Future<void> _initSettings() async {
    if (_settingsInitialized) return;

    await _readUseLocalAudioCache();

    await _readRecentPatchNotesDisposed();

    var neverShowImportsOrNull = await readSetting(kNeverShowImportFails);
    _neverShowFailedImports = neverShowImportsOrNull == null
        ? false
        : bool.parse(neverShowImportsOrNull);

    final appIndexOrNull = await readSetting(kAppIndex);
    _appIndex = appIndexOrNull == null ? 0 : int.parse(appIndexOrNull);

    final localAudioIndexOrNull = await readSetting(kLocalAudioIndex);
    _localAudioIndex =
        localAudioIndexOrNull == null ? 0 : int.parse(localAudioIndexOrNull);

    _settingsInitialized = true;
  }

  int? _localAudioIndex;
  int? get localAudioIndex => _localAudioIndex;
  final _localAudioIndexController = StreamController<int?>.broadcast();
  Stream<int?> get localAudioIndexStream => _localAudioIndexController.stream;
  void setLocalAudioIndex(int? value) {
    _localAudioIndex = value;
  }

  int? _appIndex;
  int? get appIndex => _appIndex;
  void setAppIndex(int? value) {
    _appIndex = value;
  }

  Future<void> dispose() async {
    await safeStates();
    await _useLocalAudioCacheController.close();
    await _albumsController.close();
    await _podcastsController.close();
    await _likedAudiosController.close();
    await _playlistsController.close();
    await _starredStationsController.close();
    await _favTagsController.close();
    await _lastPositionsController.close();
    await _localAudioIndexController.close();
    await _neverShowFailedImportsController.close();
    await _lastFavController.close();
    await _updateController.close();
  }

  Future<void> safeStates() async {
    await writeSetting(kLocalAudioIndex, _localAudioIndex.toString());
    await writeSetting(kAppIndex, _appIndex.toString());
    await writePlayerState();
  }

  Future<void> disposePatchNotes() async {
    await writeSetting(
      kPatchNotesDisposed,
      kRecentPatchNotesDisposed,
    );
  }

  bool _recentPatchNotesDisposed = false;
  bool get recentPatchNotesDisposed => _recentPatchNotesDisposed;

  Future<void> _readRecentPatchNotesDisposed() async {
    String? value = await readSetting(kPatchNotesDisposed);
    if (value == kRecentPatchNotesDisposed) {
      _recentPatchNotesDisposed = true;
    }
  }

  Future<void> writePlayerState() async {
    await writeSetting(kLastPositionAsString, _position.toString());
    await writeSetting(kLastDurationAsString, _duration.toString());
    await writeSetting(kLastAudio, _lastAudio?.toJson());
  }

  Duration? _duration;
  void setDuration(Duration? duration) => _duration = duration;
  Duration? _position;
  void setPosition(Duration? position) => _position = position;
  Audio? _lastAudio;
  void setLastAudio(Audio? audio) => _lastAudio = audio;

  Future<(Duration?, Duration?, Audio?)> readPlayerState() async {
    Duration? position, duration;
    Audio? audio;
    final positionAsString = await readSetting(kLastPositionAsString);
    final durationAsString = await readSetting(kLastDurationAsString);
    if (positionAsString != null) {
      position = parseDuration(positionAsString);
    }
    if (durationAsString != null) {
      duration = parseDuration(durationAsString);
    }
    final maybeAudio = await readSetting(kLastAudio);
    if (maybeAudio != null) {
      audio = Audio.fromJson(maybeAudio);
    }

    return (position, duration, audio);
  }
}
