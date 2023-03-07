import 'package:music/data/audio.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class PlaylistModel extends SafeChangeNotifier {
  int get totalListAmount =>
      starredStationsLength +
      podcastsLength +
      playlistsLength +
      pinnedAlbumsLength +
      5;

  //
  // Liked Audios
  //
  final Set<Audio> _likedAudios = {};
  Set<Audio> get likedAudios => _likedAudios;

  void addLikedAudio(Audio audio) {
    _likedAudios.add(audio);
    notifyListeners();
  }

  void addLikedAudios(Set<Audio> audios) {
    for (var audio in audios) {
      addLikedAudio(audio);
    }
  }

  bool liked(Audio audio) {
    return likedAudios.contains(audio);
  }

  void removeLikedAudio(Audio audio) {
    _likedAudios.remove(audio);
    notifyListeners();
  }

  void removeLikedAudios(Set<Audio> audios) {
    for (var audio in audios) {
      removeLikedAudio(audio);
    }
  }

  //
  // Starred stations
  //

  final Map<String, Set<Audio>> _starredStations = {};
  Map<String, Set<Audio>> get starredStations => _starredStations;
  int get starredStationsLength => _starredStations.length;
  void addStarredStation(String name, Set<Audio> audios) {
    _starredStations.putIfAbsent(name, () => audios);
    notifyListeners();
  }

  void unStarStation(String name) {
    _starredStations.remove(name);
    notifyListeners();
  }

  bool isStarredStation(String name) {
    return _starredStations.containsKey(name);
  }

  //
  // Normal playlists and albums
  //

  final Map<String, Set<Audio>> _playlists = {};
  Map<String, Set<Audio>> get playlists => _playlists;
  int get playlistsLength => _playlists.length;
  List<Audio> getPlaylistAt(int index) =>
      _playlists.entries.elementAt(index).value.toList();

  bool isSavedPlaylist(String name) => _playlists.containsKey(name);

  void addPlaylist(String name, Set<Audio> audios) {
    _playlists.putIfAbsent(name, () => audios);
    notifyListeners();
  }

  void removePlaylist(String name) {
    _playlists.remove(name);
    notifyListeners();
  }

  void updatePlaylistName(String oldName, String newName) {
    if (newName == oldName) return;
    final oldList = _playlists[oldName];
    if (oldList != null) {
      _playlists.remove(oldName);
      _playlists.putIfAbsent(newName, () => oldList);
    }

    notifyListeners();
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
    notifyListeners();
  }

  void removeAudioFromPlaylist(String playlist, Audio audio) {
    final p = _playlists[playlist];
    if (p != null && p.contains(audio)) {
      p.remove(audio);
    }
    notifyListeners();
  }

  List<String> getTopFivePlaylistNames() {
    return _playlists.entries.take(5).map((e) => e.key).toList();
  }

  // Podcasts

  final Map<String, Set<Audio>> _podcasts = {};
  Map<String, Set<Audio>> get podcasts => _podcasts;
  int get podcastsLength => _podcasts.length;
  void addPodcast(String name, Set<Audio> audios) {
    _podcasts.putIfAbsent(name, () => audios);
    notifyListeners();
  }

  void removePodcast(String name) {
    _podcasts.remove(name);
    _podcastsToFeedUrls.remove(name);
    notifyListeners();
  }

  bool podcastSubscribed(String name) => _podcasts.containsKey(name);

  final Map<String, String> _podcastsToFeedUrls = {};
  Map<String, String> get podcastsToFeedUrls => _podcastsToFeedUrls;
  void addPlaylistFeed(String playlist, String feedUrl) {
    _podcastsToFeedUrls.putIfAbsent(playlist, () => feedUrl);
    notifyListeners();
  }

  //
  // Albums
  //

  final Map<String, Set<Audio>> _pinnedAlbums = {};
  Map<String, Set<Audio>> get pinnedAlbums => _pinnedAlbums;
  int get pinnedAlbumsLength => _pinnedAlbums.length;
  List<Audio> getAlbumAt(int index) =>
      _pinnedAlbums.entries.elementAt(index).value.toList();

  bool isPinnedAlbum(String name) => _pinnedAlbums.containsKey(name);

  void addPinnedAlbum(String name, Set<Audio> audios) {
    _pinnedAlbums.putIfAbsent(name, () => audios);
    notifyListeners();
  }

  void removePinnedAlbum(String name) {
    _pinnedAlbums.remove(name);
    notifyListeners();
  }

  Future<void> init() async {
    // TODO: load from db
  }
  // Future<void> dispose() async {
  // TODO: safe to db
  // }

  int? _index;
  int? get index => _index;
  set index(int? value) {
    if (value == null || value == _index) return;
    _index = value;
    notifyListeners();
  }
}
