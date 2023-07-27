import 'dart:async';

import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/service/library_service.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class LibraryModel extends SafeChangeNotifier {
  LibraryModel(this._service);

  final LibraryService _service;
  StreamSubscription<bool>? _likedAudiosSub;
  StreamSubscription<bool>? _playlistsSub;
  StreamSubscription<bool>? _albumsSub;
  StreamSubscription<bool>? _podcastsSub;
  StreamSubscription<bool>? _stationsSub;
  StreamSubscription<int?>? _localAudioIndexSub;

  bool ready = false;

  Future<void> init() async {
    await _service.init();

    _localAudioIndexSub = _service.localAudioIndexStream
        .listen((index) => localAudioindex = index);
    _likedAudiosSub =
        _service.likedAudiosChanged.listen((event) => notifyListeners());
    _playlistsSub =
        _service.playlistsChanged.listen((event) => notifyListeners());
    _albumsSub = _service.albumsChanged.listen((event) => notifyListeners());
    _podcastsSub =
        _service.podcastsChanged.listen((event) => notifyListeners());
    _stationsSub =
        _service.starredStationsChanged.listen((event) => notifyListeners());

    ready = true;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    _localAudioIndexSub?.cancel();
    _likedAudiosSub?.cancel();
    _playlistsSub?.cancel();
    _albumsSub?.cancel();
    _podcastsSub?.cancel();
    _stationsSub?.cancel();

    await _service.dispose();
    super.dispose();
  }

  int get totalListAmount {
    const fix = 7;

    return starredStationsLength +
        podcastsLength +
        playlistsLength +
        pinnedAlbumsLength +
        fix;
  }

  AudioPageType? _audioPageType;
  AudioPageType? get audioPageType => _audioPageType;
  void setAudioPageType(AudioPageType? value) {
    if (value == _audioPageType) {
      _audioPageType = null;
    } else {
      _audioPageType = value;
    }
    notifyListeners();
  }

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

  bool get showStarredStations =>
      audioPageType == null || audioPageType == AudioPageType.radio;

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

  bool get showPlaylists =>
      audioPageType == null || audioPageType == AudioPageType.playlist;

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

  bool get showSubbedPodcasts =>
      audioPageType == null || audioPageType == AudioPageType.podcast;

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

  bool get showPinnedAlbums =>
      audioPageType == null || audioPageType == AudioPageType.album;

  int? get localAudioindex => _service.localAudioIndex;
  set localAudioindex(int? value) {
    if (value == null || value == _service.localAudioIndex) return;
    _service.setLocalAudioIndex(value);
  }
}
