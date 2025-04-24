import 'dart:async';

import 'package:flutter/material.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../app/view/mobile_page.dart';
import '../app_config.dart';
import '../common/data/audio.dart';
import '../common/logging.dart';
import '../common/view/back_gesture.dart';
import '../local_audio/local_audio_service.dart';
import 'library_service.dart';

class LibraryModel extends SafeChangeNotifier implements NavigatorObserver {
  LibraryModel({
    required LibraryService service,
    required LocalAudioService localAudioService,
  })  : _service = service,
        _localAudioService = localAudioService {
    _propertiesChangedSub ??=
        _service.propertiesChanged.listen((_) => notifyListeners());
  }

  final LibraryService _service;
  final LocalAudioService _localAudioService;
  StreamSubscription<bool>? _propertiesChangedSub;

  @override
  Future<void> dispose() async {
    await _propertiesChangedSub?.cancel();
    super.dispose();
  }

  bool isPageInLibrary(String? pageId) => _service.isPageInLibrary(pageId);

  //
  // Liked Audios
  //
  int get likedAudiosLength => _service.likedAudiosLength;
  List<Audio> get likedAudios => _service.likedAudios;
  void addLikedAudio(Audio audio) => _service.addLikedAudio(audio);
  void addLikedAudios(List<Audio> audios) => _service.addLikedAudios(audios);
  void removeLikedAudios(List<Audio> audios) =>
      _service.removeLikedAudios(audios);
  bool isLikedAudio(Audio? audio) =>
      audio == null ? false : _service.isLiked(audio);
  bool isLikedAudios(List<Audio> audios) => _service.isLikedAudios(audios);
  void removeLikedAudio(Audio audio, [bool notify = true]) =>
      _service.removeLikedAudio(audio, notify);

  //
  // Starred stations
  //

  List<String> get starredStations => _service.starredStations;
  int get starredStationsLength => _service.starredStations.length;
  void addStarredStation(String uuid) => _service.addStarredStation(uuid);
  void unStarStation(String uuid) => _service.removeStarredStation(uuid);
  void unStarAllStations() => _service.unStarAllStations();

  bool isStarredStation(String? uuid) =>
      uuid?.isNotEmpty == false ? false : _service.isStarredStation(uuid);

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

  List<String> get playlistIDs => _service.playlistIDs;
  int get playlistsLength => playlistIDs.length;
  List<Audio>? getPlaylistById(String id) => _service.getPlaylistById(id);
  List<String> get externalPlaylists => _service.externalPlaylistIDs;

  bool isPlaylistSaved(String? id) => _service.isPlaylistSaved(id);
  Future<void> addPlaylist(String name, List<Audio> audios) async =>
      _service.addPlaylist(name, audios);
  Future<void> addPlaylists(
    List<({String id, List<Audio> audios})> playlists, {
    required bool external,
  }) async {
    if (external) {
      _addLocalAudiosFromPlaylists(playlists);
    }
    return _service.addPlaylists(playlists: playlists, external: external);
  }

  void _addLocalAudiosFromPlaylists(
    List<({List<Audio> audios, String id})> playlists,
  ) {
    for (var playlist in playlists) {
      _localAudioService.addAudios(playlist.audios);
    }
  }

  Future<void> updatePlaylist({
    required String id,
    required List<Audio> audios,
    bool external = false,
  }) async =>
      _service.updatePlaylist(id: id, audios: audios, external: external);
  Future<void> removePlaylist(String id) => _service.removePlaylist(id);

  void updatePlaylistName(String oldName, String newName) =>
      _service.updatePlaylistName(oldName, newName);
  void addAudiosToPlaylist({
    required String id,
    required List<Audio> audios,
  }) =>
      _service.addAudiosToPlaylist(id: id, audios: audios);
  Future<void> removeAudiosFromPlaylist({
    required String id,
    required List<Audio> audios,
  }) async =>
      _service.removeAudiosFromPlaylist(id: id, audios: audios);

  void clearPlaylist(String id) => _service.clearPlaylist(id);
  void moveAudioInPlaylist({
    required int oldIndex,
    required int newIndex,
    required String id,
  }) {
    _service.moveAudioInPlaylist(
      oldIndex: oldIndex,
      newIndex: newIndex,
      id: id,
    );
  }

