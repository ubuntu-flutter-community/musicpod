import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../common/data/audio.dart';
import '../app/page_ids.dart';
import '../common/persistence/database.dart';
import '../extensions/date_time_x.dart';
import '../local_audio/local_audio_service.dart';

@singleton
class LibraryService {
  LibraryService({
    required Database database,
    required LocalAudioService localAudioService,
  }) : _db = database,
       _localAudioService = localAudioService;

  final Database _db;
  final LocalAudioService _localAudioService;

  final _propertiesChangedController = StreamController<bool>.broadcast();
  Stream<bool> get propertiesChanged => _propertiesChangedController.stream;

  void _notify() => _propertiesChangedController.add(true);

  @PostConstruct(preResolve: true)
  Future<void> init() async {
    await _loadLikedAudios();
    await _loadStarredStations();
    await _loadFavRadioTags();
    await _loadFavCountryCodes();
    await _loadFavLanguageCodes();
    await _loadPlaylists();
    await _loadExternalPlaylistIDs();
    await _loadPodcastCache();
    await _loadPodcastUpdates();
    await _loadDownloads();
    await _loadFavoriteAlbums();
    await _loadSelectedPageId();
  }

  @disposeMethod
  Future<void> dispose() => _propertiesChangedController.close();

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
    return _localAudioService.trackToAudio(
      track,
      albumRow,
      artistRow,
      albumArt,
      genreRow,
    );
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

  // ── Starred stations ──

  List<String> _starredStations = [];
  List<String> get starredStations => _starredStations;
  int get starredStationsLength => _starredStations.length;

  Future<void> _loadStarredStations() async {
    final rows = await _db.select(_db.starredStationTable).get();
    _starredStations = rows.map((r) => r.uuid).toList();
  }

  void addStarredStation(String uuid) {
    if (_starredStations.contains(uuid)) return;
    _starredStations.add(uuid);
    _db
        .into(_db.starredStationTable)
        .insert(
          StarredStationTableCompanion.insert(uuid: uuid),
          mode: InsertMode.insertOrIgnore,
        )
        .then((_) => _notify());
  }

  void addStarredStations(List<String?> uuids) {
    if (uuids.isEmpty) return;
    for (var uuid in uuids) {
      if (uuid != null && uuid.isNotEmpty && !_starredStations.contains(uuid)) {
        _starredStations.add(uuid);
        _db
            .into(_db.starredStationTable)
            .insert(
              StarredStationTableCompanion.insert(uuid: uuid),
              mode: InsertMode.insertOrIgnore,
            );
      }
    }
    _notify();
  }

  void removeStarredStation(String uuid) {
    if (!_starredStations.contains(uuid)) return;
    _starredStations.remove(uuid);
    (_db.delete(
      _db.starredStationTable,
    )..where((t) => t.uuid.equals(uuid))).go().then((_) => _notify());
  }

  void unStarAllStations() {
    if (_starredStations.isEmpty) return;
    _starredStations.clear();
    _db.delete(_db.starredStationTable).go().then((_) => _notify());
  }

  bool isStarredStation(String? uuid) => _starredStations.contains(uuid);

  // ── Fav radio tags ──

  Set<String> _favRadioTags = {};
  Set<String> get favRadioTags => _favRadioTags;
  bool isFavTag(String value) => _favRadioTags.contains(value);

  Future<void> _loadFavRadioTags() async {
    final rows = await _db.select(_db.favoriteRadioTagTable).get();
    _favRadioTags = rows.map((r) => r.name).toSet();
  }

  void addFavRadioTag(String name) {
    if (_favRadioTags.contains(name)) return;
    _favRadioTags.add(name);
    _db
        .into(_db.favoriteRadioTagTable)
        .insert(
          FavoriteRadioTagTableCompanion.insert(name: name),
          mode: InsertMode.insertOrIgnore,
        )
        .then((_) => _notify());
  }

  void removeFavRadioTag(String name) {
    if (!_favRadioTags.contains(name)) return;
    _favRadioTags.remove(name);
    (_db.delete(
      _db.favoriteRadioTagTable,
    )..where((t) => t.name.equals(name))).go().then((_) => _notify());
  }

  // ── Fav country codes ──

  Set<String> _favCountryCodes = {};
  Set<String> get favCountryCodes => _favCountryCodes;
  bool isFavCountry(String value) => _favCountryCodes.contains(value);

  Future<void> _loadFavCountryCodes() async {
    final rows = await _db.select(_db.favoriteCountryTable).get();
    _favCountryCodes = rows.map((r) => r.code).toSet();
  }

