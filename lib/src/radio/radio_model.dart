import 'dart:async';

import 'package:collection/collection.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide Country;
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../constants.dart';
import '../../data.dart';
import '../../string_x.dart';
import '../../utils.dart';
import 'radio_search.dart';
import 'radio_service.dart';

class RadioModel extends SafeChangeNotifier {
  final RadioService _radioService;

  RadioModel(this._radioService);

  StreamSubscription<bool>? _stationsSub;
  StreamSubscription<bool>? _statusCodeSub;
  StreamSubscription<bool>? _tagsSub;

  Country? _country;
  Country? get country => _country;
  void setCountry(Country? value) {
    if (value == _country) return;
    _country = value;
    _loadQueryBySearch();
  }

  List<Country> get sortedCountries {
    if (_country == null) return Country.values;
    final notSelected =
        Country.values.where((c) => c != _country).toList().sorted(
              (a, b) => a.name.compareTo(b.name),
            );
    final list = <Country>[_country!, ...notSelected];

    return list;
  }

  List<Tag>? get tags => _radioService.tags;
  Tag? _tag;
  Tag? get tag => _tag;
  void setTag(Tag? value) {
    if (value == _tag) return;
    _tag = value;
    _loadQueryBySearch();
  }

  Future<Set<Audio>?> getStations({
    String? country,
    String? name,
    String? state,
    Tag? tag,
    int limit = 100,
  }) async {
    final s = await _radioService.getStations(
      tag: tag,
      name: name,
      country: country?.camelToSentence(),
      state: state,
      limit: limit,
    );
    if (s == null) return null;

    if (s.isEmpty) {
      return <Audio>{};
    }

    return Set.from(
      s.map(
        (e) {
          var artist = e.bitrate == 0 ? '' : '${e.bitrate} kb/s';
          if (e.language?.isNotEmpty == true) {
            artist += ', ${e.language}';
          }
          return Audio(
            url: e.urlResolved,
            title: e.name,
            artist: artist,
            album: e.tags ?? '',
            audioType: AudioType.radio,
            imageUrl: e.favicon,
            website: e.homepage,
          );
        },
      ),
    );
  }

  String? get statusCode => _radioService.statusCode;

  int _limit = 100;
  int get limit => _limit;
  void setLimit(int? value) {
    if (value == null || value == _limit) return;
    _limit = value;
    notifyListeners();
  }

  String? _connectedHost;
  Future<String?> init({
    required String? countryCode,
  }) async {
    _connectedHost ??= await _radioService.init();

    final lastCountryCode = (await readSetting(kLastCountryCode)) as String?;
    final lastFav = (await readSetting(kLastFav)) as String?;

    _statusCodeSub ??=
        _radioService.statusCodeChanged.listen((_) => notifyListeners());
    _tagsSub ??= _radioService.tagsChanged.listen((_) => notifyListeners());
    _country ??= Country.values
        .firstWhereOrNull((c) => c.code == (lastCountryCode ?? countryCode));

    if (_connectedHost?.isNotEmpty == true) {
      await _radioService.loadTags();
      _tag ??= lastFav == null || tags == null || tags!.isEmpty
          ? null
          : tags!.firstWhere((t) => t.name.contains(lastFav));
    }

    _loadQueryBySearch();

    return _connectedHost;
  }

  void _loadQueryBySearch() {
    switch (_radioSearch) {
      case RadioSearch.country:
        _searchQuery = country?.name;
        break;
      case RadioSearch.tag:
        _searchQuery = _tag?.name;
      case RadioSearch.name:
        _searchQuery = _searchQuery;
      case RadioSearch.state:
        _searchQuery = state;
      default:
    }
    notifyListeners();
  }

  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  void setSearchQuery(String? value) {
    if (value == _searchQuery) return;
    _searchQuery = value;
    notifyListeners();
  }

  String? _state;
  String? get state => _state;
  void setState(String? value) {
    if (value == _state) return;
    _state = value;
    notifyListeners();
  }

  bool _showTags = false;
  bool get showTags => _showTags;
  void setShowTags(bool value) {
    if (value == _showTags) return;
    _showTags = value;
    notifyListeners();
  }

  RadioSearch _radioSearch = RadioSearch.country;
  RadioSearch get radioSearch => _radioSearch;
  void setRadioSearch(RadioSearch value) {
    if (value == _radioSearch) return;
    _radioSearch = value;
    _loadQueryBySearch();
  }

  @override
  void dispose() {
    _stationsSub?.cancel();
    _tagsSub?.cancel();
    _statusCodeSub?.cancel();
    super.dispose();
  }
}
