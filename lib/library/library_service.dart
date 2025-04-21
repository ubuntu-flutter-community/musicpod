import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../common/data/audio.dart';
import '../common/file_names.dart';
import '../common/logging.dart';
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
  // Favorite Audios
  //

  List<String> get favoriteAudios =>
      _sharedPreferences.getStringList(SPKeys.favoriteAudios) ?? [];
  bool isFavoriteAudio(String? id) => favoriteAudios.contains(id);

  void addFavoriteAudios(List<String?> ids, {bool clear = false}) {
    if (ids.isEmpty) return;
    final List<String> favorites = List.from(clear ? [] : favoriteAudios);
    for (var id in ids) {
      if (id != null && id.isNotEmpty && !favorites.contains(id)) {
        favorites.add(id);
      }
    }

    try {
      _sharedPreferences
          .setStringList(SPKeys.favoriteAudios, favorites)
          .then(notify);
    } catch (e) {
      printMessageInDebugMode(e.toString());
    }
  }

  void removeFavoriteAudios(List<String?> ids) {
    if (ids.isEmpty) return;
    final List<String> favorites = List.from(favoriteAudios);
    for (var id in ids) {
      if (favorites.contains(id)) {
        favorites.remove(id);
      }
    }
    try {
      _sharedPreferences
          .setStringList(SPKeys.favoriteAudios, favorites)
          .then(notify);
    } catch (e) {
      printMessageInDebugMode(e.toString());
    }
  }

  //
  // Starred stations
  //

  List<String> get starredStations =>
      _sharedPreferences.getStringList(
        SPKeys.starredStations,
      ) ??
      [];
  int get starredStationsLength => starredStations.length;

  void addStarredStation(String uuid) {
    if (starredStations.contains(uuid)) return;
    final List<String> starred = List.from(starredStations);
    starred.add(uuid);
    _sharedPreferences
        .setStringList(SPKeys.starredStations, starred)
        .then(notify);
  }

  void addStarredStations(List<String?> uuids) {
    if (uuids.isEmpty) return;
    final List<String> starred = List.from(starredStations);
    for (var uuid in uuids) {
      if (uuid != null && uuid.isNotEmpty && !starred.contains(uuid)) {
        starred.add(uuid);
      }
    }
    _sharedPreferences
        .setStringList(SPKeys.starredStations, starred)
        .then(notify);
  }

  void removeStarredStation(String uuid) {
    if (!starredStations.contains(uuid)) return;
    final List<String> starred = List.from(starredStations);
    starred.remove(uuid);
    _sharedPreferences
        .setStringList(SPKeys.starredStations, starred)
        .then(notify);
  }

  void unStarAllStations() {
    if (starredStations.isEmpty) return;
    _sharedPreferences.setStringList(SPKeys.starredStations, []).then(notify);
  }

  bool isStarredStation(String? uuid) => starredStations.contains(uuid);

  Set<String> get favRadioTags =>
      _sharedPreferences.getStringList(SPKeys.favRadioTags)?.toSet() ?? {};
  bool isFavTag(String value) => favRadioTags.contains(value);

  void addFavRadioTag(String name) {
    if (favRadioTags.contains(name)) return;
    final Set<String> tags = favRadioTags;
    tags.add(name);
    _sharedPreferences
        .setStringList(SPKeys.favRadioTags, tags.toList())
        .then(notify);
  }

  void removeFavRadioTag(String name) {
    if (!favRadioTags.contains(name)) return;
    final Set<String> tags = favRadioTags;
    tags.remove(name);
    _sharedPreferences
        .setStringList(SPKeys.favRadioTags, tags.toList())
        .then(notify);
  }

  String? get lastCountryCode =>
      _sharedPreferences.getString(SPKeys.lastCountryCode);
  void setLastCountryCode(String value) {
    _sharedPreferences.setString(SPKeys.lastCountryCode, value).then(notify);
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
        .then(notify);
  }

  void removeFavCountryCode(String name) {
    if (!favCountryCodes.contains(name)) return;
    final favCodes = favCountryCodes;
    favCodes.remove(name);
    _sharedPreferences
        .setStringList(SPKeys.favCountryCodes, favCodes.toList())
        .then(notify);
  }

  String? get lastLanguageCode =>
      _sharedPreferences.getString(SPKeys.lastLanguageCode);
  void setLastLanguageCode(String value) {
    _sharedPreferences.setString(SPKeys.lastLanguageCode, value).then(notify);
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
        .then(notify);
  }

  void removeFavLanguageCode(String name) {
    if (!favLanguageCodes.contains(name)) return;
    final favLangs = favLanguageCodes;
    favLangs.remove(name);
    _sharedPreferences
        .setStringList(SPKeys.favLanguageCodes, favLangs.toList())
        .then(notify);
  }

  //
  // Playlists
  //

  List<String> get _playlistIDs =>
      _sharedPreferences.getStringList(SPKeys.playlistIDs) ?? [];
  List<String> getPlaylistById(String id) =>
      _sharedPreferences.getStringList(id) ?? [];
  List<String> get playlistIDs => _playlistIDs;

  bool isPlaylistSaved(String? id) =>
      id == null ? false : _playlistIDs.contains(id);

  Future<void> addPlaylist(String id, List<Audio> audios) async {
    if (!_playlistIDs.contains(id)) {
      final ids = List<String>.from(_playlistIDs);
      ids.add(id);
      await _sharedPreferences.setStringList(SPKeys.playlistIDs, ids);
      await _sharedPreferences.setStringList(
        id,
        audios
            .where((e) => e.audioId != null && e.audioId!.isNotEmpty)
            .map((e) => e.audioId!)
            .toList(),
      );
      _propertiesChangedController.add(true);
    }
  }

  Future<void> removePlaylist(String id) async {
    if (_playlistIDs.contains(id)) {
      final list = List<String>.from(_playlistIDs);
      list.remove(id);
      await _sharedPreferences.setStringList(SPKeys.playlistIDs, list);
      await _sharedPreferences.remove(id);
      _propertiesChangedController.add(true);
    }
  }

  Future<void> addPlaylists({
    required List<({String id, List<Audio> audios})> playlists,
    required bool external,
  }) async {
    if (playlists.isEmpty) return;
    for (var playlist in playlists) {
      if (!_playlistIDs.contains(playlist.id)) {
        await addPlaylist(playlist.id, playlist.audios);
        if (external) {
          final externalPlaylists =
              _sharedPreferences.getStringList(SPKeys.externalPlaylists);
          final newList = List<String>.from(externalPlaylists ?? []);
          newList.add(playlist.id);
          await _sharedPreferences.setStringList(
            SPKeys.externalPlaylists,
            newList,
          );
        }
      }
    }
  }

  Future<void> updatePlaylist(String id, List<Audio> audios) async {
    if (id.isEmpty || audios.isEmpty) return;
    if (_playlistIDs.contains(id)) {
      await _sharedPreferences.setStringList(
        id,
        audios
            .where((e) => e.audioId != null && e.audioId!.isNotEmpty)
            .map((e) => e.audioId!)
            .toList(),
      );
      _propertiesChangedController.add(true);
    }
  }

  void updatePlaylistName(String oldName, String newName) {
    if (newName == oldName) return;
    if (_playlistIDs.contains(oldName)) {
      final list =
          List<String>.from(_sharedPreferences.getStringList(oldName) ?? []);
      removePlaylist(oldName);
      addPlaylist(newName, list.map((e) => Audio.local(File(e))).toList());
    }
  }

  void moveAudioInPlaylist({
    required int oldIndex,
    required int newIndex,
    required String id,
  }) {
    final audios = id == PageIDs.likedAudios
        ? favoriteAudios.map((e) => Audio.local(File(e))).toList()
        : getPlaylistById(id).map((e) => Audio.local(File(e))).toList();

    if (audios.isEmpty == true || !(newIndex < audios.length)) {
      return;
    }

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final audio = audios.removeAt(oldIndex);
    audios.insert(newIndex, audio);

    if (id == PageIDs.likedAudios) {
      addFavoriteAudios(audios.map((e) => e.audioId).toList(), clear: true);
    } else {
      _sharedPreferences
          .setStringList(
            id,
            audios
                .where((e) => e.audioId != null && e.audioId!.isNotEmpty)
                .map((e) => e.audioId!)
                .toList(),
          )
          .then(notify);
    }
  }

  void addAudiosToPlaylist({required String id, required List<Audio> audios}) {
    final playlist = (_sharedPreferences.getStringList(id) ?? [])
        .map((e) => Audio.local(File(e)))
        .toList();

    for (var audio in audios) {
      if (!playlist.contains(audio)) {
        playlist.add(audio);
      }
    }

    _sharedPreferences
        .setStringList(
          id,
          playlist
              .where((e) => e.audioId != null && e.audioId!.isNotEmpty)
              .map((e) => e.audioId!)
              .toList(),
        )
        .then(notify);
  }

  Future<void> removeAudiosFromPlaylist({
    required String id,
    required List<Audio> audios,
  }) async {
    final playlist = (_sharedPreferences.getStringList(id) ?? [])
        .map((e) => Audio.local(File(e)))
        .toList();

    for (var audio in audios) {
      if (playlist.contains(audio)) {
        playlist.remove(audio);
      }
    }

    _sharedPreferences
        .setStringList(
          id,
          playlist
              .where((e) => e.audioId != null && e.audioId!.isNotEmpty)
              .map((e) => e.audioId!)
              .toList(),
        )
        .then(notify);
  }

  void clearPlaylist(String id) {
    if (!_playlistIDs.contains(id)) return;
    _sharedPreferences.setStringList(id, []).then(notify);
  }

  ///
  /// Podcasts
  ///
  ///

  // TODO: #1228 migrate podcasts to shared preferences

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

  bool showPodcastAscending(String feedUrl) =>
      _sharedPreferences.getBool(SPKeys.ascendingFeeds + feedUrl) ?? false;

  Future<void> _addAscendingPodcast(String feedUrl) async {
    await _sharedPreferences
        .setBool(SPKeys.ascendingFeeds + feedUrl, true)
        .then(notify);
  }

  Future<void> _removeAscendingPodcast(String feedUrl) async =>
      _sharedPreferences.remove(SPKeys.ascendingFeeds + feedUrl).then(notify);

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

  List<String> get _podcastUpdates =>
      _sharedPreferences.getStringList(SPKeys.podcastUpdates) ?? [];
  int get podcastUpdatesLength => _podcastUpdates.length;

  bool podcastUpdateAvailable(String feedUrl) =>
      _podcastUpdates.contains(feedUrl);

  void _addPodcastUpdate(String feedUrl) {
    if (podcastUpdateAvailable(feedUrl)) return;

    final updates = List<String>.from(_podcastUpdates);
    updates.add(feedUrl);
    _sharedPreferences
        .setStringList(SPKeys.podcastUpdates, updates)
        .then(notify);
  }

  void removePodcastUpdate(String feedUrl) {
    if (!podcastUpdateAvailable(feedUrl)) return;
    final updates = List<String>.from(_podcastUpdates);
    updates.remove(feedUrl);
    _sharedPreferences
        .setStringList(SPKeys.podcastUpdates, updates)
        .then(notify);
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
    _podcastUpdates.clear();
    _sharedPreferences.remove(SPKeys.podcastUpdates);
    writeAudioMap(
      map: _podcasts,
      fileName: FileNames.podcasts,
    ).then((_) => _propertiesChangedController.add(true));
  }

  //
  // Albums
  //

  List<String> get favoriteAlbums =>
      _sharedPreferences.getStringList(SPKeys.favoriteAlbums) ?? [];

  bool isFavoriteAlbum(String id) => favoriteAlbums.contains(id);

  void addFavoriteAlbum(String id, {required Function() onFail}) {
    if (id.isEmpty) {
      onFail();
      return;
    }
    if (favoriteAlbums.contains(id)) return;
    final List<String> favorites = List.from(favoriteAlbums);
    favorites.add(id);
    _sharedPreferences
        .setStringList(SPKeys.favoriteAlbums, favorites)
        .then(notify);
  }

  void removeFavoriteAlbum(String id, {required Function() onFail}) {
    if (id.isEmpty) {
      onFail();
      return;
    }
    if (!favoriteAlbums.contains(id)) return;
    final List<String> favorites = List.from(favoriteAlbums);
    favorites.remove(id);
    _sharedPreferences
        .setStringList(SPKeys.favoriteAlbums, favorites)
        .then(notify);
  }

  bool notify(bool saved) {
    if (saved) _propertiesChangedController.add(true);
    return saved;
  }

  Future<void> init() async {
    _podcasts = await readAudioMap(FileNames.podcasts);
    _downloads = await readStringMap(FileNames.downloads);
    _feedsWithDownloads = Set.from(
      await readStringIterable(filename: FileNames.feedsWithDownloads) ??
          <String>{},
    );
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
          favoriteAlbums.contains(pageId) ||
          isStarredStation(pageId) ||
          isPlaylistSaved(pageId) ||
          isPodcastSubscribed(pageId));
}
