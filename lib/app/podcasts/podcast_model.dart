import 'package:collection/collection.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:music/data/audio.dart';
import 'package:music/string_x.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

final countries = [
  Country.AFGHANISTAN,
  Country.ALAND_ISLANDS,
  Country.ALBANIA,
  Country.ALGERIA,
  Country.AMERICAN_SAMOA,
  Country.ANDORRA,
  Country.ANGOLA,
  Country.ANGUILLA,
  Country.ANTARCTICA,
  Country.ANTIGUA_AND_BARBUDA,
  Country.ARGENTINA,
  Country.ARMENIA,
  Country.ARUBA,
  Country.AUSTRALIA,
  Country.AUSTRIA,
  Country.AZERBAIJAN,
  Country.BAHAMAS,
  Country.BAHRAIN,
  Country.BANGLADESH,
  Country.BARBADOS,
  Country.BELARUS,
  Country.BELGIUM,
  Country.BELIZE,
  Country.BENIN,
  Country.BERMUDA,
  Country.BHUTAN,
  Country.BOLIVIA,
  Country.BONAIRE,
  Country.BOSNIA_AND_HERZEGOVINA,
  Country.BOTSWANA,
  Country.BOUVET_ISLAND,
  Country.BRAZIL,
  Country.BRITISH_INDIAN_OCEAN_TERRITORY,
  Country.BRITISH_VIRGIN_ISLANDS,
  Country.BRUNEI_DARUSSALAM,
  Country.BULGARIA,
  Country.BURKINA_FASO,
  Country.BURUNDI,
  Country.CABO_VERDE,
  Country.CAMBODIA,
  Country.CAMEROON,
  Country.CANADA,
  Country.CAYMAN_ISLANDS,
  Country.CENTRAL_AFRICAN_REPUBLIC,
  Country.CHAD,
  Country.CHILE,
  Country.CHINA,
  Country.CHRISTMAS_ISLAND,
  Country.COCOS_ISLANDS,
  Country.COLOMBIA,
  Country.COMOROS,
  Country.CONGO,
  Country.CONGO_DEMOCRATIC_REPUBLIC_OF,
  Country.COOK_ISLANDS,
  Country.COSTA_RICA,
  Country.COTE_D_IVOIRE,
  Country.CROATIA,
  Country.CUBA,
  Country.CURACAO,
  Country.CYPRUS,
  Country.CZECHIA,
  Country.DENMARK,
  Country.DJIBOUTI,
  Country.DOMINICA,
  Country.DOMINICAN_REPUBLIC,
  Country.ECUADOR,
  Country.EGYPT,
  Country.EL_SALVADOR,
  Country.EQUATORIAL_GUINEA,
  Country.ERITREA,
  Country.ESTONIA,
  Country.ETHIOPIA,
  Country.FALKLAND_ISLANDS,
  Country.FAROE_ISLANDS,
  Country.FIJI,
  Country.FINLAND,
  Country.FRANCE,
  Country.FRENCH_GUIANA,
  Country.FRENCH_POLYNESIA,
  Country.FRENCH_SOUTHERN_TERRITORIES,
  Country.GABON,
  Country.GAMBIA,
  Country.GEORGIA,
  Country.GERMANY,
  Country.GHANA,
  Country.GIBRALTAR,
  Country.GREECE,
  Country.GREENLAND,
  Country.GRENADA,
  Country.GUADELOUPE,
  Country.GUAM,
  Country.GUATEMALA,
  Country.GUERNSEY,
  Country.GUINEA,
  Country.GUINEA_BISSAU,
  Country.GUYANA,
  Country.HAITI,
  Country.HEARD_ISLAND_AND_MCDONALD_ISLANDS,
  Country.HONDURAS,
  Country.HONG_KONG,
  Country.HUNGARY,
  Country.ICELAND,
  Country.INDIA,
  Country.INDONESIA,
  Country.IRAN,
  Country.IRAQ,
  Country.IRELAND,
  Country.ISLE_OF_MAN,
  Country.ISRAEL,
  Country.ITALY,
  Country.JAMAICA,
  Country.JAPAN,
  Country.JERSEY,
  Country.JORDAN,
  Country.KAZAKHSTAN,
  Country.KENYA,
  Country.KIRIBATI,
  Country.KUWAIT,
  Country.KYRGYZSTAN,
  Country.LAOS,
  Country.LATVIA,
  Country.LEBANON,
  Country.LESOTHO,
  Country.LIBERIA,
  Country.LIBYA,
  Country.LIECHTENSTEIN,
  Country.LITHUANIA,
  Country.LUXEMBOURG,
  Country.MACAO,
  Country.MACEDONIA,
  Country.MADAGASCAR,
  Country.MALAWI,
  Country.MALAYSIA,
  Country.MALDIVES,
  Country.MALI,
  Country.MALTA,
  Country.MARSHALL_ISLANDS,
  Country.MARTINIQUE,
  Country.MAURITANIA,
  Country.MAURITIUS,
  Country.MAYOTTE,
  Country.MEXICO,
  Country.MICRONESIA,
  Country.MOLDOVA,
  Country.MONACO,
  Country.MONGOLIA,
  Country.MONTENEGRO,
  Country.MONTSERRAT,
  Country.MOROCCO,
  Country.MOZAMBIQUE,
  Country.MYANMAR,
  Country.NAMIBIA,
  Country.NAURU,
  Country.NEPAL,
  Country.NETHERLANDS,
  Country.NEW_CALEDONIA,
  Country.NEW_ZEALAND,
  Country.NICARAGUA,
  Country.NIGER,
  Country.NIGERIA,
  Country.NIUE,
  Country.NORFOLK_ISLAND,
  Country.NORTH_KOREA,
  Country.NORTHERN_MARIANA_ISLANDS,
  Country.NORWAY,
  Country.OMAN,
  Country.PAKISTAN,
  Country.PALAU,
  Country.PALESTINE,
  Country.PANAMA,
  Country.PAPUA_NEW_GUINEA,
  Country.PARAGUAY,
  Country.PERU,
  Country.PHILIPPINES,
  Country.PITCAIRN,
  Country.POLAND,
  Country.PORTUGAL,
  Country.PUERTO_RICO,
  Country.QATAR,
  Country.REUNION,
  Country.ROMANIA,
  Country.RUSSIAN_FEDERATION,
  Country.RWANDA,
  Country.SAINT_BARTHELEMY,
  Country.SAINT_HELENA,
  Country.SAINT_KITTS_AND_NEVIS,
  Country.SAINT_LUCIA,
  Country.SAINT_MARTIN,
  Country.SAINT_PIERRE_AND_MIQUELON,
  Country.SAINT_VINCENT_AND_THE_GRENADINES,
  Country.SAMOA,
  Country.SAN_MARINO,
  Country.SAO_TOME_AND_PRINCIPE,
  Country.SAUDI_ARABIA,
  Country.SENEGAL,
  Country.SERBIA,
  Country.SEYCHELLES,
  Country.SIERRA_LEONE,
  Country.SINGAPORE,
  Country.SINT_MAARTEN,
  Country.SLOVAKIA,
  Country.SLOVENIA,
  Country.SOLOMON_ISLANDS,
  Country.SOMALIA,
  Country.SOUTH_AFRICA,
  Country.SOUTH_GEORGIA_AND_THE_SOUTH_SANDWICH_ISLANDS,
  Country.SOUTH_KOREA,
  Country.SOUTH_SUDAN,
  Country.SPAIN,
  Country.SRI_LANKA,
  Country.SUDAN,
  Country.SURINAME,
  Country.SVALBARD_AND_JAN_MAYEN,
  Country.SWAZILAND,
  Country.SWEDEN,
  Country.SWITZERLAND,
  Country.SYRIAN_ARAB_REPUBLIC,
  Country.TAIWAN,
  Country.TAJIKISTAN,
  Country.TANZANIA,
  Country.THAILAND,
  Country.TIMOR_LESTE,
  Country.TOGO,
  Country.TOKELAU,
  Country.TONGA,
  Country.TRINIDAD_AND_TOBAGO,
  Country.TUNISIA,
  Country.TURKEY,
  Country.TURKMENISTAN,
  Country.TURKS_AND_CAICOS_ISLANDS,
  Country.TUVALU,
  Country.UGANDA,
  Country.UKRAINE,
  Country.UNITED_ARAB_EMIRATES,
  Country.UNITED_KINGDOM,
  Country.UNITED_STATES,
  Country.UNITED_STATES_MINOR_OUTLYING_ISLANDS,
  Country.URUGUAY,
  Country.US_VIRGIN_ISLANDS,
  Country.UZBEKISTAN,
  Country.VANUATU,
  Country.VATICAN_CITY,
  Country.VENEZUELA,
  Country.VIET_NAM,
  Country.WALLIS_AND_FUTUNA,
  Country.WESTERN_SAHARA,
  Country.YEMEN,
  Country.ZAMBIA,
  Country.ZIMBABWE,
];

