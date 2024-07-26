import 'dart:async';

import 'package:flutter/material.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/view/global_keys.dart';
import '../constants.dart';
import 'library_service.dart';

class LibraryModel extends SafeChangeNotifier {
  LibraryModel(this._service);

  final LibraryService _service;
  StreamSubscription<bool>? _likedAudiosSub;
  StreamSubscription<bool>? _playlistsSub;
  StreamSubscription<bool>? _albumsSub;
  StreamSubscription<bool>? _podcastsSub;
  StreamSubscription<bool>? _stationsSub;
  StreamSubscription<bool>? _updatesChangedSub;
  StreamSubscription<bool>? _favTagsSub;
  StreamSubscription<bool>? _favCountriesSub;
  StreamSubscription<bool>? _favLanguageCodeFavsSub;
  StreamSubscription<bool>? _lastCountryCodeSub;
  StreamSubscription<bool>? _downloadsSub;

  Future<bool> init() async {
    await _service.init();
    if (_service.selectedPageId != null) {
      _pageIdStack.add(_service.selectedPageId!);
    }

    _likedAudiosSub ??=
        _service.likedAudiosChanged.listen((event) => notifyListeners());
    _playlistsSub ??=
        _service.playlistsChanged.listen((event) => notifyListeners());
    _albumsSub = _service.albumsChanged.listen((event) => notifyListeners());
    _podcastsSub ??=
        _service.podcastsChanged.listen((event) => notifyListeners());
    _stationsSub ??=
        _service.starredStationsChanged.listen((event) => notifyListeners());
    _updatesChangedSub ??=
        _service.updatesChanged.listen((_) => notifyListeners());
    _favTagsSub ??= _service.favTagsChanged.listen((_) => notifyListeners());
    _favCountriesSub ??=
        _service.favCountriesChanged.listen((_) => notifyListeners());
    _favLanguageCodeFavsSub ??=
        _service.favLanguagesChanged.listen((_) => notifyListeners());

    _downloadsSub ??=
        _service.downloadsChanged.listen((_) => notifyListeners());
    _lastCountryCodeSub ??=
        _service.lastCountryCodeChanged.listen((_) => notifyListeners());

    notifyListeners();
    return true;
  }

  @override
  Future<void> dispose() async {
    await _likedAudiosSub?.cancel();
    await _playlistsSub?.cancel();
    await _albumsSub?.cancel();
    await _podcastsSub?.cancel();
    await _stationsSub?.cancel();
    await _updatesChangedSub?.cancel();
    await _favTagsSub?.cancel();
    await _favCountriesSub?.cancel();
    await _favLanguageCodeFavsSub?.cancel();
    await _downloadsSub?.cancel();
    await _lastCountryCodeSub?.cancel();
    super.dispose();
  }

  Set<Audio>? getAudiosById(String pageId) {
    if (pageId == kLikedAudiosPageId) {
      return likedAudios;
    } else {
      return playlists[pageId] ??
          pinnedAlbums[pageId] ??
          podcasts[pageId] ??
          starredStations[pageId];
    }
  }

  //
  // Liked Audios
  //
  Set<Audio> get likedAudios => _service.likedAudios;

  void addLikedAudio(Audio audio, [bool notify = true]) =>
      _service.addLikedAudio(audio, notify);

  void addLikedAudios(Set<Audio> audios) => _service.addLikedAudios(audios);

  void removeLikedAudios(Set<Audio> audios) =>
      _service.removeLikedAudios(audios);

  bool liked(Audio? audio) => audio == null ? false : _service.liked(audio);

  void removeLikedAudio(Audio audio, [bool notify = true]) =>
      _service.removeLikedAudio(audio, notify);

  //
  // Starred stations
  //

  Map<String, Set<Audio>> get starredStations => _service.starredStations;
  int get starredStationsLength => _service.starredStations.length;
  void addStarredStation(String url, Set<Audio> audios) =>
      _service.addStarredStation(url, audios);

  void unStarStation(String url, [bool popIt = true]) {
    _service.unStarStation(url);
    if (popIt) {
      pop();
    }
  }

  bool isStarredStation(String? url) =>
      url?.isNotEmpty == false ? false : _service.isStarredStation(url);

  void addFavRadioTag(String value) => _service.addFavRadioTag(value);
  void removeRadioFavTag(String value) => _service.removeFavRadioTag(value);
  Set<String> get favRadioTags => _service.favRadioTags;
  int get favRadioTagsLength => _service.favRadioTags.length;

  String? get lastCountryCode => _service.lastCountryCode;
  void setLastCountryCode(String? value) => _service.setLastCountryCode(value);
  void addFavCountryCode(String value) => _service.addFavCountryCode(value);
  void removeFavCountryCode(String value) =>
      _service.removeFavCountryCode(value);
  Set<String> get favCountryCodes => _service.favCountryCodes;
  int get favCountriesLength => _service.favCountryCodes.length;

  String? get lastLanguageCode => _service.lastLanguageCode;
  void setLastLanguage(String? value) => _service.setLastLanguageCode(value);
  void addFavLanguageCode(String value) => _service.addFavLanguageCode(value);
  void removeFavLanguageCode(String value) =>
      _service.removeFavLanguageCode(value);
  Set<String> get favLanguageCodes => _service.favLanguageCodes;
  int get favLanguagesLength => _service.favLanguageCodes.length;

