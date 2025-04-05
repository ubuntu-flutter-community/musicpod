import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/data/audio.dart';
import '../common/file_names.dart';
import '../common/page_ids.dart';
import '../common/view/audio_filter.dart';
import '../extensions/shared_preferences_x.dart';
import '../persistence_utils.dart';

class LibraryService {
  LibraryService({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;

  final _propertiesChangedController = StreamController<bool>.broadcast();
  Stream<bool> get propertiesChanged => _propertiesChangedController.stream;

  //
  // Liked Audios
  //
  List<Audio> _likedAudios = [];
  List<Audio> get likedAudios => _likedAudios;

  void addLikedAudio(Audio audio, [bool notify = true]) {
    if (_likedAudios.contains(audio)) return;
    _likedAudios.add(audio);
    if (notify) {
      writeAudioMap(
        map: {PageIDs.likedAudios: _likedAudios},
        fileName: FileNames.likedAudios,
      ).then((value) => _propertiesChangedController.add(true));
    }
  }

  void addLikedAudios(List<Audio> audios) {
    for (var audio in audios) {
      addLikedAudio(audio, false);
    }
    writeAudioMap(
      map: {PageIDs.likedAudios: _likedAudios},
      fileName: FileNames.likedAudios,
    ).then((value) => _propertiesChangedController.add(true));
  }

  bool liked(Audio audio) {
    return likedAudios.contains(audio);
  }

  void removeLikedAudio(Audio audio, [bool notify = true]) {
    _likedAudios.remove(audio);
    if (notify) {
      writeAudioMap(
        map: {PageIDs.likedAudios: _likedAudios},
        fileName: FileNames.likedAudios,
      ).then((value) => _propertiesChangedController.add(true));
    }
  }

  void removeLikedAudios(List<Audio> audios) {
    for (var audio in audios) {
      removeLikedAudio(audio, false);
    }
    writeAudioMap(
      map: {PageIDs.likedAudios: _likedAudios},
      fileName: FileNames.likedAudios,
    ).then((value) => _propertiesChangedController.add(true));
  }

  //
  // Starred stations
  //

  Map<String, List<Audio>> _starredStations = {};
  Map<String, List<Audio>> get starredStations => _starredStations;
  int get starredStationsLength => _starredStations.length;

  void addStarredStation(String uuid, List<Audio> audios) {
    _starredStations.putIfAbsent(uuid, () => audios);
    writeAudioMap(map: _starredStations, fileName: FileNames.starredStations)
        .then((_) => _propertiesChangedController.add(true));
  }

  void addStarredStations(
    List<(String uuid, List<Audio> audios)> stations,
  ) {
    if (stations.isEmpty) return;
    for (var station in stations) {
      if (!_starredStations.containsKey(station.$1)) {
        _starredStations.putIfAbsent(station.$1, () => station.$2);
      }
    }
    writeAudioMap(map: _starredStations, fileName: FileNames.starredStations)
        .then((_) => _propertiesChangedController.add(true));
  }

  void unStarStation(String uuid) {
    _starredStations.remove(uuid);
    writeAudioMap(map: _starredStations, fileName: FileNames.starredStations)
        .then((_) => _propertiesChangedController.add(true));
  }

  Future<void> unStarAllStations() async {
    _starredStations.clear();
    return writeAudioMap(
      map: _starredStations,
      fileName: FileNames.starredStations,
    ).then((_) => _propertiesChangedController.add(true));
  }

  bool isStarredStation(String? uuid) {
    return uuid == null ? false : _starredStations.containsKey(uuid);
  }

  Set<String> get favRadioTags =>
      _sharedPreferences.getStringList(SPKeys.favRadioTags)?.toSet() ?? {};
  bool isFavTag(String value) => favRadioTags.contains(value);

  void addFavRadioTag(String name) {
    if (favRadioTags.contains(name)) return;
    final Set<String> tags = favRadioTags;
    tags.add(name);
    _sharedPreferences.setStringList(SPKeys.favRadioTags, tags.toList()).then(
      (saved) {
        if (saved) _propertiesChangedController.add(true);
      },
    );
  }

  void removeFavRadioTag(String name) {
    if (!favRadioTags.contains(name)) return;
    final Set<String> tags = favRadioTags;
    tags.remove(name);
    _sharedPreferences.setStringList(SPKeys.favRadioTags, tags.toList()).then(
      (saved) {
        if (saved) _propertiesChangedController.add(true);
      },
    );
  }

  String? get lastCountryCode =>
      _sharedPreferences.getString(SPKeys.lastCountryCode);
  void setLastCountryCode(String value) {
    _sharedPreferences.setString(SPKeys.lastCountryCode, value).then(
      (saved) {
        if (saved) _propertiesChangedController.add(true);
      },
    );
  }

  Set<String> get favCountryCodes =>
      _sharedPreferences.getStringList(SPKeys.favCountryCodes)?.toSet() ?? {};
  bool isFavCountry(String value) => favCountryCodes.contains(value);

  void addFavCountryCode(String name) {
    if (favCountryCodes.contains(name)) return;
    final favCodes = favCountryCodes;
    favCodes.add(name);
    _sharedPreferences
        .setStringList(SPKeys.favCountryCodes, favCodes.toList())
        .then((saved) {
      if (saved) _propertiesChangedController.add(true);
    });
  }

  void removeFavCountryCode(String name) {
    if (!favCountryCodes.contains(name)) return;
    final favCodes = favCountryCodes;
    favCodes.remove(name);
    _sharedPreferences
        .setStringList(SPKeys.favCountryCodes, favCodes.toList())
        .then((saved) {
      if (saved) _propertiesChangedController.add(true);
    });
  }

  String? get lastLanguageCode =>
      _sharedPreferences.getString(SPKeys.lastLanguageCode);
  void setLastLanguageCode(String value) {
    _sharedPreferences.setString(SPKeys.lastLanguageCode, value).then((saved) {
      if (saved) _propertiesChangedController.add(true);
    });
  }

  Set<String> get favLanguageCodes =>
      _sharedPreferences.getStringList(SPKeys.favLanguageCodes)?.toSet() ?? {};
  bool isFavLanguage(String value) => favLanguageCodes.contains(value);

  void addFavLanguageCode(String name) {
    if (favLanguageCodes.contains(name)) return;
    final favLangs = favLanguageCodes;
    favLangs.add(name);
    _sharedPreferences
        .setStringList(SPKeys.favLanguageCodes, favLangs.toList())
        .then(
      (saved) {
        if (saved) _propertiesChangedController.add(true);
      },
    );
  }

  void removeFavLanguageCode(String name) {
    if (!favLanguageCodes.contains(name)) return;
    final favLangs = favLanguageCodes;
    favLangs.remove(name);
    _sharedPreferences
        .setStringList(SPKeys.favLanguageCodes, favLangs.toList())
        .then(
      (saved) {
        if (saved) _propertiesChangedController.add(true);
      },
    );
  }

  //
  // Playlists
  //

  Map<String, List<Audio>> _playlists = {};
  Map<String, List<Audio>> get playlists => _playlists;
  bool isPlaylistSaved(String? id) =>
      id == null ? false : _playlists.containsKey(id);

  Future<void> addPlaylist(String id, List<Audio> audios) async {
    if (!_playlists.containsKey(id)) {
      _playlists.putIfAbsent(id, () => audios);
      await writeAudioMap(map: _playlists, fileName: FileNames.playlists)
          .then((_) => _propertiesChangedController.add(true));
    }
  }

  Future<void> updatePlaylist(String id, List<Audio> audios) async {
    if (_playlists.containsKey(id)) {
      await writeAudioMap(map: _playlists, fileName: FileNames.playlists)
          .then((_) {
        _playlists.update(
          id,
          (value) => audios,
        );
        _propertiesChangedController.add(true);
      });
    }
  }

  void removePlaylist(String id) {
    if (_playlists.containsKey(id)) {
      writeAudioMap(map: _playlists, fileName: FileNames.playlists).then(
        (_) {
          _playlists.remove(id);
          _propertiesChangedController.add(true);
        },
      );
    }
  }

  void updatePlaylistName(String oldName, String newName) {
    if (newName == oldName) return;
    final oldList = _playlists[oldName];
    if (oldList != null) {
      _playlists.remove(oldName);
      _playlists.putIfAbsent(newName, () => oldList);
      writeAudioMap(map: _playlists, fileName: FileNames.playlists)
          .then((_) => _propertiesChangedController.add(true));
    }
  }

  void moveAudioInPlaylist({
    required int oldIndex,
    required int newIndex,
    required String id,
  }) {
    final audios = id == PageIDs.likedAudios
        ? likedAudios.toList()
        : playlists[id]?.toList();

    if (audios == null ||
        audios.isEmpty == true ||
        !(newIndex < audios.length)) {
      return;
    }

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final audio = audios.removeAt(oldIndex);
    audios.insert(newIndex, audio);

    if (id == PageIDs.likedAudios) {
      writeAudioMap(
        map: {PageIDs.likedAudios: _likedAudios},
        fileName: FileNames.likedAudios,
      ).then((value) {
        likedAudios.clear();
        likedAudios.addAll(audios);
        _propertiesChangedController.add(true);
      });
    } else {
      writeAudioMap(map: _playlists, fileName: FileNames.likedAudios).then((_) {
        _playlists.update(id, (value) => audios);
        _propertiesChangedController.add(true);
      });
    }
  }

  void addAudiosToPlaylist({required String id, required List<Audio> audios}) {
    final playlist = _playlists[id];
    if (playlist == null) return;

    for (var audio in audios) {
      if (!playlist.contains(audio)) {
        playlist.add(audio);
      }
    }
    writeAudioMap(map: _playlists, fileName: FileNames.playlists)
        .then((_) => _propertiesChangedController.add(true));
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
    writeAudioMap(map: _playlists, fileName: FileNames.playlists)
        .then((_) => _propertiesChangedController.add(true));
  }

  void clearPlaylist(String id) {
    final playlist = _playlists[id];
    if (playlist != null) {
      playlist.clear();
      writeAudioMap(map: _playlists, fileName: FileNames.playlists)
          .then((_) => _propertiesChangedController.add(true));
    }
  }

  ///
  /// Podcasts
  ///
  Map<String, String> _downloads = {};
  Map<String, String> get downloads => _downloads;
  String? getDownload(String? url) => downloads[url];

  Set<String> _feedsWithDownloads = {};
  bool feedHasDownloads(String feedUrl) =>
      _feedsWithDownloads.contains(feedUrl);
  int get feedsWithDownloadsLength => _feedsWithDownloads.length;

  void addDownload({
    required String url,
    required String path,
    required String feedUrl,
  }) {
    if (_downloads.containsKey(url)) return;
    _downloads.putIfAbsent(url, () => path);
    _feedsWithDownloads.add(feedUrl);
    writeStringMap(_downloads, FileNames.downloads)
        .then(
          (_) => writeStringIterable(
            iterable: _feedsWithDownloads,
            filename: FileNames.feedsWithDownloads,
          ),
        )
        .then((_) => _propertiesChangedController.add(true));
  }

  void removeDownload({required String url, required String feedUrl}) {
    _deleteDownload(url);

    if (_downloads.containsKey(url)) {
      _downloads.remove(url);
      _feedsWithDownloads.remove(feedUrl);

      _updateDownloads();
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

  void _updateDownloads() {
    writeStringMap(_downloads, FileNames.downloads)
        .then(
          (_) => writeStringIterable(
            iterable: _feedsWithDownloads,
            filename: FileNames.feedsWithDownloads,
          ),
        )
        .then((_) => _propertiesChangedController.add(true));
  }

  void removeAllDownloads() {
    for (var download in _downloads.entries) {
      _deleteDownload(download.key);
    }
    _downloads.clear();
    _feedsWithDownloads.clear();
    _updateDownloads();
  }

  void _removeFeedWithDownload(String feedUrl) {
    if (!_feedsWithDownloads.contains(feedUrl)) return;
    _feedsWithDownloads.remove(feedUrl);
    writeStringIterable(
      iterable: _feedsWithDownloads,
      filename: FileNames.feedsWithDownloads,
    ).then((_) => _propertiesChangedController.add(true));
  }

  Map<String, List<Audio>> _podcasts = {};
  bool isPodcastSubscribed(String feedUrl) => _podcasts.containsKey(feedUrl);
  Map<String, List<Audio>> get podcasts => _podcasts;
  int get podcastsLength => _podcasts.length;

  void addPodcast(String feedUrl, List<Audio> audios) {
    if (isPodcastSubscribed(feedUrl)) return;
    _podcasts.putIfAbsent(feedUrl, () => audios);
    writeAudioMap(map: _podcasts, fileName: FileNames.podcasts)
        .then((_) => _propertiesChangedController.add(true));
  }

  void addPodcasts(List<(String feedUrl, List<Audio> audios)> podcasts) {
    if (podcasts.isEmpty) return;
    for (var podcast in podcasts) {
      if (!isPodcastSubscribed(podcast.$1)) {
        _podcasts.putIfAbsent(podcast.$1, () => podcast.$2);
      }
    }
    writeAudioMap(map: _podcasts, fileName: FileNames.podcasts)
        .then((_) => _propertiesChangedController.add(true));
  }

  Future<void> updatePodcast(String feedUrl, List<Audio> audios) async {
    if (feedUrl.isEmpty || audios.isEmpty) return;
    _addPodcastUpdate(feedUrl);
    _podcasts.update(feedUrl, (value) => audios);
    return writeAudioMap(map: _podcasts, fileName: FileNames.podcasts)
        .then((_) => _propertiesChangedController.add(true));
  }

  Future<void> updatePodcasts(
    List<({String feedUrl, List<Audio> audios})> podcasts,
  ) async {
    if (podcasts.isEmpty) return;
    for (var podcast in podcasts) {
      if (podcast.feedUrl.isEmpty || podcast.audios.isEmpty) continue;
      _addPodcastUpdate(podcast.feedUrl);
      _podcasts.update(podcast.feedUrl, (value) => podcast.audios);
    }
    return writeAudioMap(map: _podcasts, fileName: FileNames.podcasts)
        .then((_) => _propertiesChangedController.add(true));
  }

  void _addPodcastUpdate(String feedUrl) {
    if (_podcastUpdates?.contains(feedUrl) == true) return;
    _podcastUpdates?.add(feedUrl);
    writeStringIterable(
      iterable: _podcastUpdates!,
      filename: FileNames.podcastUpdates,
    ).then((_) => _propertiesChangedController.add(true));
  }

  bool showPodcastAscending(String feedUrl) =>
      _sharedPreferences.getBool(SPKeys.ascendingFeeds + feedUrl) ?? false;

  Future<void> _addAscendingPodcast(String feedUrl) async {
    await _sharedPreferences
        .setBool(SPKeys.ascendingFeeds + feedUrl, true)
        .then(
          (_) => _propertiesChangedController.add(true),
        );
  }

  Future<void> _removeAscendingPodcast(String feedUrl) async =>
      _sharedPreferences.remove(SPKeys.ascendingFeeds + feedUrl).then(
            (_) => _propertiesChangedController.add(true),
          );

  Future<void> reorderPodcast({
    required String feedUrl,
    required bool ascending,
  }) async {
    final podcast = _podcasts[feedUrl];
    if (podcast == null || podcast.isEmpty) return;
    sortListByAudioFilter(
      audioFilter: AudioFilter.year,
      audios: podcast,
      descending: !ascending,
    );
    if (ascending) {
      await _addAscendingPodcast(feedUrl);
    } else {
      await _removeAscendingPodcast(feedUrl);
    }
    await updatePodcast(feedUrl, podcast);
  }

  Set<String>? _podcastUpdates;
  int? get podcastUpdatesLength => _podcastUpdates?.length;

  bool podcastUpdateAvailable(String feedUrl) =>
      _podcastUpdates?.contains(feedUrl) == true;

  void removePodcastUpdate(String feedUrl) {
    if (_podcastUpdates?.isNotEmpty == false) return;
    _podcastUpdates?.remove(feedUrl);
    writeStringIterable(
      iterable: _podcastUpdates!,
      filename: FileNames.podcastUpdates,
    ).then((_) => _propertiesChangedController.add(true));
  }

  void removePodcast(String feedUrl) {
    if (!isPodcastSubscribed(feedUrl)) return;
    _podcasts.remove(feedUrl);
    writeAudioMap(map: _podcasts, fileName: FileNames.podcasts)
        .then((_) => _propertiesChangedController.add(true))
        .then((_) => removePodcastUpdate(feedUrl))
        .then((_) => _removeFeedWithDownload(feedUrl));
  }

  Future<void> removeAllPodcasts() async {
    _podcasts.clear();
    _podcastUpdates?.clear();
    writeAudioMap(
      map: _podcasts,
      fileName: FileNames.podcasts,
    ).then((_) => _propertiesChangedController.add(true));
  }

  //
  // Albums
  //

  Map<String, List<Audio>> _pinnedAlbums = {};
  Map<String, List<Audio>> get pinnedAlbums => _pinnedAlbums;
  int get pinnedAlbumsLength => _pinnedAlbums.length;

  List<Audio> getAlbumAt(int index) =>
      _pinnedAlbums.entries.elementAt(index).value.toList();

  bool isPinnedAlbum(String name) => _pinnedAlbums.containsKey(name);

  void addPinnedAlbum(String name, List<Audio> audios) {
    _pinnedAlbums.putIfAbsent(name, () => audios);
    writeAudioMap(map: _pinnedAlbums, fileName: FileNames.pinnedAlbums)
        .then((_) => _propertiesChangedController.add(true));
  }

  void removePinnedAlbum(String name) {
    _pinnedAlbums.remove(name);
    writeAudioMap(map: _pinnedAlbums, fileName: FileNames.pinnedAlbums)
        .then((_) => _propertiesChangedController.add(true));
  }

  bool? _libraryInitialized;
  Future<bool> init() async {
    // Ensure [init] is only called once
    if (_libraryInitialized == true) return _libraryInitialized!;

    _playlists = await readAudioMap(FileNames.playlists);
    _pinnedAlbums = await readAudioMap(FileNames.pinnedAlbums);
    _podcasts = await readAudioMap(FileNames.podcasts);
    _podcastUpdates = Set.from(
      await readStringIterable(filename: FileNames.podcastUpdates) ??
          <String>{},
    );
    _podcastUpdates ??= {};
    _starredStations = await readAudioMap(FileNames.starredStations);

    _likedAudios = (await readAudioMap(FileNames.likedAudios))
            .entries
            .firstOrNull
            ?.value ??
        <Audio>[];

    _downloads = await readStringMap(FileNames.downloads);
    _feedsWithDownloads = Set.from(
      await readStringIterable(filename: FileNames.feedsWithDownloads) ??
          <String>{},
    );

    return true;
  }

  String? get selectedPageId =>
      _sharedPreferences.getString(PageIDs.selectedPage);
  Future<void> setSelectedPageId(String value) async {
    final success =
        await _sharedPreferences.setString(PageIDs.selectedPage, value);
    if (success) {
      _propertiesChangedController.add(true);
    }
  }

  Future<void> dispose() async {
    await _propertiesChangedController.close();
  }

  bool isPageInLibrary(String? pageId) =>
      pageId != null &&
      (PageIDs.permanent.contains(pageId) ||
          isPinnedAlbum(pageId) ||
          isStarredStation(pageId) ||
          isPlaylistSaved(pageId) ||
          isPodcastSubscribed(pageId));
}