enum PodcastGenre {
  arts,
  business,
  comedy,
  education,
  fiction,
  government,
  healthAndFitness,
  history,
  kidsAndFamily,
  leisure,
  music,
  news,
  religionAndSpirituality,
  science,
  societyAndCulture,
  sports,
  tvAndFilm,
  technology,
  trueCrime;

  String get id {
    switch (this) {
      case healthAndFitness:
        return 'Health & Fitness';
      case kidsAndFamily:
        return 'Kids & Family';
      case religionAndSpirituality:
        return 'Religion & Spirituality';
      case societyAndCulture:
        return 'Society & Culture';
      case tvAndFilm:
        return 'TV & Film';
      case trueCrime:
        return 'True Crime';
      default:
        return name.capitalize();
    }
  }
}

class PodcastModel extends SafeChangeNotifier {
  PodcastModel() : _search = Search();

  final Search _search;

  Set<Set<Audio>>? _podcastSearchResult;
  Set<Set<Audio>>? get podcastSearchResult => _podcastSearchResult;
  set podcastSearchResult(Set<Set<Audio>>? value) {
    _podcastSearchResult = value;
    notifyListeners();
  }

  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  void setSearchQuery(String? value) {
    if (value == null || value == _searchQuery) return;
    _searchQuery = value;
    notifyListeners();
  }

