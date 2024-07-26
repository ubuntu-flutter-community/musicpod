import '../common/data/audio.dart';

typedef LocalAudioSearchResult = ({
  Set<Audio> titlesSearchResult,
  // TODO: all but titles should be String here!!!
  Set<Audio> albumSearchResult,
  Set<Audio> artistsSearchResult,
  Set<Audio> genresSearchResult,
});
