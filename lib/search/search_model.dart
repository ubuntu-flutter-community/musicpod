import '../common/data/audio.dart';
import '../common/data/podcast_genre.dart';
import '../local_audio/local_audio_model.dart';
import '../podcasts/podcast_service.dart';
import '../radio/radio_service.dart';
import 'local_audio_search_result.dart';
import 'package:collection/collection.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:watch_it/watch_it.dart';
import 'search_type.dart';

class SearchModel extends SafeChangeNotifier {
  SearchModel({
    required RadioService radioService,
    required PodcastService podcastService,
    required LocalAudioModel localAudioModel,
  })  : _radioService = radioService,
        _podcastService = podcastService,
        _localAudioModel = localAudioModel;

  final RadioService _radioService;
  final PodcastService _podcastService;
  // TODO: replac with service when all is migrated
  final LocalAudioModel _localAudioModel;

  Set<SearchType> _searchTypes = {};
  Set<SearchType> get searchTypes => _searchTypes;
  AudioType _audioType = AudioType.radio;
  AudioType get audioType => _audioType;
  void setAudioType(AudioType value) {
    if (value == _audioType) return;
    _audioType = value;
    _searchTypes = SearchType.values
        .where((e) => e.name.contains(_audioType.name))
        .toSet();
    setSearchType(_searchTypes.first);
  }

  SearchType _searchType = SearchType.radioName;
  SearchType get searchType => _searchType;
  void setSearchType(SearchType value) {
    _searchType = value;
    notifyListeners();
  }

  String? _searchQuery;
  String? get searchQuery => _searchQuery;

  LocalAudioSearchResult? _localAudioSearchResult;
  LocalAudioSearchResult? get localAudioSearchResult => _localAudioSearchResult;
  void setLocalAudioSearchResult(LocalAudioSearchResult? value) {
    _localAudioSearchResult = value;
    notifyListeners();
  }

  SearchResult? _podcastSearchResult;
  SearchResult? get podcastSearchResult => _podcastSearchResult;
  void setPodcastSearchResult(SearchResult? value) {
    _podcastSearchResult = value;
    notifyListeners();
  }

  List<Audio>? _radioSearchResult;
  List<Audio>? get radioSearchResult => _radioSearchResult;
  void setRadioSearchResult(List<Audio>? value) {
    _radioSearchResult = value;
    notifyListeners();
  }

  void setSearchQuery(String? value) {
    if (value == _searchQuery) return;
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> search() async {
    switch (_audioType) {
      case AudioType.podcast:
        setPodcastSearchResult(null);
      case AudioType.local:
        setLocalAudioSearchResult(null);
      case AudioType.radio:
        setRadioSearchResult(null);
    }

    return switch (_searchType) {
      SearchType.radioName =>
        await _radioService.getStations(name: _searchQuery).then(
              (v) => setRadioSearchResult(
                v?.map((e) => Audio.fromStation(e)).toList(),
              ),
            ),
      SearchType.radioTag =>
        await di<RadioService>().getStations(tag: _searchQuery).then(
              (v) => setRadioSearchResult(
                v?.map((e) => Audio.fromStation(e)).toList(),
              ),
            ),
      SearchType.radioCountry =>
        await di<RadioService>().getStations(country: _searchQuery).then(
              (v) => setRadioSearchResult(
                v?.map((e) => Audio.fromStation(e)).toList(),
              ),
            ),
      SearchType.radioLanguage =>
        await di<RadioService>().getStations(language: _searchQuery).then(
              (v) => setRadioSearchResult(
                v?.map((e) => Audio.fromStation(e)).toList(),
              ),
            ),
      SearchType.podcastTitle => await _podcastService
          .search(searchQuery: _searchQuery)
          .then((v) => setPodcastSearchResult(v)),
      SearchType.podcastGenre => await _podcastService
          .search(
            podcastGenre: PodcastGenre.values.firstWhereOrNull(
                  (e) => e.name
                      .toLowerCase()
                      .contains(_searchQuery?.toLowerCase() ?? ''),
                ) ??
                PodcastGenre.all,
          )
          .then((v) => setPodcastSearchResult(v)),
      SearchType.localArtist ||
      SearchType.localTitle ||
      SearchType.localArtist ||
      SearchType.localGenreName =>
        localSearch(_localAudioModel.audios),
      _ => Future.value()
    };
  }

  LocalAudioSearchResult? localSearch(Set<Audio>? audios) {
    if (_searchQuery == null) return null;
    if (_searchQuery?.isEmpty == true) {
      (
        titlesSearchResult: {},
        albumSearchResult: {},
        artistsSearchResult: {},
        genresSearchResult: {},
      );
    }

    final allAlbumsFindings = audios?.where(
      (audio) =>
          audio.album?.isNotEmpty == true &&
          audio.album!.toLowerCase().contains(_searchQuery!.toLowerCase()),
    );

    final albumsResult = <Audio>{};
    if (allAlbumsFindings != null) {
      for (var a in allAlbumsFindings) {
        if (albumsResult.none((element) => element.album == a.album)) {
          albumsResult.add(a);
        }
      }
    }

    final allGenresFindings = audios?.where(
      (audio) =>
          audio.genre?.isNotEmpty == true &&
          audio.genre!.toLowerCase().contains(_searchQuery!.toLowerCase()),
    );

    final genreFindings = <Audio>{};
    if (allGenresFindings != null) {
      for (var a in allGenresFindings) {
        if (genreFindings.none((element) => element.genre == a.genre)) {
          genreFindings.add(a);
        }
      }
    }

    final allArtistFindings = audios?.where(
      (audio) =>
          audio.artist?.isNotEmpty == true &&
          audio.artist!.toLowerCase().contains(_searchQuery!.toLowerCase()),
    );
    final artistsResult = <Audio>{};
    if (allArtistFindings != null) {
      for (var a in allArtistFindings) {
        if (artistsResult.none(
          (e) => e.artist == a.artist,
        )) {
          artistsResult.add(a);
        }
      }
    }

    return (
      titlesSearchResult: Set.from(
        audios?.where(
              (audio) =>
                  audio.title?.isNotEmpty == true &&
                  audio.title!
                      .toLowerCase()
                      .contains(_searchQuery!.toLowerCase()),
            ) ??
            <Audio>[],
      ),
      albumSearchResult: albumsResult,
      artistsSearchResult: artistsResult,
      genresSearchResult: genreFindings,
    );
  }
}
