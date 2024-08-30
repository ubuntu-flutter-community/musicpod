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
  StreamSubscription<bool>? _propertiesChangedSub;

  Future<bool> init() async {
    await _service.init();
    _pageIdStack.add(_service.selectedPageId ?? kSearchPageId);

    _propertiesChangedSub ??=
        _service.propertiesChanged.listen((_) => notifyListeners());

    notifyListeners();
    return true;
  }

  @override
  Future<void> dispose() async {
    await _propertiesChangedSub?.cancel();
    super.dispose();
  }

  List<Audio>? getAudiosById(String pageId) {
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
  List<Audio> get likedAudios => _service.likedAudios;

  void addLikedAudio(Audio audio, [bool notify = true]) =>
      _service.addLikedAudio(audio, notify);

  void addLikedAudios(List<Audio> audios) => _service.addLikedAudios(audios);

  void removeLikedAudios(List<Audio> audios) =>
      _service.removeLikedAudios(audios);

  bool liked(Audio? audio) => audio == null ? false : _service.liked(audio);

  void removeLikedAudio(Audio audio, [bool notify = true]) =>
      _service.removeLikedAudio(audio, notify);

  //
  // Starred stations
  //

  Map<String, List<Audio>> get starredStations => _service.starredStations;
  int get starredStationsLength => _service.starredStations.length;
  void addStarredStation(String url, List<Audio> audios) =>
      _service.addStarredStation(url, audios);

  void unStarStation(String url) {
    _service.unStarStation(url);
    if (selectedPageId == url) {
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
  void setLastCountryCode(String value) => _service.setLastCountryCode(value);
  void addFavCountryCode(String value) => _service.addFavCountryCode(value);
  void removeFavCountryCode(String value) =>
      _service.removeFavCountryCode(value);
  Set<String> get favCountryCodes => _service.favCountryCodes;
  int get favCountriesLength => _service.favCountryCodes.length;

  String? get lastLanguageCode => _service.lastLanguageCode;
  void setLastLanguage(String value) => _service.setLastLanguageCode(value);
  void addFavLanguageCode(String value) => _service.addFavLanguageCode(value);
  void removeFavLanguageCode(String value) =>
      _service.removeFavLanguageCode(value);
  Set<String> get favLanguageCodes => _service.favLanguageCodes;
  int get favLanguagesLength => _service.favLanguageCodes.length;

  //
  // Playlists
  //

  Map<String, List<Audio>> get playlists => _service.playlists;
  int get playlistsLength => playlists.length;
  List<Audio> getPlaylistAt(int index) =>
      playlists.entries.elementAt(index).value.toList();
  List<Audio>? getPlaylistById(String id) => _service.playlists[id];

  bool isPlaylistSaved(String? name) => playlists.containsKey(name);

  Future<void> addPlaylist(String name, List<Audio> audios) async =>
      _service.addPlaylist(name, audios);

  Future<void> updatePlaylist(String id, List<Audio> audios) async =>
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

  Map<String, List<Audio>> get podcasts => _service.podcasts;
  int get podcastsLength => podcasts.length;
  void addPodcast(String feedUrl, List<Audio> audios) =>
      _service.addPodcast(feedUrl, audios);
  void updatePodcast(String feedUrl, List<Audio> audios) =>
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

  String? get downloadsDir => _service.downloadsDir;

  int get downloadsLength => _service.downloads.length;

  String? getDownload(String? url) =>
      url == null ? null : _service.downloads[url];

  bool feedHasDownload(String? feedUrl) =>
      feedUrl == null ? false : _service.feedHasDownloads(feedUrl);

  int get feedsWithDownloadsLength => _service.feedsWithDownloadsLength;

  Future<void> reorderPodcast({
    required String feedUrl,
    required bool ascending,
  }) =>
      _service.reorderPodcast(feedUrl: feedUrl, ascending: ascending);

  bool showPodcastAscending(String feedUrl) =>
      _service.showPodcastAscending(feedUrl);

  //
  // Albums
  //

  Map<String, List<Audio>> get pinnedAlbums => _service.pinnedAlbums;
  int get pinnedAlbumsLength => pinnedAlbums.length;
  List<Audio> getAlbumAt(int index) =>
      pinnedAlbums.entries.elementAt(index).value.toList();
  bool isPinnedAlbum(String name) => pinnedAlbums.containsKey(name);

  void addPinnedAlbum(String name, List<Audio> audios) =>
      _service.addPinnedAlbum(name, audios);

  void removePinnedAlbum(String name) {
    _service.removePinnedAlbum(name);
    pop();
  }

  final List<String> _pageIdStack = [];
  String? get selectedPageId => _pageIdStack.lastOrNull;
  Future<void> pushNamed({required String pageId, bool replace = false}) async {
    if (pageId == _pageIdStack.lastOrNull) return;
    _putOnStack(pageId: pageId, replace: replace);
    if (replace) {
      await masterNavigator.currentState?.pushReplacementNamed(pageId);
    } else {
      await masterNavigator.currentState?.pushNamed(pageId);
    }
  }

  void _putOnStack({
    required String pageId,
    bool replace = false,
  }) {
    if (replace) {
      _pageIdStack.last = pageId;
    } else {
      _pageIdStack.add(pageId);
    }

    if (isPageInLibrary(pageId)) {
      _service.setSelectedPageId(pageId);
    }
    notifyListeners();
  }

  bool get canPop => _pageIdStack.length > 1;

  Future<void> push({
    required Widget Function(BuildContext) builder,
    required String pageId,
    bool maintainState = false,
    bool replace = false,
  }) async {
    if (isPageInLibrary(pageId)) {
      await pushNamed(pageId: pageId, replace: replace);
    } else {
      _putOnStack(pageId: pageId, replace: replace);
      final materialPageRoute = MaterialPageRoute(
        builder: builder,
        maintainState: maintainState,
        settings: RouteSettings(
          name: pageId,
        ),
      );
      if (replace) {
        await masterNavigator.currentState?.pushReplacement(
          materialPageRoute,
        );
      } else {
        await masterNavigator.currentState?.push(
          materialPageRoute,
        );
      }
    }
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
      (pageId == kSearchPageId ||
          pageId == kLikedAudiosPageId ||
          pageId == kLocalAudioPageId ||
          pageId == kPodcastsPageId ||
          pageId == kRadioPageId ||
          isPinnedAlbum(pageId) ||
          isStarredStation(pageId) ||
          isPlaylistSaved(pageId) ||
          isPodcastSubscribed(pageId));
}
