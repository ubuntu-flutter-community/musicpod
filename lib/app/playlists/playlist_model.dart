import 'dart:async';

import 'package:musicpod/data/audio.dart';
import 'package:musicpod/service/library_service.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class PlaylistModel extends SafeChangeNotifier {
  PlaylistModel(this._service);

  final LibraryService _service;
  StreamSubscription<bool>? _likedAudiosSub;
  StreamSubscription<bool>? _playlistsSub;
  StreamSubscription<bool>? _albumsSub;
  StreamSubscription<bool>? _podcastsSub;
  StreamSubscription<bool>? _stationsSub;

  Future<void> init() async {
    _likedAudiosSub =
        _service.likedAudiosChanged.listen((event) => notifyListeners());
    _playlistsSub =
        _service.playlistsChanged.listen((event) => notifyListeners());
    _albumsSub = _service.albumsChanged.listen((event) => notifyListeners());
    _podcastsSub =
        _service.podcastsChanged.listen((event) => notifyListeners());
    _stationsSub =
        _service.starredStationsChanged.listen((event) => notifyListeners());
  }

  @override
  void dispose() {
    _likedAudiosSub?.cancel();
    _playlistsSub?.cancel();
    _albumsSub?.cancel();
    _podcastsSub?.cancel();
    _stationsSub?.cancel();
    super.dispose();
  }

  int get totalListAmount =>
      starredStationsLength +
      podcastsLength +
      playlistsLength +
      pinnedAlbumsLength +
      5;

  //
  // Liked Audios
  //
  Set<Audio> get likedAudios => _service.likedAudios;

  void addLikedAudio(Audio audio, [bool notify = true]) =>
      _service.addLikedAudio(audio, notify);

  void addLikedAudios(Set<Audio> audios) => _service.addLikedAudios(audios);

  bool liked(Audio audio) => _service.liked(audio);

  void removeLikedAudio(Audio audio, [bool notify = true]) =>
      _service.removeLikedAudio(audio, notify);

  void removeLikedAudios(Set<Audio> audios) =>
      _service.removeLikedAudios(audios);

  //
  // Starred stations
  //

  Map<String, Set<Audio>> get starredStations => _service.starredStations;
  int get starredStationsLength => _service.starredStations.length;
  void addStarredStation(String name, Set<Audio> audios) =>
      _service.addStarredStation(name, audios);

  void unStarStation(String name) => _service.unStarStation(name);

  bool isStarredStation(String name) => _service.isStarredStation(name);

  //
  // Playlists
  //

  Map<String, Set<Audio>> get playlists => _service.playlists;
  int get playlistsLength => playlists.length;
  List<Audio> getPlaylistAt(int index) =>
      playlists.entries.elementAt(index).value.toList();

  bool isPlaylistSaved(String? name) => playlists.containsKey(name);

  void addPlaylist(String name, Set<Audio> audios) =>
      _service.addPlaylist(name, audios);

  void removePlaylist(String name) => _service.removePlaylist(name);

  void updatePlaylistName(String oldName, String newName) =>
      _service.updatePlaylistName(oldName, newName);

  void addAudioToPlaylist(String playlist, Audio audio) =>
      _service.addAudioToPlaylist(playlist, audio);

  void removeAudioFromPlaylist(String playlist, Audio audio) =>
      _service.removeAudioFromPlaylist(playlist, audio);

  List<String> getTopFivePlaylistNames() =>
      playlists.entries.take(5).map((e) => e.key).toList();

  // Podcasts

  Map<String, Set<Audio>> get podcasts => _service.podcasts;
  int get podcastsLength => podcasts.length;
  void addPodcast(String name, Set<Audio> audios) =>
      _service.addPodcast(name, audios);
  void updatePodcast(String name, Set<Audio> audios) =>
      _service.updatePodcast(name, audios);

  void removePodcast(String name) => _service.removePodcast(name);

  bool podcastSubscribed(String name) => podcasts.containsKey(name);

  Map<String, String> get podcastsToFeedUrls => _service.podcastsToFeedUrls;
  void addPlaylistFeed(String playlist, String feedUrl) =>
      _service.addPlaylistFeed(playlist, feedUrl);

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

  void removePinnedAlbum(String name) => _service.removePinnedAlbum(name);

  int? _index;
  int? get index => _index;
  set index(int? value) {
    if (value == null || value == _index) return;
    _index = value;
    notifyListeners();
  }
}