  //
  // Podcasts
  //

  List<String> get podcastFeedUrls => _service.podcastFeedUrls;
  List<Audio>? getPodcast(String? feedUrl) => _service.podcasts[feedUrl];
  int get podcastsLength => _service.podcasts.length;
  void addPodcast(String feedUrl, List<Audio> audios) =>
      _service.addPodcast(feedUrl, audios);
  void removePodcast(String feedUrl) => _service.removePodcast(feedUrl);

  bool isPodcastSubscribed(String? feedUrl) =>
      feedUrl == null ? false : _service.podcasts.containsKey(feedUrl);
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

  List<String> get favoriteAlbums => _service.favoriteAlbums;
  int get favoriteAlbumsLength => _service.favoriteAlbums.length;

  bool isFavoriteAlbum(String id) => _service.isFavoriteAlbum(id);

  void addFavoriteAlbum(String id, {required Function() onFail}) =>
      _service.addFavoriteAlbum(id, onFail: onFail);

  void removeFavoriteAlbum(String id, {required Function() onFail}) =>
      _service.removeFavoriteAlbum(id, onFail: onFail);

  //
  // Navigation inside the Library
  //

  String? get selectedPageId => _service.selectedPageId;
  void _setSelectedPageId(String pageId) => _service.setSelectedPageId(pageId);

  Future<void> push({
    required String pageId,
    Widget Function(BuildContext)? builder,
    bool maintainState = false,
    bool replace = false,
  }) async {
    final inLibrary = isPageInLibrary(pageId);
    assert(inLibrary || builder != null);
    if (inLibrary) {
      if (replace) {
        await _masterNavigatorKey.currentState?.pushReplacementNamed(pageId);
      } else {
        await _masterNavigatorKey.currentState?.pushNamed(pageId);
      }
    } else if (builder != null) {
      final materialPageRoute = MaterialPageRoute(
        settings: RouteSettings(
          name: pageId,
        ),
        builder: (context) => AppConfig.isMobilePlatform
            ? MobilePage(page: builder(context))
            : BackGesture(child: builder(context)),
      );

      if (replace) {
        await _masterNavigatorKey.currentState?.pushReplacement(
          materialPageRoute,
        );
      } else {
        await _masterNavigatorKey.currentState?.push(
          materialPageRoute,
        );
      }
    }
  }

  void pop() => _masterNavigatorKey.currentState?.maybePop();

  bool get canPop => _masterNavigatorKey.currentState?.canPop() == true;

  @override
  void didPop(Route route, Route? previousRoute) {
    final pageId = previousRoute?.settings.name;

    printMessageInDebugMode(
      'didPop: ${route.settings.name}, previousPageId: ${previousRoute?.settings.name}',
    );
    if (pageId == null) return;
    _setSelectedPageId(pageId);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    final pageId = route.settings.name;
    printMessageInDebugMode(
      'didPush: $pageId, previousPageId: ${previousRoute?.settings.name}',
    );
    if (pageId == null) return;
    _setSelectedPageId(pageId);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    final pageId = route.settings.name;
    printMessageInDebugMode(
      'didRemove: $pageId, previousPageId: ${previousRoute?.settings.name}',
    );
    if (pageId == null) return;
    _setSelectedPageId(pageId);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    printMessageInDebugMode(
      'didReplace: ${oldRoute?.settings.name}, newPageId: ${newRoute?.settings.name}',
    );
    final pageId = newRoute?.settings.name;
    if (pageId == null) return;
    _setSelectedPageId(pageId);
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    printMessageInDebugMode(
      'didStartUserGesture: ${route.settings.name}, previousPageId: ${previousRoute?.settings.name}',
    );
  }

  @override
  void didStopUserGesture() {
    printMessageInDebugMode('didStopUserGesture');
  }

  @override
  void didChangeTop(Route topRoute, Route? previousTopRoute) {
    printMessageInDebugMode('didChangeTop');
  }

  // Note: Navigator.initState ensures assert(observer.navigator == null);
  // Afterwards the Navigator itself!!! sets the navigator of its observers...
  @override
  NavigatorState? get navigator => null;
  final GlobalKey<NavigatorState> _masterNavigatorKey =
      GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState> get masterNavigatorKey => _masterNavigatorKey;
}