  void addFavCountryCode(String name) {
    if (_favCountryCodes.contains(name)) return;
    _favCountryCodes.add(name);
    _db
        .into(_db.favoriteCountryTable)
        .insert(
          FavoriteCountryTableCompanion.insert(code: name),
          mode: InsertMode.insertOrIgnore,
        )
        .then((_) => _notify());
  }

  void removeFavCountryCode(String name) {
    if (!_favCountryCodes.contains(name)) return;
    _favCountryCodes.remove(name);
    (_db.delete(
      _db.favoriteCountryTable,
    )..where((t) => t.code.equals(name))).go().then((_) => _notify());
  }

  // ── Fav language codes ──

  Set<String> _favLanguageCodes = {};
  Set<String> get favLanguageCodes => _favLanguageCodes;
  bool isFavLanguage(String value) => _favLanguageCodes.contains(value);

  Future<void> _loadFavLanguageCodes() async {
    final rows = await _db.select(_db.favoriteLanguageTable).get();
    _favLanguageCodes = rows.map((r) => r.isoCode).toSet();
  }

  void addFavLanguageCode(String name) {
    if (_favLanguageCodes.contains(name)) return;
    _favLanguageCodes.add(name);
    _db
        .into(_db.favoriteLanguageTable)
        .insert(
          FavoriteLanguageTableCompanion.insert(isoCode: name),
          mode: InsertMode.insertOrIgnore,
        )
        .then((_) => _notify());
  }

