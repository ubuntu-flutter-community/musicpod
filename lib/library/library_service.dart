import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/data/audio.dart';
import '../common/view/audio_filter.dart';
import '../constants.dart';
import '../persistence_utils.dart';

class LibraryService {
  LibraryService({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;

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
      writeAudioMap({kLikedAudiosPageId: _likedAudios}, kLikedAudiosFileName)
          .then((value) => _propertiesChangedController.add(true));
    }
  }

  void addLikedAudios(List<Audio> audios) {
    for (var audio in audios) {
      addLikedAudio(audio, false);
    }
    writeAudioMap({kLikedAudiosPageId: _likedAudios}, kLikedAudiosFileName)
        .then((value) => _propertiesChangedController.add(true));
  }

  bool liked(Audio audio) {
    return likedAudios.contains(audio);
  }

  void removeLikedAudio(Audio audio, [bool notify = true]) {
    _likedAudios.remove(audio);
    if (notify) {
      writeAudioMap({kLikedAudiosPageId: _likedAudios}, kLikedAudiosFileName)
          .then((value) => _propertiesChangedController.add(true));
    }
  }

  void removeLikedAudios(List<Audio> audios) {
    for (var audio in audios) {
      removeLikedAudio(audio, false);
    }
    writeAudioMap({kLikedAudiosPageId: _likedAudios}, kLikedAudiosFileName)
        .then((value) => _propertiesChangedController.add(true));
  }

  //
  // Starred stations
  //

  Map<String, List<Audio>> _starredStations = {};
  Map<String, List<Audio>> get starredStations => _starredStations;
  int get starredStationsLength => _starredStations.length;

  void addStarredStation(String uuid, List<Audio> audios) {
    _starredStations.putIfAbsent(uuid, () => audios);
    writeAudioMap(_starredStations, kStarredStationsFileName)
        .then((_) => _propertiesChangedController.add(true));
  }

  void unStarStation(String uuid) {
    _starredStations.remove(uuid);
    writeAudioMap(_starredStations, kStarredStationsFileName)
        .then((_) => _propertiesChangedController.add(true));
  }

  bool isStarredStation(String? uuid) {
    return uuid == null ? false : _starredStations.containsKey(uuid);
  }

  Set<String> get favRadioTags =>
      _sharedPreferences.getStringList(kFavRadioTags)?.toSet() ?? {};
  bool isFavTag(String value) => favRadioTags.contains(value);

  void addFavRadioTag(String name) {
    if (favRadioTags.contains(name)) return;
    final Set<String> tags = favRadioTags;
    tags.add(name);
    _sharedPreferences.setStringList(kFavRadioTags, tags.toList()).then(
      (saved) {
        if (saved) _propertiesChangedController.add(true);
      },
    );
  }

  void removeFavRadioTag(String name) {
    if (!favRadioTags.contains(name)) return;
    final Set<String> tags = favRadioTags;
    tags.remove(name);
    _sharedPreferences.setStringList(kFavRadioTags, tags.toList()).then(
      (saved) {
        if (saved) _propertiesChangedController.add(true);
      },
    );
  }

  String? get lastCountryCode => _sharedPreferences.getString(kLastCountryCode);
  void setLastCountryCode(String value) {
    _sharedPreferences.setString(kLastCountryCode, value).then(
      (saved) {
        if (saved) _propertiesChangedController.add(true);
      },
    );
  }

  Set<String> get favCountryCodes =>
      _sharedPreferences.getStringList(kFavCountryCodes)?.toSet() ?? {};
  bool isFavCountry(String value) => favCountryCodes.contains(value);

  void addFavCountryCode(String name) {
    if (favCountryCodes.contains(name)) return;
    final favCodes = favCountryCodes;
    favCodes.add(name);
    _sharedPreferences
        .setStringList(kFavCountryCodes, favCodes.toList())
        .then((saved) {
      if (saved) _propertiesChangedController.add(true);
    });
  }

  void removeFavCountryCode(String name) {
    if (!favCountryCodes.contains(name)) return;
    final favCodes = favCountryCodes;
    favCodes.remove(name);
    _sharedPreferences
        .setStringList(kFavCountryCodes, favCodes.toList())
        .then((saved) {
      if (saved) _propertiesChangedController.add(true);
    });
  }