  Set<Set<Audio>>? _chartsPodcasts;
  Set<Set<Audio>>? get chartsPodcasts => _chartsPodcasts;
  set chartsPodcasts(Set<Set<Audio>>? value) {
    _chartsPodcasts = value;
    notifyListeners();
  }

  Country _country = Country.UNITED_STATES;
  Country get country => _country;
  set country(Country value) {
    if (value == _country) return;
    _country = value;
    notifyListeners();
  }

  Language _language = Language.NONE;
  Language get language => _language;
  set language(Language value) {
    if (value == _language) return;
    _language = value;
    notifyListeners();
  }

  PodcastGenre _podcastGenre = PodcastGenre.science;
  PodcastGenre get podcastGenre => _podcastGenre;
  set podcastGenre(PodcastGenre value) {
    if (value == _podcastGenre) return;
    _podcastGenre = value;
    notifyListeners();
  }

  List<PodcastGenre> get sortedGenres {
    final notSelected =
        PodcastGenre.values.where((g) => g != podcastGenre).toList();

    return [podcastGenre, ...notSelected];
  }

  List<Country> get sortedCountries {
    final notSelected = countries
        .where((c) => c != country)
        .toList()
        .sorted((a, b) => a.countryCode.compareTo(b.countryCode));
    final list = <Country>[country, ...notSelected];

    return list;
  }

  Future<void> init(String? countryCode) async {
    final c = countries.firstWhereOrNull((c) => c.countryCode == countryCode);
    if (c != null) {
      _country = c;
    }
    await loadCharts();
  }

  Future<void> loadCharts() async {
    chartsPodcasts = null;
    final chartsSearch = await _search.charts(
      genre: podcastGenre.id,
      limit: 10,
      country: _country,
    );

    if (chartsSearch.successful && chartsSearch.items.isNotEmpty) {
      _chartsPodcasts ??= {};
      _chartsPodcasts?.clear();

      for (var item in chartsSearch.items) {
        if (item.feedUrl != null) {
          final Podcast podcast = await Podcast.loadFeed(
            url: item.feedUrl!,
          );

          final episodes = <Audio>{};

          for (var episode in podcast.episodes ?? <Episode>[]) {
            final audio = Audio(
              url: episode.contentUrl,
              audioType: AudioType.podcast,
              name: podcast.title,
              imageUrl: podcast.image,
              metadata: Metadata(
                title: episode.title,
                album: item.collectionName,
                artist: item.artistName,
              ),
              description: podcast.description,
              website: podcast.url,
            );

            episodes.add(audio);
          }
          _chartsPodcasts?.add(episodes);
        }
      }
    } else {
      _chartsPodcasts = null;
    }

    notifyListeners();
  }

  Future<void> search({String? searchQuery, bool useAlbumImage = false}) async {
    if (searchQuery?.isEmpty == true) return;
    podcastSearchResult = null;

    SearchResult results = await _search.search(
      searchQuery!,
      country: _country,
      language: _language,
      limit: 10,
    );

    if (results.successful && results.items.isNotEmpty) {
      _podcastSearchResult ??= {};
      _podcastSearchResult?.clear();

      for (var item in results.items) {
        if (item.feedUrl != null) {
          final Podcast podcast = await Podcast.loadFeed(
            url: item.feedUrl!,
          );

          if (podcast.episodes?.isNotEmpty == true) {
            final episodes = <Audio>{};

            for (var episode in podcast.episodes!) {
              if (episode.contentUrl != null) {
                final audio = Audio(
                  url: episode.contentUrl,
                  audioType: AudioType.podcast,
                  name: '${podcast.title ?? ''} - ${episode.title}',
                  imageUrl: useAlbumImage
                      ? podcast.image ?? episode.imageUrl
                      : episode.imageUrl ?? podcast.image,
                  metadata: Metadata(
                    title: episode.title,
                    album: podcast.title,
                    artist: podcast.copyright,
                  ),
                  description: podcast.description,
                  website: podcast.url,
                );

                episodes.add(audio);
              }
            }
            _podcastSearchResult?.add(episodes);
            notifyListeners();
          }
        }
      }
    } else {
      podcastSearchResult = {};
    }
  }
}