  void removeFavLanguageCode(String name) {
    if (!_favLanguageCodes.contains(name)) return;
    _favLanguageCodes.remove(name);
    (_db.delete(
      _db.favoriteLanguageTable,
    )..where((t) => t.isoCode.equals(name))).go().then((_) => _notify());
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

  // ── Podcasts ──

  Map<String, String> _downloads = {};
  Map<String, String> get downloads => _downloads;
  String? getDownload(String? url) => _downloads[url];

  Set<String> _feedsWithDownloads = {};
  bool feedHasDownloads(String feedUrl) =>
      _feedsWithDownloads.contains(feedUrl);
  int get feedsWithDownloadsLength => _feedsWithDownloads.length;

  Future<void> _loadDownloads() async {
    final rows = await _db.select(_db.downloadTable).get();
    _downloads = {for (final r in rows) r.url: r.filePath};
    _feedsWithDownloads = rows.map((r) => r.feedUrl).toSet();
  }

  void addDownload({
    required String url,
    required String path,
    required String feedUrl,
  }) {
    if (_downloads.containsKey(url)) return;
    _downloads[url] = path;
    _feedsWithDownloads.add(feedUrl);
    _db
        .into(_db.downloadTable)
        .insert(
          DownloadTableCompanion.insert(
            url: url,
            filePath: path,
            feedUrl: feedUrl,
          ),
          mode: InsertMode.insertOrIgnore,
        )
        .then((_) => _notify());
  }

  void removeDownload({required String url, required String feedUrl}) {
    _deleteDownload(url);

    if (_downloads.containsKey(url)) {
      _downloads.remove(url);
      _feedsWithDownloads.remove(feedUrl);
      (_db.delete(
        _db.downloadTable,
      )..where((t) => t.url.equals(url))).go().then((_) => _notify());
    }
  }

  void _deleteDownload(String url) {
    final path = _downloads[url];
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }

  void removeAllDownloads() {
    for (var download in _downloads.entries) {
      _deleteDownload(download.key);
    }
    _downloads.clear();
    _feedsWithDownloads.clear();
    _db.delete(_db.downloadTable).go().then((_) => _notify());
  }

  void _removeFeedWithDownload(String feedUrl) {
    if (!_feedsWithDownloads.contains(feedUrl)) return;
    _feedsWithDownloads.remove(feedUrl);
    (_db.delete(
      _db.downloadTable,
    )..where((t) => t.feedUrl.equals(feedUrl))).go().then((_) => _notify());
  }

  Set<String> _podcasts = {};
  bool isPodcastSubscribed(String feedUrl) => _podcasts.contains(feedUrl);
  List<String> get podcastFeedUrls => _podcasts.toList();
  Set<String> get podcasts => _podcasts;
  int get podcastsLength => _podcasts.length;

  Map<String, PodcastTableData> _podcastCache = {};

  Future<void> _loadPodcastCache() async {
    final rows = await _db.select(_db.podcastTable).get();
    _podcastCache = {for (final r in rows) r.feedUrl: r};
    _podcasts = rows.map((r) => r.feedUrl).toSet();
  }

  String? getSubscribedPodcastImage(String feedUrl) =>
      _podcastCache[feedUrl]?.imageUrl;

  void addSubscribedPodcastImage({
    required String feedUrl,
    required String imageUrl,
  }) {
    (_db.update(_db.podcastTable)..where((t) => t.feedUrl.equals(feedUrl)))
        .write(PodcastTableCompanion(imageUrl: Value(imageUrl)))
        .then((_) {
          final cached = _podcastCache[feedUrl];
          if (cached != null) {
            _podcastCache[feedUrl] = cached.copyWith(imageUrl: Value(imageUrl));
          }
          _notify();
        });
  }

  void removeSubscribedPodcastImage(String feedUrl) {
    (_db.update(_db.podcastTable)..where((t) => t.feedUrl.equals(feedUrl)))
        .write(const PodcastTableCompanion(imageUrl: Value(null)));
  }

  String? getSubscribedPodcastName(String feedUrl) =>
      _podcastCache[feedUrl]?.name;

  void addSubscribedPodcastName({
    required String feedUrl,
    required String name,
  }) {
    (_db.update(_db.podcastTable)..where((t) => t.feedUrl.equals(feedUrl)))
        .write(PodcastTableCompanion(name: Value(name)));
    final cached = _podcastCache[feedUrl];
    if (cached != null) {
      _podcastCache[feedUrl] = cached.copyWith(name: name);
    }
  }

  void removeSubscribedPodcastName(String feedUrl) {}

  String? getSubscribedPodcastArtist(String feedUrl) =>
      _podcastCache[feedUrl]?.artist;

  void addSubscribedPodcastArtist({
    required String feedUrl,
    required String artist,
  }) {
    (_db.update(_db.podcastTable)..where((t) => t.feedUrl.equals(feedUrl)))
        .write(PodcastTableCompanion(artist: Value(artist)))
        .then((_) {
          final cached = _podcastCache[feedUrl];
          if (cached != null) {
            _podcastCache[feedUrl] = cached.copyWith(artist: artist);
          }
          _notify();
        });
  }

  void removeSubscribedPodcastArtist(String feedUrl) {}

  Future<void> addPodcast({
    required String feedUrl,
    required String? imageUrl,
    required String name,
    required String artist,
  }) async {
    if (isPodcastSubscribed(feedUrl)) return;
    _podcasts.add(feedUrl);
    final now = DateTime.now();
    await _db
        .into(_db.podcastTable)
        .insert(
          PodcastTableCompanion.insert(
            feedUrl: feedUrl,
            name: name,
            artist: artist,
            description: '',
            imageUrl: Value(imageUrl),
            lastUpdated: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    _podcastCache[feedUrl] = PodcastTableData(
      feedUrl: feedUrl,
      name: name,
      artist: artist,
      description: '',
      imageUrl: imageUrl,
      lastUpdated: now,
      ascending: false,
    );
    _notify();
  }

  Future<void> addPodcasts(
    List<({String feedUrl, String? imageUrl, String name, String artist})>
    podcasts,
  ) async {
    if (podcasts.isEmpty) return;
    for (var p in podcasts) {
      if (!_podcasts.contains(p.feedUrl)) {
        _podcasts.add(p.feedUrl);
        final now = DateTime.now();
        await _db
            .into(_db.podcastTable)
            .insert(
              PodcastTableCompanion.insert(
                feedUrl: p.feedUrl,
                name: p.name,
                artist: p.artist,
                description: '',
                imageUrl: Value(p.imageUrl),
                lastUpdated: now,
              ),
              mode: InsertMode.insertOrIgnore,
            );
        _podcastCache[p.feedUrl] = PodcastTableData(
          feedUrl: p.feedUrl,
          name: p.name,
          artist: p.artist,
          description: '',
          imageUrl: p.imageUrl,
          lastUpdated: now,
          ascending: false,
        );
      }
    }
    _notify();
  }

  bool showPodcastAscending(String feedUrl) =>
      _podcastCache[feedUrl]?.ascending ?? false;

  Future<void> reorderPodcast({
    required String feedUrl,
    required bool ascending,
  }) async {
    await (_db.update(_db.podcastTable)
          ..where((t) => t.feedUrl.equals(feedUrl)))
        .write(PodcastTableCompanion(ascending: Value(ascending)));
    final cached = _podcastCache[feedUrl];
    if (cached != null) {
      _podcastCache[feedUrl] = cached.copyWith(ascending: ascending);
    }
    _notify();
  }

  Set<String>? _podcastUpdates;
  int? get podcastUpdatesLength => _podcastUpdates?.length;

  Future<void> _loadPodcastUpdates() async {
    final rows = await _db.select(_db.podcastUpdateTable).get();
    _podcastUpdates = rows.map((r) => r.podcastFeedUrl).toSet();
  }

  Future<void> addPodcastLastUpdated({
    required String feedUrl,
    required String timestamp,
  }) async {
    final dt =
        DateTime.tryParse(timestamp.replaceAll('_', '-')) ?? DateTime.now();
    await (_db.update(_db.podcastTable)
          ..where((t) => t.feedUrl.equals(feedUrl)))
        .write(PodcastTableCompanion(lastUpdated: Value(dt)));
    final cached = _podcastCache[feedUrl];
    if (cached != null) {
      _podcastCache[feedUrl] = cached.copyWith(lastUpdated: dt);
    }
    _notify();
  }

  String? getPodcastLastUpdated(String feedUrl) =>
      _podcastCache[feedUrl]?.lastUpdated.toPodcastTimeStamp;

  bool podcastUpdateAvailable(String feedUrl) =>
      _podcastUpdates?.contains(feedUrl) == true;

  Future<void> addPodcastUpdate(String feedUrl, DateTime lastUpdated) async {
    if (_podcastUpdates?.contains(feedUrl) == true) return;
    _podcastUpdates?.add(feedUrl);
    await _db
        .into(_db.podcastUpdateTable)
        .insert(
          PodcastUpdateTableCompanion.insert(podcastFeedUrl: feedUrl),
          mode: InsertMode.insertOrIgnore,
        );
    _notify();
  }

  Future<void> removePodcastUpdate(String feedUrl) async {
    if (_podcastUpdates?.isNotEmpty == false) return;
    _podcastUpdates?.remove(feedUrl);
    await (_db.delete(
      _db.podcastUpdateTable,
    )..where((t) => t.podcastFeedUrl.equals(feedUrl))).go();
    _notify();
  }

  void removePodcast(String feedUrl) {
    if (!isPodcastSubscribed(feedUrl)) return;
    _podcasts.remove(feedUrl);
    _podcastCache.remove(feedUrl);
    _removeFeedWithDownload(feedUrl);
    (_db.delete(
      _db.podcastUpdateTable,
    )..where((t) => t.podcastFeedUrl.equals(feedUrl))).go();
    (_db.delete(
      _db.podcastTable,
    )..where((t) => t.feedUrl.equals(feedUrl))).go().then((_) => _notify());
  }

  Future<void> removeAllPodcasts() async {
    _podcasts.clear();
    _podcastUpdates?.clear();
    _podcastCache.clear();
    await _db.delete(_db.podcastUpdateTable).go();
    await _db.delete(_db.podcastTable).go();
    _notify();
  }

  // ── Albums ──

  List<int> _favoriteAlbums = [];
  List<int> get favoriteAlbums => _favoriteAlbums;

  Future<void> _loadFavoriteAlbums() async {
    final rows = await _db.select(_db.pinnedAlbumTable).get();
    _favoriteAlbums = rows.map((r) => r.albumId).toList();
  }

  bool isFavoriteAlbum(int id) => _favoriteAlbums.contains(id);

  void addFavoriteAlbum(int id, {required Function() onFail}) {
    if (_favoriteAlbums.contains(id)) return;
    _favoriteAlbums.add(id);
    _db
        .into(_db.pinnedAlbumTable)
        .insert(
          PinnedAlbumTableCompanion.insert(albumId: id),
          mode: InsertMode.insertOrIgnore,
        )
        .then((_) => _notify());
  }

  void removeFavoriteAlbum(int id, {required Function() onFail}) {
    if (!_favoriteAlbums.contains(id)) return;
    _favoriteAlbums.remove(id);
    (_db.delete(
      _db.pinnedAlbumTable,
    )..where((t) => t.albumId.equals(id))).go().then((_) => _notify());
  }

  // ── Selected page ──

  String? _selectedPageId;
  String? get selectedPageId => _selectedPageId;

  Future<void> _loadSelectedPageId() async {
    final row = await (_db.select(
      _db.appSettingTable,
    )..where((t) => t.key.equals('selectedPage'))).getSingleOrNull();
    _selectedPageId = row?.value;
  }

  Future<void> setSelectedPageId(String value) async {
    _selectedPageId = value;
    await _db
        .into(_db.appSettingTable)
        .insertOnConflictUpdate(
          AppSettingTableCompanion.insert(key: 'selectedPage', value: value),
        );
    _notify();
  }

  bool isPageInLibrary(String? pageId) =>
      pageId != null &&
      (PageIDs.permanent.contains(pageId) ||
          (int.tryParse(pageId) != null &&
              _favoriteAlbums.contains(int.parse(pageId))) ||
          isStarredStation(pageId) ||
          isPlaylistSaved(pageId) ||
          isPodcastSubscribed(pageId));
}