  String? get lastLanguageCode =>
      _sharedPreferences.getString(kLastLanguageCode);
  void setLastLanguageCode(String value) {
    _sharedPreferences.setString(kLastLanguageCode, value).then((saved) {
      if (saved) _propertiesChangedController.add(true);
    });
  }

  Set<String> get favLanguageCodes =>
      _sharedPreferences.getStringList(kFavLanguageCodes)?.toSet() ?? {};
  bool isFavLanguage(String value) => favLanguageCodes.contains(value);

  void addFavLanguageCode(String name) {
    if (favLanguageCodes.contains(name)) return;
    final favLangs = favLanguageCodes;
    favLangs.add(name);
    _sharedPreferences.setStringList(kFavLanguageCodes, favLangs.toList()).then(
      (saved) {
        if (saved) _propertiesChangedController.add(true);
      },
    );
  }

  void removeFavLanguageCode(String name) {
    if (!favLanguageCodes.contains(name)) return;
    final favLangs = favLanguageCodes;
    favLangs.remove(name);
    _sharedPreferences.setStringList(kFavLanguageCodes, favLangs.toList()).then(
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
      await writeAudioMap(_playlists, kPlaylistsFileName)
          .then((_) => _propertiesChangedController.add(true));
    }
  }

  Future<void> updatePlaylist(String id, List<Audio> audios) async {
    if (_playlists.containsKey(id)) {
      await writeAudioMap(_playlists, kPlaylistsFileName).then((_) {
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
      _playlists.remove(id);
      writeAudioMap(_playlists, kPlaylistsFileName)
          .then((_) => _propertiesChangedController.add(true));
    }
  }

  void updatePlaylistName(String oldName, String newName) {
    if (newName == oldName) return;
    final oldList = _playlists[oldName];
    if (oldList != null) {
      _playlists.remove(oldName);
      _playlists.putIfAbsent(newName, () => oldList);
      writeAudioMap(_playlists, kPlaylistsFileName)
          .then((_) => _propertiesChangedController.add(true));
    }
  }

  void moveAudioInPlaylist({
    required int oldIndex,
    required int newIndex,
    required String id,
  }) {
    final audios = id == kLikedAudiosPageId
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

    if (id == kLikedAudiosPageId) {
      writeAudioMap({kLikedAudiosPageId: _likedAudios}, kLikedAudiosFileName)
          .then((value) {
        likedAudios.clear();
        likedAudios.addAll(audios);
        _propertiesChangedController.add(true);
      });
    } else {
      writeAudioMap(_playlists, kPlaylistsFileName).then((_) {
        _playlists.update(id, (value) => audios);
        _propertiesChangedController.add(true);
      });
    }
  }

  void addAudioToPlaylist(String id, Audio audio) {
    final playlist = _playlists[id];
    if (playlist == null || playlist.contains(audio)) return;
    playlist.add(audio);
    writeAudioMap(_playlists, kPlaylistsFileName)
        .then((_) => _propertiesChangedController.add(true));
  }

  void removeAudioFromPlaylist(String id, Audio audio) {
    final playlist = _playlists[id];
    if (playlist != null && playlist.contains(audio)) {
      playlist.remove(audio);
      writeAudioMap(_playlists, kPlaylistsFileName)
          .then((_) => _propertiesChangedController.add(true));
    }
  }

  void clearPlaylist(String id) {
    final playlist = _playlists[id];
    if (playlist != null) {
      playlist.clear();
      writeAudioMap(_playlists, kPlaylistsFileName)
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
    writeStringMap(_downloads, kDownloads)
        .then(
          (_) => writeStringIterable(
            iterable: _feedsWithDownloads,
            filename: kFeedsWithDownloads,
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
    writeStringMap(_downloads, kDownloads)
        .then(
          (_) => writeStringIterable(
            iterable: _feedsWithDownloads,
            filename: kFeedsWithDownloads,
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
      filename: kFeedsWithDownloads,
    ).then((_) => _propertiesChangedController.add(true));
  }

  Map<String, List<Audio>> _podcasts = {};
  bool isPodcastSubscribed(String feedUrl) => _podcasts.containsKey(feedUrl);
  Map<String, List<Audio>> get podcasts => _podcasts;
  int get podcastsLength => _podcasts.length;

  void addPodcast(String feedUrl, List<Audio> audios) {
    if (isPodcastSubscribed(feedUrl)) return;
    _podcasts.putIfAbsent(feedUrl, () => audios);
    writeAudioMap(_podcasts, kPodcastsFileName)
        .then((_) => _propertiesChangedController.add(true));
  }

  Future<void> updatePodcast(String feedUrl, List<Audio> audios) async {
    if (feedUrl.isEmpty || audios.isEmpty) return;
    _addPodcastUpdate(feedUrl);
    _podcasts.update(feedUrl, (value) => audios);
    return writeAudioMap(_podcasts, kPodcastsFileName)
        .then((_) => _propertiesChangedController.add(true));
  }

  void _addPodcastUpdate(String feedUrl) {
    if (_podcastUpdates?.contains(feedUrl) == true) return;
    _podcastUpdates?.add(feedUrl);
    writeStringIterable(iterable: _podcastUpdates!, filename: kPodcastsUpdates)
        .then((_) => _propertiesChangedController.add(true));
  }

  bool showPodcastAscending(String feedUrl) =>
      _sharedPreferences.getBool(kAscendingFeeds + feedUrl) ?? false;

  Future<void> _addAscendingPodcast(String feedUrl) async {
    await _sharedPreferences.setBool(kAscendingFeeds + feedUrl, true).then(
          (_) => _propertiesChangedController.add(true),
        );
  }

  Future<void> _removeAscendingPodcast(String feedUrl) async =>
      _sharedPreferences.remove(kAscendingFeeds + feedUrl).then(
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
    writeStringIterable(iterable: _podcastUpdates!, filename: kPodcastsUpdates)
        .then((_) => _propertiesChangedController.add(true));
  }

  void removePodcast(String feedUrl) {
    if (!isPodcastSubscribed(feedUrl)) return;
    _podcasts.remove(feedUrl);
    writeAudioMap(_podcasts, kPodcastsFileName)
        .then((_) => _propertiesChangedController.add(true))
        .then((_) => removePodcastUpdate(feedUrl))
        .then((_) => _removeFeedWithDownload(feedUrl));
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
    writeAudioMap(_pinnedAlbums, kPinnedAlbumsFileName)
        .then((_) => _propertiesChangedController.add(true));
  }

  void removePinnedAlbum(String name) {
    _pinnedAlbums.remove(name);
    writeAudioMap(_pinnedAlbums, kPinnedAlbumsFileName)
        .then((_) => _propertiesChangedController.add(true));
  }

  bool? _libraryInitialized;
  Future<bool> init() async {
    // Ensure [init] is only called once
    if (_libraryInitialized == true) return _libraryInitialized!;

    _playlists = await readAudioMap(kPlaylistsFileName);
    _pinnedAlbums = await readAudioMap(kPinnedAlbumsFileName);
    _podcasts = await readAudioMap(kPodcastsFileName);
    _podcastUpdates = Set.from(
      await readStringIterable(filename: kPodcastsUpdates) ?? <String>{},
    );
    _podcastUpdates ??= {};
    _starredStations = await readAudioMap(kStarredStationsFileName);

    _likedAudios =
        (await readAudioMap(kLikedAudiosFileName)).entries.firstOrNull?.value ??
            <Audio>[];

    _downloads = await readStringMap(kDownloads);
    _feedsWithDownloads = Set.from(
      await readStringIterable(filename: kFeedsWithDownloads) ?? <String>{},
    );

    return true;
  }

  String? get selectedPageId => _sharedPreferences.getString(kSelectedPageId);
  Future<void> setSelectedPageId(String value) async {
    final success = await _sharedPreferences.setString(kSelectedPageId, value);
    if (success) {
      _propertiesChangedController.add(true);
    }
  }

  Future<void> dispose() async {
    await _propertiesChangedController.close();
  }

  bool isPageInLibrary(String? pageId) =>
      pageId != null &&
      (_mainPages.contains(pageId) ||
          isPinnedAlbum(pageId) ||
          isStarredStation(pageId) ||
          isPlaylistSaved(pageId) ||
          isPodcastSubscribed(pageId));

  final _mainPages = [
    kSearchPageId,
    kLikedAudiosPageId,
    kLocalAudioPageId,
    kPodcastsPageId,
    kRadioPageId,
  ];
}
