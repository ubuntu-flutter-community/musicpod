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

  Country? _country;
  Country? get country => _country;
  void setCountry(Country? value) {
    if (value == _country) return;
    _country = value;
    setSearchQuery(search: RadioSearch.country);
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
    setSearchQuery(search: RadioSearch.tag);
  }

  Future<Set<Audio>?> getStations({
    required RadioSearch radioSearch,
    required String? query,
  }) async {
    final stations = switch (radioSearch) {
      RadioSearch.tag => await _radioService.getStations(tag: query),
      RadioSearch.country =>
        await _radioService.getStations(country: query?.camelToSentence()),
      RadioSearch.name => await _radioService.getStations(name: query),
      RadioSearch.state => await _radioService.getStations(state: query),
    };

    if (stations == null) return null;

    if (stations.isEmpty) {
      return <Audio>{};
    }

    return Set.from(
      stations.map(
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

  String? _connectedHost;
  Future<String?> init({
    required String? countryCode,
    required int index,
  }) async {
    _connectedHost ??= await _radioService.init();

    final lastCountryCode = (await readSetting(kLastCountryCode)) as String?;
    final lastFav = (await readSetting(kLastFav)) as String?;

    _country ??= Country.values
        .firstWhereOrNull((c) => c.code == (lastCountryCode ?? countryCode));

    if (_connectedHost?.isNotEmpty == true) {
      _tag ??= lastFav == null || tags == null || tags!.isEmpty
          ? null
          : tags!.firstWhere((t) => t.name.contains(lastFav));
    }

    setSearchQuery(search: RadioSearch.values[index]);

    return _connectedHost;
  }

  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  void setSearchQuery({RadioSearch? search, String? query}) {
    switch (search) {
      case RadioSearch.country:
        _searchQuery = country?.name;
        break;
      case RadioSearch.tag:
        _searchQuery = _tag?.name;
      default:
        _searchQuery = query ?? _searchQuery;
    }
    notifyListeners();
  }

  bool _showTags = false;
  bool get showTags => _showTags;
  void setShowTags(bool value) {
    if (value == _showTags) return;
    _showTags = value;
    notifyListeners();
  }
}