  //
  // Playlists
  //

  Map<String, Set<Audio>> get playlists => _service.playlists;
  int get playlistsLength => playlists.length;
  List<Audio> getPlaylistAt(int index) =>
      playlists.entries.elementAt(index).value.toList();
  Set<Audio>? getPlaylistById(String id) => _service.playlists[id];

  bool isPlaylistSaved(String? name) => playlists.containsKey(name);

  Future<void> addPlaylist(String name, Set<Audio> audios) async =>
      _service.addPlaylist(name, audios);

  Future<void> updatePlaylist(String id, Set<Audio> audios) async =>
      _service.updatePlaylist(id, audios);

  void removePlaylist(String id) {
    _service.removePlaylist(id);
    pop();
  }

  void updatePlaylistName(String oldName, String newName) =>
      _service.updatePlaylistName(oldName, newName);

  void addAudioToPlaylist(String playlist, Audio audio) =>
      _service.addAudioToPlaylist(playlist, audio);

  void removeAudioFromPlaylist(String playlist, Audio audio) =>
      _service.removeAudioFromPlaylist(playlist, audio);

  void clearPlaylist(String id) => _service.clearPlaylist(id);

  List<String> getPlaylistNames() =>
      playlists.entries.map((e) => e.key).toList();

  void moveAudioInPlaylist({
    required int oldIndex,
    required int newIndex,
    required String id,
  }) =>
      _service.moveAudioInPlaylist(
        oldIndex: oldIndex,
        newIndex: newIndex,
        id: id,
      );

  // Podcasts

  Map<String, Set<Audio>> get podcasts => _service.podcasts;
  int get podcastsLength => podcasts.length;
  void addPodcast(String feedUrl, Set<Audio> audios) =>
      _service.addPodcast(feedUrl, audios);
  void updatePodcast(String feedUrl, Set<Audio> audios) =>
      _service.updatePodcast(feedUrl, audios);

  void removePodcast(String feedUrl) {
    _service.removePodcast(feedUrl);
    pop();
  }

  bool isPodcastSubscribed(String? feedUrl) =>
      feedUrl == null ? false : podcasts.containsKey(feedUrl);

  bool podcastUpdateAvailable(String feedUrl) =>
      _service.podcastUpdateAvailable(feedUrl);

  int? get podcastUpdatesLength => _service.podcastUpdatesLength;

  void removePodcastUpdate(String feedUrl) =>
      _service.removePodcastUpdate(feedUrl);

  int get downloadsLength => _service.downloads.length;

  String? getDownload(String? url) =>
      url == null ? null : _service.downloads[url];

  bool feedHasDownload(String? feedUrl) =>
      feedUrl == null ? false : _service.feedHasDownloads(feedUrl);

  int get feedsWithDownloadsLength => _service.feedsWithDownloadsLength;

  //
  // Albums
  //

  Map<String, Set<Audio>> get pinnedAlbums => _service.pinnedAlbums;
  int get pinnedAlbumsLength => pinnedAlbums.length;
  List<Audio> getAlbumAt(int index) =>
      pinnedAlbums.entries.elementAt(index).value.toList();
  bool isPinnedAlbum(String name) => pinnedAlbums.containsKey(name);

  void addPinnedAlbum(String name, Set<Audio> audios) =>
      _service.addPinnedAlbum(name, audios);

  void removePinnedAlbum(String name) {
    _service.removePinnedAlbum(name);
    pop();
  }

  final List<String> _pageIdStack = [];
  String? get selectedPageId => _pageIdStack.lastOrNull;
  Future<void> pushNamed(String pageId) async {
    if (pageId == _pageIdStack.lastOrNull) return;
    _putOnStack(pageId);
    await masterNavigator.currentState?.pushNamed(pageId);
  }

  void _putOnStack(String pageId) {
    _pageIdStack.add(pageId);
    if (isPageInLibrary(pageId)) {
      _service.selectedPageId = pageId;
    }
    notifyListeners();
  }

  bool get canPop => _pageIdStack.length > 1;

  Future<void> push({
    required Widget Function(BuildContext) builder,
    required String pageId,
    bool maintainState = false,
  }) async {
    final forceUnnamed = _isForceUnnamed(pageId);

    if (!forceUnnamed && isPageInLibrary(pageId)) {
      await pushNamed(pageId);
    } else {
      _putOnStack(pageId);
      await masterNavigator.currentState?.push(
        MaterialPageRoute(
          builder: builder,
          maintainState: maintainState,
          settings: RouteSettings(
            name: pageId,
          ),
        ),
      );
    }
  }

  bool _isForceUnnamed(String pageId) {
    return [kLocalAudioPageId, kRadioPageId]
        .any((e) => selectedPageId == e && pageId == e);
  }

  void pop({bool popStack = true}) {
    if (_pageIdStack.length > 1 && popStack) {
      _pageIdStack.removeLast();

      notifyListeners();
    }
    masterNavigator.currentState?.maybePop();
  }

  bool isPageInLibrary(String? pageId) =>
      pageId != null &&
      (pageId == kLikedAudiosPageId ||
          pageId == kLocalAudioPageId ||
          pageId == kPodcastsPageId ||
          pageId == kRadioPageId ||
          isPinnedAlbum(pageId) ||
          isStarredStation(pageId) ||
          isPlaylistSaved(pageId) ||
          isPodcastSubscribed(pageId));
}
