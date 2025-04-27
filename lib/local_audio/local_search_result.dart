import '../common/data/audio.dart';

class LocalSearchResult {
  const LocalSearchResult({
    required this.titles,
    required this.artists,
    required this.albums,
    required this.genres,
    required this.playlists,
  });

  final List<Audio>? titles;
  final List<String>? artists;

  final List<String>? albums;
  final List<String>? genres;
  final List<String>? playlists;
}
