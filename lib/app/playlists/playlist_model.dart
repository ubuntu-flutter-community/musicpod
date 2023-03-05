import 'package:music/data/audio.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class PlaylistModel extends SafeChangeNotifier {
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

  final Set<Audio> _starredStations = {};
  Set<Audio> get starredStations => _starredStations;
  void addStarredStation(Audio audio) {
    _starredStations.add(audio);
    notifyListeners();
  }

  void unStarStation(Audio audio) {
    _starredStations.remove(audio);
    notifyListeners();
  }

  bool isStarredStation(Audio audio) {
    return audio.name == null ? false : playlists.containsKey(audio.name);
  }

  final Map<String, Set<Audio>> _playlists = {};
  Map<String, Set<Audio>> get playlists => _playlists;
  List<Audio> getPlaylistAt(int index) =>
      _playlists.entries.elementAt(index).value.toList();
  void addPlaylist(String name, Set<Audio> audios) {
    _playlists.putIfAbsent(name, () => audios);
    index = playlists.length + 3;
  }

  final Map<String, String> _playlistsToFeedUrls = {};
  Map<String, String> get playlistsToFeedUrls => _playlistsToFeedUrls;
  void addPlaylistFeed(String playlist, String feedUrl) {
    _playlistsToFeedUrls.putIfAbsent(playlist, () => feedUrl);
    notifyListeners();
  }

  void removePlaylistFeed(String playlist) {
    _playlistsToFeedUrls.remove(playlist);
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

  void removePlaylist(String name) {
    _playlists.remove(name);
    index = playlists.length + 3;
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

  Future<void> init() async {
    _playlists.putIfAbsent('likedAudio', () => _likedAudios);
  }

  int? _index;
  int? get index => _index;
  set index(int? value) {
    if (value == null || value == _index) return;
    _index = value;
    notifyListeners();
  }
}
